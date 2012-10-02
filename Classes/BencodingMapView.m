/**
 This file has been forked and modified from the Titanium project to add Polygon support
 */

/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"
#import "TiUtils.h"
#import "TiMapAnnotationProxy.h"
#import "TiMapPinAnnotationView.h"
#import "TiMapImageAnnotationView.h"
#import "BencodingMapView.h"
#import "BencodingMapViewProxy.h"
#import <KMLParser.h>
#import "MKPolygon+ViewOptions.h"
#import "MKCircle+ViewOptions.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"
@implementation BencodingMapView

#pragma mark Internal

bool respondsToMKUserTrackingMode = NO;
bool polygonClickListenerAdded = NO;
int const kTagIdValue = -111111;

-(void)dealloc
{
	if (map!=nil)
	{
		map.delegate = nil;
		RELEASE_TO_NIL(map);
	}
    if (mapLine2View) {
        CFRelease(mapLine2View);
        mapLine2View = nil;
    }
    if (mapName2Line) {
        CFRelease(mapName2Line);
        mapName2Line = nil;
    }
    
    if(tapInterceptor!=nil)
    {
        RELEASE_TO_NIL(tapInterceptor);
    }
	[super dealloc];
}

-(void)render
{
    if (![NSThread isMainThread]) {
        TiThreadPerformOnMainThread(^{[self render];}, NO);
        return;
    }
    //TIMOB-10892 if any of below conditions is true , regionthatfits returns invalid.
    if (map == nil || map.bounds.size.width == 0 || map.bounds.size.height == 0)
    {
        return;
    }
    
    if (region.center.latitude!=0 && region.center.longitude!=0)
    {
        if (regionFits) {
            [map setRegion:[map regionThatFits:region] animated:animate];
        }
        else {
            [map setRegion:region animated:animate];
        }
    }
}

-(MKMapView*)map
{
    if (map==nil)
    {
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        map.delegate = self;
        map.userInteractionEnabled = YES;
        map.showsUserLocation = YES; // defaults
        map.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:map];
        mapLine2View = CFDictionaryCreateMutable(NULL, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        mapName2Line = CFDictionaryCreateMutable(NULL, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //Initialize loaded state to YES. This will automatically go to NO if the map needs to download new data
        loaded = YES;
        
        //Add in User Tracking
        respondsToMKUserTrackingMode = [MKMapView instancesRespondToSelector:@selector(setUserTrackingMode:)];
        
        if (respondsToMKUserTrackingMode)
        {
            map.userTrackingMode = MKUserTrackingModeNone;
        }
    }
    return map;
}

- (NSArray *)customAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.map.annotations];
    [annotations removeObject:self.map.userLocation];
    return annotations;
}

-(void)willFirePropertyChanges
{
	regionFits = [TiUtils boolValue:[self.proxy valueForKey:@"regionFit"]];
	animate = [TiUtils boolValue:[self.proxy valueForKey:@"animate"]];
}

-(void)didFirePropertyChanges
{
	[self render];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:[self map] positionRect:bounds];
    [super frameSizeChanged:frame bounds:bounds];
    [self render];
}

-(TiMapAnnotationProxy*)annotationFromArg:(id)arg
{
    return [(BencodingMapViewProxy*)[self proxy] annotationFromArg:arg];
}

-(NSArray*)annotationsFromArgs:(id)value
{
	ENSURE_TYPE_OR_NIL(value,NSArray);
	NSMutableArray * result = [NSMutableArray arrayWithCapacity:[value count]];
	if (value!=nil)
	{
		for (id arg in value)
		{
			[result addObject:[self annotationFromArg:arg]];
		}
	}
	return result;
}

-(void)refreshAnnotation:(TiMapAnnotationProxy*)proxy readd:(BOOL)yn
{
	NSArray *selected = map.selectedAnnotations;
	BOOL wasSelected = [selected containsObject:proxy]; //If selected == nil, this still returns FALSE.
	if (yn==NO)
	{
		[map deselectAnnotation:proxy animated:NO];
	}
	else
	{
		[map removeAnnotation:proxy];
		[map addAnnotation:proxy];
		[map setNeedsLayout];
	}
	if (wasSelected)
	{
		[map selectAnnotation:proxy animated:NO];
	}
}

#pragma mark Public APIs


-(void)addAnnotation:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(addAnnotation,args);
	[[self map] addAnnotation:[self annotationFromArg:args]];
}

-(void)addAnnotations:(id)args
{
	ENSURE_TYPE(args,NSArray);
	ENSURE_UI_THREAD(addAnnotations,args);
    
	[[self map] addAnnotations:[self annotationsFromArgs:args]];
}

-(void)removeAnnotation:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(removeAnnotation,args);
    
	id<MKAnnotation> doomedAnnotation = nil;
    
	if ([args isKindOfClass:[NSString class]])
	{
		// for pre 0.9, we supporting removing by passing the annotation title
		NSString *title = [TiUtils stringValue:args];
		for (id<MKAnnotation>an in self.customAnnotations)
		{
			if ([title isEqualToString:an.title])
			{
				doomedAnnotation = an;
				break;
			}
		}
	}
	else if ([args isKindOfClass:[TiMapAnnotationProxy class]])
	{
		doomedAnnotation = args;
	}
    
	[[self map] removeAnnotation:doomedAnnotation];
}

-(void)removeAnnotations:(id)args
{
	ENSURE_TYPE(args,NSArray); // assumes an array of TiMapAnnotationProxy classes
	ENSURE_UI_THREAD(removeAnnotations,args);
	[[self map] removeAnnotations:args];
}

-(void)removeAllAnnotations:(id)args
{
	ENSURE_UI_THREAD(removeAllAnnotations,args);
	[self.map removeAnnotations:self.customAnnotations];
}

-(void)setAnnotations_:(id)value
{
	ENSURE_TYPE_OR_NIL(value,NSArray);
	ENSURE_UI_THREAD(setAnnotations_,value)
	[self.map removeAnnotations:self.customAnnotations];
	if (value != nil) {
		[[self map] addAnnotations:[self annotationsFromArgs:value]];
	}
}


-(void)setSelectedAnnotation:(id<MKAnnotation>)annotation
{
    hitAnnotation = annotation;
    hitSelect = NO;
    manualSelect = YES;
    [[self map] selectAnnotation:annotation animated:animate];
}

-(void)selectAnnotation:(id)args
{
	ENSURE_SINGLE_ARG_OR_NIL(args,NSObject);
	ENSURE_UI_THREAD(selectAnnotation,args);
    
	if (args == nil) {
		for (id<MKAnnotation> annotation in [[self map] selectedAnnotations]) {
			hitAnnotation = annotation;
			hitSelect = NO;
			manualSelect = YES;
			[[self map] deselectAnnotation:annotation animated:animate];
		}
		return;
	}
    
	if ([args isKindOfClass:[NSString class]])
	{
		// for pre 0.9, we supported selecting by passing the annotation title
		NSString *title = [TiUtils stringValue:args];
		for (id<MKAnnotation>an in [NSArray arrayWithArray:[self map].annotations])
		{
			if ([title isEqualToString:an.title])
			{
				// TODO: Slide the view over to the selected annotation, and/or zoom so it's with all other selected.
				[self setSelectedAnnotation:an];
				break;
			}
		}
	}
	else if ([args isKindOfClass:[TiMapAnnotationProxy class]])
	{
		[self setSelectedAnnotation:args];
	}
}

-(void)deselectAnnotation:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(deselectAnnotation,args);
    
	if ([args isKindOfClass:[NSString class]])
	{
		// for pre 0.9, we supporting selecting by passing the annotation title
		NSString *title = [TiUtils stringValue:args];
		for (id<MKAnnotation>an in [NSArray arrayWithArray:[self map].annotations])
		{
			if ([title isEqualToString:an.title])
			{
				[[self map] deselectAnnotation:an animated:animate];
				break;
			}
		}
	}
	else if ([args isKindOfClass:[TiMapAnnotationProxy class]])
	{
		[[self map] deselectAnnotation:args animated:animate];
	}
}

-(void)zoom:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(zoom,args);
    
	double v = [TiUtils doubleValue:args];
	// TODO: Find a good delta tolerance value to deal with floating point goofs
	if (v == 0.0) {
		return;
	}
	MKCoordinateRegion _region = [[self map] region];
	// TODO: Adjust zoom factor based on v
	if (v > 0)
	{
		_region.span.latitudeDelta = _region.span.latitudeDelta / 2.0002;
		_region.span.longitudeDelta = _region.span.longitudeDelta / 2.0002;
	}
	else
	{
		_region.span.latitudeDelta = _region.span.latitudeDelta * 2.0002;
		_region.span.longitudeDelta = _region.span.longitudeDelta * 2.0002;
	}
	region = _region;
	[self render];
}

-(MKCoordinateRegion)regionFromDict:(NSDictionary*)dict
{
	CGFloat latitudeDelta = [TiUtils floatValue:@"latitudeDelta" properties:dict];
	CGFloat longitudeDelta = [TiUtils floatValue:@"longitudeDelta" properties:dict];
	CLLocationCoordinate2D center;
	center.latitude = [TiUtils floatValue:@"latitude" properties:dict];
	center.longitude = [TiUtils floatValue:@"longitude" properties:dict];
	MKCoordinateRegion region_;
	MKCoordinateSpan span;
	span.longitudeDelta = longitudeDelta;
	span.latitudeDelta = latitudeDelta;
	region_.center = center;
	region_.span = span;
	return region_;
}

-(CLLocationDegrees) longitudeDelta
{
    if (loaded) {
        MKCoordinateRegion _region = [[self map] region];
        return _region.span.longitudeDelta;
    }
    return 0.0;
}

-(CLLocationDegrees) latitudeDelta
{
    if (loaded) {
        MKCoordinateRegion _region = [[self map] region];
        return _region.span.latitudeDelta;
    }
    return 0.0;
}


#pragma mark Public APIs

-(void)setMapType_:(id)value
{
	[[self map] setMapType:[TiUtils intValue:value]];
}

-(void)setRegion_:(id)value
{
	if (value==nil)
	{
		// unset the region and set it back to the user's location of the map
		// what else to do??
		MKUserLocation* user = [self map].userLocation;
		if (user!=nil)
		{
			region.center = user.location.coordinate;
			[self render];
		}
		else
		{
			// if we unset but we're not allowed to get the users location, what to do?
		}
	}
	else
	{
		region = [self regionFromDict:value];
		[self render];
	}
}

-(void)setAnimate_:(id)value
{
	animate = [TiUtils boolValue:value];
}

-(void)setRegionFit_:(id)value
{
    regionFits = [TiUtils boolValue:value];
    [self render];
}

-(void)setUserLocation_:(id)value
{
	ENSURE_SINGLE_ARG(value,NSObject);
	[self map].showsUserLocation = [TiUtils boolValue:value];
}

-(void)setLocation_:(id)location
{
	ENSURE_SINGLE_ARG(location,NSDictionary);
	//comes in like region: {latitude:100, longitude:100, latitudeDelta:0.5, longitudeDelta:0.5}
	id lat = [location objectForKey:@"latitude"];
	id lon = [location objectForKey:@"longitude"];
	id latdelta = [location objectForKey:@"latitudeDelta"];
	id londelta = [location objectForKey:@"longitudeDelta"];
	if (lat)
	{
		region.center.latitude = [lat doubleValue];
	}
	if (lon)
	{
		region.center.longitude = [lon doubleValue];
	}
	if (latdelta)
	{
		region.span.latitudeDelta = [latdelta doubleValue];
	}
	if (londelta)
	{
		region.span.longitudeDelta = [londelta doubleValue];
	}
	id an = [location objectForKey:@"animate"];
	if (an)
	{
		animate = [an boolValue];
	}
	id rf = [location objectForKey:@"regionFit"];
	if (rf)
	{
		regionFits = [rf boolValue];
	}
	[self render];
}

-(void)addRoute:(id)args
{
	// process args
    ENSURE_DICT(args);
    
	NSArray *points = [args objectForKey:@"points"];
	if (!points) {
		[self throwException:@"missing required points key" subreason:nil location:CODELOCATION];
	}
    if (![points count]) {
		[self throwException:@"missing required points data" subreason:nil location:CODELOCATION];
    }
	NSString *name = [TiUtils stringValue:@"name" properties:args];
	if (!name) {
		[self throwException:@"missing required name key" subreason:nil location:CODELOCATION];
	}
    TiColor* color = [TiUtils colorValue:@"color" properties:args];
    float width = [TiUtils floatValue:@"width" properties:args def:2];
    
    // construct the MKPolyline
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * [points count]);
    for (int i = 0; i < [points count]; ++i) {
        NSDictionary* entry = [points objectAtIndex:i];
        CLLocationDegrees lat = [TiUtils doubleValue:[entry objectForKey:@"latitude"]];
        CLLocationDegrees lon = [TiUtils doubleValue:[entry objectForKey:@"longitude"]];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
        MKMapPoint pt = MKMapPointForCoordinate(coord);
        pointArray[i] = pt;
    }
    MKPolyline* routeLine = [[MKPolyline polylineWithPoints:pointArray count:[points count]] autorelease];
    free(pointArray);
    
	// construct the MKPolylineView
    MKPolylineView* routeView = [[MKPolylineView alloc] initWithPolyline:routeLine];
    routeView.fillColor = routeView.strokeColor = color ? [color _color] : [UIColor blueColor];
    routeView.lineWidth = width;
    
    // update our mappings
    CFDictionaryAddValue(mapName2Line, name, routeLine);
    CFDictionaryAddValue(mapLine2View, routeLine, routeView);
    // finally add our new overlay
    [map addOverlay:routeLine];
}

-(void)removeRoute:(id)args
{
    ENSURE_DICT(args);
    NSString* name = [TiUtils stringValue:@"name" properties:args];
	if (!name) {
		[self throwException:@"missing required name key" subreason:nil location:CODELOCATION];
	}
    
    MKPolyline* routeLine = (MKPolyline*)CFDictionaryGetValue(mapName2Line, name);
    if (routeLine) {
        CFDictionaryRemoveValue(mapLine2View, routeLine);
        CFDictionaryRemoveValue(mapName2Line, name);
        [map removeOverlay:routeLine];
    }
}


#pragma mark Delegates

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [self prepareOverlayForPresentation:overlay];
    
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	if ([self.proxy _hasListeners:@"regionChanged"])
	{	//TODO: Deprecate old event
		region = [mapView region];
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
								@"regionChanged",@"type",
								[NSNumber numberWithDouble:region.center.latitude],@"latitude",
								[NSNumber numberWithDouble:region.center.longitude],@"longitude",
								[NSNumber numberWithDouble:region.span.latitudeDelta],@"latitudeDelta",
								[NSNumber numberWithDouble:region.span.longitudeDelta],@"longitudeDelta",nil];
		[self.proxy fireEvent:@"regionChanged" withObject:props];
	}
	if ([self.proxy _hasListeners:@"regionchanged"])
	{
		region = [mapView region];
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
								@"regionchanged",@"type",
								[NSNumber numberWithDouble:region.center.latitude],@"latitude",
								[NSNumber numberWithDouble:region.center.longitude],@"longitude",
								[NSNumber numberWithDouble:region.span.latitudeDelta],@"latitudeDelta",
								[NSNumber numberWithDouble:region.span.longitudeDelta],@"longitudeDelta",nil];
		[self.proxy fireEvent:@"regionchanged" withObject:props];
	}
    
    //TODO:Remove all this code when we drop support for iOS 4.X
    
    //SELECT ANNOTATION WILL NOT ALWAYS WORK IF THE MAPVIEW IS ANIMATING.
    //THIS FORCES A RESELCTION OF THE ANNOTATIONS WITHOUT SENDING OUT EVENTS
    //SEE TIMOB-8431 (IOS 4.3)
    ignoreClicks = YES;
    NSArray* currentSelectedAnnotations = [[mapView selectedAnnotations] retain];
    for (id annotation in currentSelectedAnnotations) {
        //Only Annotations that are hidden at this point should be
        //made visible here.
        if ([mapView viewForAnnotation:annotation].hidden) {
            [mapView deselectAnnotation:annotation animated:NO];
            [mapView selectAnnotation:annotation animated:NO];
        }
    }
    [currentSelectedAnnotations release];
    ignoreClicks = NO;
    
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	loaded = NO;
	if ([self.proxy _hasListeners:@"loading"])
	{
		[self.proxy fireEvent:@"loading" withObject:nil];
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	ignoreClicks = YES;
	loaded = YES;
	if ([self.proxy _hasListeners:@"complete"])
	{
		[self.proxy fireEvent:@"complete" withObject:nil];
	}
	ignoreClicks = NO;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	if ([self.proxy _hasListeners:@"error"])
	{
		NSDictionary *event = [NSDictionary dictionaryWithObject:[error description] forKey:@"message"];
		[self.proxy fireEvent:@"error" withObject:event];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	[map addAnnotation:placemark];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	[self firePinChangeDragState:annotationView newState:newState fromOldState:oldState];
}

- (void)firePinChangeDragState:(MKAnnotationView *) pinview newState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	TiMapAnnotationProxy *viewProxy = [self proxyForAnnotation:pinview];
    
	if (viewProxy == nil)
		return;
    
	TiProxy * ourProxy = [self proxy];
	BOOL parentWants = [ourProxy _hasListeners:@"pinchangedragstate"];
	BOOL viewWants = [viewProxy _hasListeners:@"pinchangedragstate"];
    
	if(!parentWants && !viewWants)
		return;
    
	id title = [viewProxy title];
	if (title == nil)
		title = [NSNull null];
    
	NSNumber * indexNumber = NUMINT([pinview tag]);
    
	NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
                            viewProxy,@"annotation",
                            ourProxy,@"map",
                            title,@"title",
                            indexNumber,@"index",
                            NUMINT(newState),@"newState",
                            NUMINT(oldState),@"oldState",
                            nil];
    
	if (parentWants)
		[ourProxy fireEvent:@"pinchangedragstate" withObject:event];
    
	if (viewWants)
		[viewProxy fireEvent:@"pinchangedragstate" withObject:event];
}

- (TiMapAnnotationProxy*)proxyForAnnotation:(MKAnnotationView*)pinview
{
	for (id annotation in [map annotations])
	{
		if ([annotation isKindOfClass:[TiMapAnnotationProxy class]])
		{
			if ([annotation tag] == pinview.tag)
			{
				return annotation;
			}
		}
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	if ([view conformsToProtocol:@protocol(TiMapAnnotation)])
	{
		BOOL isSelected = [view isSelected];
		MKAnnotationView<TiMapAnnotation> *ann = (MKAnnotationView<TiMapAnnotation> *)view;
		[self fireClickEvent:view source:isSelected?@"pin":[ann lastHitName]];
		manualSelect = NO;
		hitSelect = NO;
		return;
	}
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
	if ([view conformsToProtocol:@protocol(TiMapAnnotation)])
	{
		BOOL isSelected = [view isSelected];
		MKAnnotationView<TiMapAnnotation> *ann = (MKAnnotationView<TiMapAnnotation> *)view;
		[self fireClickEvent:view source:isSelected?@"pin":[ann lastHitName]];
		manualSelect = NO;
		hitSelect = NO;
		return;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aview calloutAccessoryControlTapped:(UIControl *)control
{
	if ([aview conformsToProtocol:@protocol(TiMapAnnotation)])
	{
		MKPinAnnotationView *pinview = (MKPinAnnotationView*)aview;
		NSString * clickSource = @"unknown";
		if (aview.leftCalloutAccessoryView == control)
		{
			clickSource = @"leftButton";
		}
		else if (aview.rightCalloutAccessoryView == control)
		{
			clickSource = @"rightButton";
		}
		[self fireClickEvent:pinview source:clickSource];
	}
}


// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[TiMapAnnotationProxy class]])
	{
		TiMapAnnotationProxy *ann = (TiMapAnnotationProxy*)annotation;
        id imagePath = [ann valueForUndefinedKey:@"image"];
        UIImage *image = [TiUtils image:imagePath proxy:ann];
        NSString *identifier = (image!=nil) ? @"timap-image":@"timap-pin";
		MKAnnotationView *annView = nil;
        
		annView = (MKAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annView==nil)
        {
            if ([identifier isEqualToString:@"timap-image"])
            {
                annView=[[[TiMapImageAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier map:((TiMapView*)self) image:image] autorelease];
            }
            else
            {
                annView=[[[TiMapPinAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier map:((TiMapView*)self)] autorelease];
            }
        }
        if ([identifier isEqualToString:@"timap-image"])
        {
            annView.image = image;
        }
        else
		{
			MKPinAnnotationView *pinview = (MKPinAnnotationView*)annView;
			pinview.pinColor = [ann pinColor];
			pinview.animatesDrop = [ann animatesDrop] && ![(TiMapAnnotationProxy *)annotation placed];
			annView.calloutOffset = CGPointMake(-8, 0);
		}
		annView.canShowCallout = YES;
		annView.enabled = YES;
		UIView *left = [ann leftViewAccessory];
		UIView *right = [ann rightViewAccessory];
		if (left!=nil)
		{
			annView.leftCalloutAccessoryView = left;
		}
		if (right!=nil)
		{
			annView.rightCalloutAccessoryView = right;
		}
        
		BOOL draggable = [TiUtils boolValue: [ann valueForUndefinedKey:@"draggable"]];
		if (draggable && [[MKAnnotationView class] instancesRespondToSelector:NSSelectorFromString(@"isDraggable")])
			[annView performSelector:NSSelectorFromString(@"setDraggable:") withObject:[NSNumber numberWithBool:YES]];
        
		annView.userInteractionEnabled = YES;
		annView.tag = [ann tag];
		return annView;
	}
	return nil;
}


// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView<TiMapAnnotation> *thisView in views)
	{
		if(![thisView conformsToProtocol:@protocol(TiMapAnnotation)])
		{
			return;
		}
        /*Image Annotation don't have any animation of its own.
         *So in this case we do a custom animation, to place the
         *image annotation on top of the mapview.*/
        if([thisView isKindOfClass:[TiMapImageAnnotationView class]])
        {
            TiMapAnnotationProxy *anntProxy = [self proxyForAnnotation:thisView];
            if([anntProxy animatesDrop] && ![anntProxy placed])
            {
                CGRect viewFrame = thisView.frame;
                thisView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y - self.frame.size.height, viewFrame.size.width, viewFrame.size.height);
                [UIView animateWithDuration:0.4
                                      delay:0.0
                                    options:UIViewAnimationCurveEaseOut
                                 animations:^{thisView.frame = viewFrame;}
                                 completion:nil];
            }
        }
		TiMapAnnotationProxy * thisProxy = [self proxyForAnnotation:thisView];
		[thisProxy setPlaced:YES];
	}
}

#pragma mark Click detection

-(id<MKAnnotation>)wasHitOnAnnotation:(CGPoint)point inView:(UIView*)view
{
	id<MKAnnotation> result = nil;
	for (UIView* subview in [view subviews]) {
		if (![subview pointInside:[self convertPoint:point toView:subview] withEvent:nil]) {
			continue;
		}
        
		if ([subview isKindOfClass:[MKAnnotationView class]]) {
			result = [(MKAnnotationView*)subview annotation];
		}
		else {
			result = [self wasHitOnAnnotation:point inView:subview];
		}
        
		if (result != nil) {
			break;
		}
	}
	return result;
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* result = [super hitTest:point withEvent:event];
	if (result != nil) {
		// OK, we hit something - if the result is an annotation... (3.2+)
		if ([result isKindOfClass:[MKAnnotationView class]]) {
			hitAnnotation = [(MKAnnotationView*)result annotation];
		} else {
			hitAnnotation = nil;
		}
	} else {
		hitAnnotation = nil;
	}
	hitSelect = YES;
	manualSelect = NO;
	return result;
}

#pragma mark Event generation

- (void)fireClickEvent:(MKAnnotationView *) pinview source:(NSString *)source
{
	if (ignoreClicks)
	{
		return;
	}
    
	TiMapAnnotationProxy *viewProxy = [self proxyForAnnotation:pinview];
	if (viewProxy == nil)
	{
		return;
	}
    
	TiProxy * ourProxy = [self proxy];
	BOOL parentWants = [ourProxy _hasListeners:@"click"];
	BOOL viewWants = [viewProxy _hasListeners:@"click"];
	if(!parentWants && !viewWants)
	{
		return;
	}
    
	id title = [viewProxy title];
	if (title == nil)
	{
		title = [NSNull null];
	}
    
	NSNumber * indexNumber = NUMINT([pinview tag]);
	id clicksource = source ? source : (id)[NSNull null];
    
	NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
                            clicksource,@"clicksource",	viewProxy,@"annotation",	ourProxy,@"map",
                            title,@"title",			indexNumber,@"index",		nil];
    
	if (parentWants)
	{
		[ourProxy fireEvent:@"click" withObject:event];
	}
	if (viewWants)
	{
		[viewProxy fireEvent:@"click" withObject:event];
	}
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//
//      Updating the code yourself?  Here are some helpful notes.
//
//
//      You need to alter the below deligates
//          - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
//
//      You need to alter the below Methods
//          Add the following lines to the dealloc method
//
//          if(polygonOverlays!=nil)
//          {
//              RELEASE_TO_NIL(polygonOverlays);
//          }
//          if(circleOverlays!=nil)
//          {
//              RELEASE_TO_NIL(circleOverlays);
//          }
//
//
//      Don't forget to copy from here to the end, this should be the easy part
//
//      After you copy, you will need to run Analyze to pick-up on type conversion issues
//
//////////////////////////////////////////////////////////////////////////////////////////////////

//http://compileyouidontevenknowyou.blogspot.com/2010/06/random-colors-in-objective-c.html
- (UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

//-(void) addPolygonTouch
//{
//    tapInterceptor = [[WildcardGestureRecognizer alloc] init];
//    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:self.map];
//
//        CLLocationCoordinate2D coord = [self.map convertPoint:point toCoordinateFromView:self.map];
//        MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
//        for (id overlay in self.map.overlays)
//        {
//            if ([overlay isKindOfClass:[MKPolygon class]])
//            {
//                MKPolygon *poly = (MKPolygon*) overlay;
//                id view = [self.map viewForOverlay:poly];
//                if ([view isKindOfClass:[MKPolygonView class]])
//                {
//                    MKPolygonView *polyView = (MKPolygonView*) view;
//                    CGPoint polygonViewPoint = [polyView pointForMapPoint:mapPoint];
//                    BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(polyView.path, NULL, polygonViewPoint, NO);
//                    if (mapCoordinateIsInPolygon) {
//                        if (([self.proxy _hasListeners:@"polygonClick"]) && (poly.title!=nil))
//                        {
//                            NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                    @"polygon",@"clicksource",
//                                                    poly.title,@"title", nil];
//                            [self.proxy fireEvent:@"polygonClick" withObject:event];
//
//                        }
//                        break;
//                    }
//                }
//            }
//        }
//
//    };
//    [self.map addGestureRecognizer:tapInterceptor];
//    polygonClickListenerAdded=YES;
//}
//
//-(void)setPolygonTouchTracking_:(id)value
//{
//    BOOL touchCommand = [TiUtils boolValue:value];
//
//    if((polygonClickListenerAdded==NO)&&(touchCommand))
//    {
//        [self addPolygonTouch];
//    }
//    if((polygonClickListenerAdded)&&(touchCommand==NO))
//    {
//       [self.map removeGestureRecognizer:tapInterceptor];
//        polygonClickListenerAdded=NO;
//    }
//}

- (MKOverlayView *)prepareOverlayForPresentation:(id <MKOverlay>)overlay
{
    @try {
        //NSLog(@"overlay type %@",NSStringFromClass ([overlay class]));
        if ([overlay isKindOfClass:[MKPolygon class]])
        {
            MKPolygonView *polygonView = [[[MKPolygonView alloc] initWithPolygon:overlay] autorelease];
            if ([overlay respondsToSelector:@selector(color)])
            {
                MKPolygon* temp =(MKPolygon*)overlay;
                if(temp.color==nil)
                {
                    polygonView.fillColor = [UIColor greenColor];
                }
                else
                {
                    polygonView.fillColor=temp.color;
                }
                if(temp.strokeColor!=nil)
                {
                    polygonView.strokeColor=temp.strokeColor;
                }
                polygonView.alpha=[temp.alpha floatValue];
                polygonView.lineWidth=[temp.lineWidth floatValue];
            }
            
            return polygonView;
        }
        else if ([overlay isKindOfClass:[MKCircle class]])
        {
            MKCircleView *cirlceView = [[[MKCircleView alloc] initWithCircle:overlay] autorelease];
            MKCircle* temp =(MKCircle*)overlay;
            if(temp.color==nil)
            {
                cirlceView.fillColor = [UIColor greenColor];
            }
            else
            {
                cirlceView.fillColor=temp.color;
            }
            if(temp.strokeColor!=nil)
            {
                cirlceView.strokeColor=temp.strokeColor;
            }
            cirlceView.alpha=[temp.alpha floatValue];
            cirlceView.lineWidth=[temp.lineWidth floatValue];
            
            return cirlceView;
        }
        else if ([overlay isKindOfClass:[MKPolyline class]])
        {
            return (MKOverlayView *)CFDictionaryGetValue(mapLine2View, overlay);
        }
        else if ([overlay isKindOfClass:[BBSquareImageOverlay class]])
        {
            BBSquareImageOverlay *mapOverlay = (BBSquareImageOverlay *)overlay;
            
            BBSquareImageOverlayView *mapOverlayView =
            [[[BBSquareImageOverlayView alloc] initWithOverlay:mapOverlay] autorelease];
            
            if(mapOverlay.imagePath!=nil)
            {
                mapOverlayView.ImagePath=mapOverlay.imagePath;
            }
            else
            {
                if(mapOverlay.color==nil)
                {
                    mapOverlayView.backgroundColor = [UIColor yellowColor];
                }
                else
                {
                    mapOverlayView.backgroundColor=mapOverlay.color;
                }
            }
            mapOverlayView.alpha=[mapOverlay.alpha floatValue];
            return mapOverlayView;
        }
        else if ([overlay isKindOfClass:[TileOverlay class]])
        {
            TileOverlay *tileOverlay = (TileOverlay *)overlay;
            TileOverlayView *tileOverlayView = [[[TileOverlayView alloc] initWithOverlay:overlay] autorelease];
            tileOverlayView.tileAlpha = 1.0;
            return tileOverlayView;
        }
        else
        {
            return nil;
        }
    }
    @catch (id theException) {
		NSLog(@"%@", theException);
        return nil;
	}
}
-(void) ImageOverlayQueryToRemoveByTitle:(NSString*)filter
{
    ENSURE_UI_THREAD(ImageOverlayQueryToRemoveByTitle,filter);
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[BBSquareImageOverlay class]])
        {
            //We match on title, not the best, but the easiest approach
            if ([overlay.title isEqualToString: filter])
            {
                [[self map] removeOverlay:overlay];
            }
        }
    }
}
-(void) ImageOverlayQueryToRemoveByTag:(int)filter
{
    ENSURE_UI_THREAD(ImageOverlayQueryToRemoveByTag,filter);
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[BBSquareImageOverlay class]])
        {
            //We match on title, not the best, but the easiest approach
            if (((BBSquareImageOverlay*)overlay).tag == filter)
            {
                [[self map] removeOverlay:overlay];
            }
        }
    }
}
-(void)removeImageOverlay:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(removeImageOverlay,args);
    //Fetch our name we will be trying to remove
    if([args objectForKey:@"tag"]==[NSNull null])
    {
        NSString *filter = [TiUtils stringValue:@"title" properties:args];
        [self ImageOverlayQueryToRemoveByTitle:filter];
    }
    else
    {
        int tagId =[TiUtils intValue:@"tag" properties:args def:-222222];
        [self ImageOverlayQueryToRemoveByTag:tagId];
    }
}
-(void)removeAllImageOverlays:(id)arg
{
	ENSURE_UI_THREAD(removeAllImageOverlays,arg);
    
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[BBSquareImageOverlay class]])
        {
            [[self map] removeOverlay:overlay];
        }
    }
    
}

-(BBSquareImageOverlay*) BuildImageOverlayFromCoordinates:(NSDictionary*)args withHasCoordBox:(BOOL)hasCoordBox withHasSizedBox:(BOOL)hasSizedBox
{    
    @try
    {

//        NSLog(@"hasCoordBox %@",(hasCoordBox ? @"YES" : @"NO"));
//        NSLog(@"hasSizedBox %@",(hasSizedBox ? @"YES" : @"NO"));
        
        if(hasCoordBox==YES)
        {
            //Convert the points into something useful
            NSDictionary *boxInfo = [args objectForKey:@"coordBox"];
            NSDictionary *coords = [boxInfo objectForKey:@"coords"];
            NSDictionary *upperRight = [coords objectForKey:@"upperRight"];
            NSDictionary *bottomLeft = [coords objectForKey:@"bottomLeft"];
            
            CLLocationCoordinate2D  upperRightCoords = CLLocationCoordinate2DMake(
                                                                                  [TiUtils floatValue:@"latitude" properties:upperRight def:0.0],
                                                                                  [TiUtils floatValue:@"longitude" properties:upperRight def:0.0]
                                                                                  );
            CLLocationCoordinate2D  bottomLeftCoords = CLLocationCoordinate2DMake(
                                                                                  [TiUtils floatValue:@"latitude" properties:bottomLeft def:0.0],
                                                                                  [TiUtils floatValue:@"longitude" properties:bottomLeft def:0.0]
                                                                                  );
            BBSquareImageOverlay* imgOverlay =[[[BBSquareImageOverlay alloc] initWithCoordinates:upperRightCoords
                                                                         withLowerLeftCoordinate:bottomLeftCoords] autorelease];
            return imgOverlay;
        }
        
        if(hasSizedBox==YES)
        {
            //Convert the points into something useful
            NSDictionary *sizedBox = [args objectForKey:@"sizedBox"];
            NSDictionary *coords = [sizedBox objectForKey:@"coords"];
            NSDictionary *upperRight = [coords objectForKey:@"upperRight"];

            //Create the number of points provided
            CLLocationCoordinate2D  upperRightCoords = CLLocationCoordinate2DMake(
                                                                                  [TiUtils floatValue:@"latitude" properties:upperRight def:0.0],
                                                                                  [TiUtils floatValue:@"longitude" properties:upperRight def:0.0]
                                                                                  );

            float cellSizeLatitude = [TiUtils floatValue:@"cellSizeLat" properties:sizedBox def:0.001];
            float cellSizeLongitude = [TiUtils floatValue:@"cellSizeLng" properties:sizedBox def:0.001];

            CLLocationCoordinate2D bottomLeft = CLLocationCoordinate2DMake((upperRightCoords.latitude - cellSizeLatitude),
                                                                           (upperRightCoords.longitude - cellSizeLongitude));
            
            BBSquareImageOverlay* imgOverlay =[[[BBSquareImageOverlay alloc] initWithCoordinates:upperRightCoords
                                                                         withLowerLeftCoordinate:bottomLeft] autorelease];
            return imgOverlay;
        }
    }
    @catch (id theException) {
        NSLog(@"BuildImageOverlayFromCoordinates %@", theException);
        return nil;
    }
}

-(void)addImageOverlay:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(addImageOverlay,args);
    
    BOOL hasCoordBox = (([args valueForKey:@"coordBox"]!=nil) ? YES : NO);
    BOOL hasSizedBox = (([args valueForKey:@"sizedBox"]!=nil) ? YES : NO);
    
    if((hasCoordBox==NO) && (hasSizedBox==NO))
    {
        NSLog(@"not values provided for coordBox or center. One of these properties need to be set to continue");
        return;
    }

    //Build Overlay
    BBSquareImageOverlay* imgOverlay = [self BuildImageOverlayFromCoordinates:args withHasCoordBox:hasCoordBox withHasSizedBox:hasSizedBox];
    
    NSString *imgPath = [TiUtils stringValue:@"image" properties:args];
    
    if(imgPath==nil)
    {
        NSLog(@"No image provided unable to continue adding overlay");
        return;
    }

    //Get the alpha, if not provided default to 0.9
    float alpha = [TiUtils floatValue:@"alpha" properties:args def:0.9];
    imgOverlay.alpha=[NSNumber numberWithFloat:alpha];
    
    NSURL* filePath = [TiUtils toURL:imgPath proxy:self.proxy];
    NSString* pathToAdd = [filePath path];
    NSLog(@"adding path %@", pathToAdd);

    //Add image path
    imgOverlay.imagePath=pathToAdd;
    
    //Get the title for the overlay
    NSString *overlayTitle = [TiUtils stringValue:@"title" properties:args];
    imgOverlay.title=overlayTitle;
    
    //Get tagId for overlay
    int tagId = [TiUtils intValue:@"tag" properties:args def:kTagIdValue];
    imgOverlay.tag=tagId;
    
    [[self map] addOverlay:imgOverlay];

}

-(void)setTileOverlay:(id)arg{
    
    ENSURE_TYPE(arg,NSString);
	ENSURE_UI_THREAD(setTileOverlay,arg);
    
    [self removeTileOverlay:nil];

    
    NSURL* filePath = [TiUtils toURL:arg proxy:self.proxy];
    NSString* tileDirectory = [filePath path];
    TileOverlay *tileOverlay = [[[TileOverlay alloc] initWithTileDirectory:tileDirectory] autorelease];
    [[self map] addOverlay:tileOverlay];
    
}

-(void)removeTileOverlay:(id)arg
{
    //Remove any other tile overlays from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about TileOverlays
        if ([overlay isKindOfClass:[TileOverlay class]])
        {
            [[self map] removeOverlay:overlay];
        }
    }
}

-(void)removeAllCircles:(id)arg
{
	ENSURE_UI_THREAD(removeAllCircles,arg);
    
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[MKCircle class]])
        {
            [[self map] removeOverlay:overlay];
        }
    }
    
}
-(void) cirleQueryToRemoveByTitle:(NSString*)filter
{
    ENSURE_UI_THREAD(cirleQueryToRemoveByTitle,filter);
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[MKCircle class]])
        {
            //We match on title, not the best, but the easiest approach
            if ([overlay.title isEqualToString: filter])
            {
                [[self map] removeOverlay:overlay];
            }
        }
    }
}
-(void) cirleQueryToRemoveByTag:(int)filter
{
    ENSURE_UI_THREAD(cirleQueryToRemoveByTag,filter);
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[MKCircle class]])
        {
            //We match on title, not the best, but the easiest approach
            if (((MKCircle*)overlay).tag == filter)
            {
                [[self map] removeOverlay:overlay];
            }
        }
    }
}
-(void)removeCircle:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(removeCircle,args);
    //Fetch our name we will be trying to remove
    if([args objectForKey:@"tag"]==[NSNull null])
    {
        NSString *filter = [TiUtils stringValue:@"title" properties:args];
        [self cirleQueryToRemoveByTitle:filter];
    }
    else
    {
        int tagId =[TiUtils intValue:@"tag" properties:args def:-222222];
        [self cirleQueryToRemoveByTag:tagId];
    }
}
-(void)addCircle:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(addCircle,args);
    
    //Get the title for the polygon
    NSString *circleTitle = [TiUtils stringValue:@"title" properties:args];
    
    
    //Create the number of points provided
    CLLocationCoordinate2D  coords = CLLocationCoordinate2DMake(
                                                                [TiUtils floatValue:@"latitude" properties:args def:0.0],
                                                                [TiUtils floatValue:@"longitude" properties:args def:0.0]
                                                                );
    
    //Get the radius for the circle in meters, if not provided default to 100 meters
    float circleRadius = [TiUtils floatValue:@"radius" properties:args def:100];
    
    //Create our circle
    MKCircle* circleToAdd = [MKCircle circleWithCenterCoordinate:coords radius:circleRadius];
    circleToAdd.title = circleTitle;
    // Check if we're using a random color (false by default)
    BOOL useRandomColor =[TiUtils boolValue:@"useRandomColor" properties:args def:NO];
    UIColor * circleColor = [[TiUtils colorValue:@"color" properties:args] _color];
    if ((circleColor == nil)||(useRandomColor))
    {
        circleColor=[self randomColor];
    }
    circleToAdd.color=circleColor;
    
    //Get the alpha, if not provided default to 0.9
    float alpha = [TiUtils floatValue:@"alpha" properties:args def:0.9];
    circleToAdd.alpha=[NSNumber numberWithFloat:alpha];
    //Get our lineWidth, if not provoded default to 1.0
    float lineWidth = [TiUtils floatValue:@"lineWidth" properties:args def:1.0];
    circleToAdd.lineWidth=[NSNumber numberWithFloat:lineWidth];
    //Get the optional strokeColor
    UIColor * strokeColor = [[TiUtils colorValue:@"strokeColor" properties:args] _color];
    //We only add the strokeColor if it is provided
    if (strokeColor != nil)
    {
        circleToAdd.strokeColor=strokeColor;
    }
    //Get tagId for overlay
    int tagId = [TiUtils intValue:@"tag" properties:args def:kTagIdValue];
    circleToAdd.tag=tagId;
    
    //Add the circle to the map
    [[self map] addOverlay:circleToAdd];
    
}

-(void)removeAllPolygons:(id)arg
{
	ENSURE_UI_THREAD(removeAllPolygons,arg);
    
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[MKPolygon class]])
        {
            [[self map] removeOverlay:overlay];
        }
    }
}
-(void) clear:(id)unused
{
    ENSURE_UI_THREAD(clear,unused);
    
    //Remove all overlays
    for (id <MKOverlay> overlay in [self map].overlays) {
        [[self map] removeOverlay:overlay];
    }
    
    //Remove all annotations
    [self removeAllAnnotations:unused];
    
}
-(void) polygonQueryToRemoveByTitle:(NSString*)filter
{
    ENSURE_UI_THREAD(polygonQueryToRemoveByTitle,filter);
    //NSLog(@"polygonQueryToRemove Filter: %@", filter);
    
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[MKPolygon class]])
        {
            //We match on title, not the best, but the easiest approach
            if ([overlay.title isEqualToString: filter])
            {
                [[self map] removeOverlay:overlay];
            }
        }
    }
}
-(void) polygonQueryToRemoveByTag:(int)filter
{
    ENSURE_UI_THREAD(polygonQueryToRemoveByTag,filter);
    //NSLog(@"polygonQueryToRemove Filter: %@", filter);
    
    //Remove overlay from map
    for (id <MKOverlay> overlay in [self map].overlays) {
        //We only care about polgyons
        if ([overlay isKindOfClass:[MKPolygon class]])
        {
            //We match on title, not the best, but the easiest approach
            if (((MKPolygon*)overlay).tag==filter)
            {
                [[self map] removeOverlay:overlay];
            }
        }
    }
}
-(void)removePolygon:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(removePolygon,args);
    if([args objectForKey:@"tag"]==[NSNull null])
    {
        //Fetch our name we will be trying to remove
        NSString *filter = [TiUtils stringValue:@"title" properties:args];
        [self polygonQueryToRemoveByTitle:filter];
    }else
    {
        int tagId =[TiUtils intValue:@"tag" properties:args def:-222222];
        [self polygonQueryToRemoveByTag:tagId];
    }
}

-(void)addPolygon:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(addPolygon,args);
    
    id pointsValue = [args objectForKey:@"points"];
    
    if(pointsValue==nil)
    {
        NSLog(@"points value is missing, cannot add polygon");
        return;
    }
    //Convert the points into something useful
    NSArray *inputPoints = [NSArray arrayWithArray:pointsValue];
    //Get our counter
    NSUInteger pointsCount = [inputPoints count];
    
    //We need at least one point to do anything
    if(pointsCount==0){
        return;
    }
    
    //Get the title for the polygon
    NSString *polyTitle = [TiUtils stringValue:@"title" properties:args];
    
    //Create the number of points provided
    CLLocationCoordinate2D  points[pointsCount];
    
    //loop through and add coordinates
    for (int iLoop = 0; iLoop < pointsCount; iLoop++) {
        points[iLoop] = CLLocationCoordinate2DMake(
                                                   [TiUtils floatValue:@"latitude" properties:[inputPoints objectAtIndex:iLoop] def:0],
                                                   [TiUtils floatValue:@"longitude" properties:[inputPoints objectAtIndex:iLoop] def:0]);
    }
    //Create our polgyon
    MKPolygon* polygonToAdd = [MKPolygon polygonWithCoordinates:points count:pointsCount];
    polygonToAdd.title = polyTitle;
    
    
    // Check if we're using a random color (false by default)
    BOOL useRandomColor =[TiUtils boolValue:@"useRandomColor" properties:args def:NO];
    UIColor * polyColor = [[TiUtils colorValue:@"color" properties:args] _color];
    if ((polyColor == nil)||(useRandomColor))
    {
        polyColor=[self randomColor];
    }
    polygonToAdd.color=polyColor;
    
    //Get the alpha, if not provided default to 0.9
    float alpha = [TiUtils floatValue:@"alpha" properties:args def:0.9];
    polygonToAdd.alpha=[NSNumber numberWithFloat:alpha];
    
    //Get our lineWidth, if not provoded default to 1.0
    float lineWidth = [TiUtils floatValue:@"lineWidth" properties:args def:1.0];
    polygonToAdd.lineWidth=[NSNumber numberWithFloat:lineWidth];
    
    
    //Get the optional strokeColor
    UIColor * strokeColor = [[TiUtils colorValue:@"strokeColor" properties:args] _color];
    //We only add the strokeColor if it is provided
    if (strokeColor != nil)
    {
        polygonToAdd.strokeColor=strokeColor;
    }
    //Get tagId for overlay
    int tagId = [TiUtils intValue:@"tag" properties:args def:kTagIdValue];
    polygonToAdd.tag=tagId;
    
    //Add the polgyon to the map
    [[self map] addOverlay:polygonToAdd];
    
}

-(void)setUserTrackingMode_:(id)value
{
    if(respondsToMKUserTrackingMode)
    {
        ENSURE_SINGLE_ARG(value,NSDictionary);
        id userTrackingMode = [value objectForKey:@"mode"];
        id animation = [value objectForKey:@"animated"];
        
        [[self map] setUserTrackingMode:[TiUtils intValue:userTrackingMode]  animated:[TiUtils boolValue:animation]];
    }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if(respondsToMKUserTrackingMode){
        if ([self.proxy _hasListeners:@"userTrackingMode"])
        {
            //mode = [mapView userTrackingMode];
            NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"userTrackingMode",@"type",
                                    [NSNumber numberWithInt:mode],@"mode",
                                    nil];
            [self.proxy fireEvent:@"userTrackingMode" withObject:props];
        }
    }
}

-(void)removeKML:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(removeKML,args);
    
    if([args objectForKey:@"tag"]==[NSNull null])
    {
        NSLog(@"tag is required to remove KML upload");
    }
    
    int tagId =[TiUtils intValue:@"tag" properties:args def:-222222];
    
    //Remove all polygons
    [self polygonQueryToRemoveByTag:tagId];
    //Remove all circles
    [self cirleQueryToRemoveByTag:tagId];
    
    //Loop through and remove any annotations we can find with a matching tagId
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.map.annotations];
    [annotations removeObject:self.map.userLocation];
    
    for(TiMapAnnotationProxy* ann in annotations) {
        //NSLog(@"ann tag %i", [ann tag]);
        if([ann tag]==tagId)
        {
            [self removeAnnotation:ann];
        }
    }
}

-(void)addKML:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(addKML,args);
    
    //File path
    NSString* providedPath =[TiUtils stringValue:@"path" properties:args];
    //Determine if we should use FlyTo
    BOOL enableFlyTo =[TiUtils boolValue:@"flyTo" properties:args def:NO];
    
    Class dictClass = [NSDictionary class];
    
    //Obtain the overlay property node
	NSDictionary * overlayInfo = [args objectForKey:@"overlayInfo"];
	ENSURE_CLASS_OR_NIL(overlayInfo,dictClass);
    //Obtain the annotation proerty node
	NSDictionary * annotationInfo = [args objectForKey:@"annotationInfo"];
	ENSURE_CLASS_OR_NIL(annotationInfo,dictClass);
    
    //Figure out our file path
    NSURL* filePath = [TiUtils toURL:providedPath proxy:self.proxy];
    
    //Format our path so we can send it to the parser
    NSURL* kmlPath = [NSURL fileURLWithPath:[filePath path]];
    
    //Tell the parser where the file is we want actioned
    KMLParser *kmlParser = [[[KMLParser alloc] initWithURL:kmlPath] autorelease];
    
    //Parse the KML
    [kmlParser parseKML];
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    
    //Get tagId for overlay
    int tagId = [TiUtils intValue:@"tag" properties:args def:kTagIdValue];
    
    //Check if we should include overlays
    if(overlayInfo!=nil)
    {
        //Get the title for the polygon
        NSString *overlayTitle = [TiUtils stringValue:@"title" properties:overlayInfo];
        
        //Overlay color
        UIColor *overlayColor = [[TiUtils colorValue:@"color" properties:overlayInfo] _color];
        if (overlayColor == nil)
        {
            overlayColor=[self randomColor];
        }
        
        //Get the alpha, if not provided default to 0.9
        float alpha = [TiUtils floatValue:@"alpha" properties:overlayInfo def:0.9];
        //Get our lineWidth, if not provoded default to 1.0
        float lineWidth = [TiUtils floatValue:@"lineWidth" properties:overlayInfo def:1.0];
        
        //Get the optional strokeColor
        UIColor *strokeColor = [[TiUtils colorValue:@"strokeColor" properties:overlayInfo] _color];
        
        // Check if we're using a random color (false by default)
        BOOL useRandomColor =[TiUtils boolValue:@"useRandomColor" properties:overlayInfo def:NO];
        
        NSArray *kmlOverlays = [kmlParser overlays];
        
        for (id <MKOverlay> overlay in kmlOverlays) {
            
            if(enableFlyTo)
            {
                if (MKMapRectIsNull(flyTo)) {
                    flyTo = [overlay boundingMapRect];
                } else {
                    flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
                }
            }
            
            if ([overlay isKindOfClass:[MKPolygon class]])
            {
                if(useRandomColor)
                {
                    overlayColor=[self randomColor];
                }
                
                MKPolygon* temp =(MKPolygon*)overlay;
                temp.title = overlayTitle; //Set the title
                temp.color = overlayColor; //Assign Color
                temp.alpha = [NSNumber numberWithFloat:alpha];
                temp.lineWidth = [NSNumber numberWithFloat:lineWidth];
                temp.tag = tagId;
                
                //We only add the strokeColor if it is provided
                if (strokeColor != nil)
                {
                    temp.strokeColor=strokeColor;
                }
                
                //Add the polgyon to the map
                [[self map] addOverlay:temp];
            }
            
            if ([overlay isKindOfClass:[MKCircle class]])
            {
                MKCircle* temp =(MKCircle*)overlay;
                temp.title = overlayTitle; //Set the title
                temp.color = overlayColor; //Assign Color
                temp.alpha = [NSNumber numberWithFloat:alpha];
                temp.lineWidth = [NSNumber numberWithFloat:lineWidth];
                temp.tag = tagId;
                
                //We only add the strokeColor if it is provided
                if (strokeColor != nil)
                {
                    temp.strokeColor=strokeColor;
                }
                
                //Add the cirlce to the map
                [[self map] addOverlay:temp];
            }
        }
    }
    
    //Check if we should include annotations
    if(annotationInfo!=nil)
    {
        //Find pin color for our annotations
        int pincolor = [TiUtils intValue:@"pincolor" properties:annotationInfo def:MKPinAnnotationColorRed];
        
        NSArray *annotations = [kmlParser points];
        //NSLog(@"annotations count %i",[annotations count]);
        
        for (id <MKAnnotation> annotation in annotations) {
            if(enableFlyTo)
            {
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
                if (MKMapRectIsNull(flyTo)) {
                    flyTo = pointRect;
                } else {
                    flyTo = MKMapRectUnion(flyTo, pointRect);
                }
            }
            
            NSMutableDictionary *details = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithDouble:annotation.coordinate.latitude],@"latitude",
                                            [NSNumber numberWithDouble:annotation.coordinate.longitude],@"longitude",
                                            [NSNumber numberWithInt:tagId],@"tag",
                                            [NSNumber numberWithInt:pincolor],@"pincolor",
                                            nil];
            //Add in the other attributes one at a time to avoid nil issues
            if([annotation title]!=nil)
            {
                [details setObject:[annotation title] forKey:@"title"];
            }
            if([annotation subtitle]!=nil)
            {
                [details setObject:[annotation subtitle] forKey:@"subtitle"];
            }
            
            [self addAnnotation:details];
        }
    }
    
    if(enableFlyTo)
    {
        // Position the map so that all overlays and annotations are visible on screen.
        map.visibleMapRect = flyTo;
    }
    
    //Fire event to tell everyone we're finished
	if ([self.proxy _hasListeners:@"kmlCompleted"])
	{
		[self.proxy fireEvent:@"kmlCompleted" withObject:nil];
	}
    
}

-(void)ZoomOutFull:(id)unused
{
    @try {
        MKMapRect fullRect = MKMapRectMake(map.bounds.origin.x, map.bounds.origin.y,
                                           map.bounds.size.width, map.bounds.size.height);
        map.visibleMapRect = fullRect;
        region = MKCoordinateRegionForMapRect(MKMapRectWorld);
        [map setRegion:region animated:animate];
    }
    @catch (id theException) {
		NSLog(@"ZoomToWorld %@", theException);
        
	}
}

-(void)ZoomToFit:(id)unused
{
    ENSURE_UI_THREAD(ZoomToFit,unused);
    if([map.annotations count] == 0)
        return;
    
    MKMapRect fullRect = MKMapRectMake(map.bounds.origin.x, map.bounds.origin.y,
                                       map.bounds.size.width, map.bounds.size.height);
    map.visibleMapRect = fullRect;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id <MKOverlay> overlay in [self map].overlays) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, overlay.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, overlay.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, overlay.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, overlay.coordinate.latitude);
    }
    
    for (id <MKAnnotation> annotation in [self map].annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [map regionThatFits:region];
    [map setRegion:region animated:YES];
}
@end
