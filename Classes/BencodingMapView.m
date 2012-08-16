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


@implementation BencodingMapView

#pragma mark Internal

bool respondsToMKUserTrackingMode = NO;

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
    if(polygonOverlays!=nil)
    {
        RELEASE_TO_NIL(polygonOverlays);
    }
    if(circleOverlays!=nil)
    {
        RELEASE_TO_NIL(circleOverlays);
    }    
    
	[super dealloc];
}

-(void)render
{
    if (![NSThread isMainThread]) {
        TiThreadPerformOnMainThread(^{[self render];}, NO);
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
    //Remove our polygon cache
    RELEASE_TO_NIL(circleOverlays);
    
}
-(void)removeCircle:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(removeCircle,args);
    //Fetch our name we will be trying to remove
    NSString *filter = [TiUtils stringValue:@"title" properties:args];
    
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
    
    //Remove polygon from collection
    if(circleOverlays!=nil)
    {
        for (ExtCircle *extCircle in circleOverlays) 
        {
            if ([extCircle.Title isEqualToString: filter])
            {
                if([circleOverlays containsObject:extCircle])
                {
                    [circleOverlays removeObject:extCircle];                 
                }
            }
        }
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
    
    UIColor * circleColor = [[TiUtils colorValue:@"color" properties:args] _color];
    if (circleColor == nil)
    {
        circleColor=[UIColor greenColor];
    }
    
    //Get the alpha, if not provided default to 0.9
    float alpha = [TiUtils floatValue:@"alpha" properties:args def:0.9];
    //Get our lineWidth, if not provoded default to 1.0
    float lineWidth = [TiUtils floatValue:@"lineWidth" properties:args def:1.0];
    
    //Build our extension object, so we can format on display
    ExtCircle *newCircle = [[[ExtCircle alloc] 
                               initWithParameters:circleColor 
                               alpha:alpha title:circleTitle 
                               polygon:circleToAdd 
                               linewidth:lineWidth] autorelease];
    
    //Get the optional strokeColor
    UIColor * strokeColor = [[TiUtils colorValue:@"strokeColor" properties:args] _color];
    //We only add the strokeColor if it is provided
    if (strokeColor != nil)
    {
        newCircle.strokeColor=strokeColor;
    }
    
    //If our circle collection isn't create, do so
    if (circleOverlays==nil)
    {
        circleOverlays = [[NSMutableArray alloc] init];
    }
    
    //Add the newly created circle to our collection
    [circleOverlays addObject:newCircle];
    
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
    //Remove our polygon cache
    RELEASE_TO_NIL(polygonOverlays);
    
}
-(void)removePolygon:(id)args
{
	ENSURE_TYPE(args,NSDictionary);
	ENSURE_UI_THREAD(removePolygon,args);
    //Fetch our name we will be trying to remove
    NSString *filter = [TiUtils stringValue:@"title" properties:args];

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
    
    //Remove polygon from collection
    if(polygonOverlays!=nil)
    {
         for (ExtPolygon *pgc in polygonOverlays) 
         {
             if ([pgc.Title isEqualToString: filter])
             {
                 if([polygonOverlays containsObject:pgc])
                 {
                     [polygonOverlays removeObject:pgc];                 
                 }
             }
         }
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
   
    UIColor * polyColor = [[TiUtils colorValue:@"color" properties:args] _color];
    if (polyColor == nil)
    {
        polyColor=[UIColor greenColor];
    }
    
    //Get the alpha, if not provided default to 0.9
    float alpha = [TiUtils floatValue:@"alpha" properties:args def:0.9];
    //Get our lineWidth, if not provoded default to 1.0
    float lineWidth = [TiUtils floatValue:@"lineWidth" properties:args def:1.0];
    //Build our extension object, so we can format on display
    ExtPolygon *newPolygon = [[[ExtPolygon alloc] 
                              initWithParameters:polyColor 
                              alpha:alpha title:polyTitle 
                              polygon:polygonToAdd 
                              linewidth:lineWidth] autorelease];
    
    //Get the optional strokeColor
    UIColor * strokeColor = [[TiUtils colorValue:@"strokeColor" properties:args] _color];
    //We only add the strokeColor if it is provided
    if (strokeColor != nil)
    {
        newPolygon.strokeColor=strokeColor;
    }
    
    //If our polygon collection isn't create, do so
    if (polygonOverlays==nil)
    {
        polygonOverlays = [[NSMutableArray alloc] init];
    }
    
    //Add the newly created polgyon to our collection
    [polygonOverlays addObject:newPolygon];
    //Add the polgyon to the map
    [[self map] addOverlay:polygonToAdd];
    
}
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
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        BOOL usePolygonDefaults = YES;
        MKPolygonView *polygonView = [[[MKPolygonView alloc] initWithPolygon:overlay] autorelease]; 
                
        for (ExtPolygon *pgc in polygonOverlays) 
        {    
            if (pgc.Polygon == overlay)
            {
                usePolygonDefaults=NO;
                polygonView.fillColor=pgc.Color;
                polygonView.alpha=pgc.Alpha;
                polygonView.lineWidth=pgc.lineWidth;
                if(pgc.strokeColor!=nil)
                {
                    polygonView.strokeColor=pgc.strokeColor;
                }
            }
        }
        
        if(usePolygonDefaults==YES)
        {
            polygonView.strokeColor = [UIColor greenColor];
            polygonView.fillColor = [UIColor greenColor];            
        }

        return polygonView;        
    }
    if ([overlay isKindOfClass:[MKCircle class]])
    {
        BOOL useCircleDefaults = YES;
        MKCircleView *cirlceView = [[[MKCircleView alloc] initWithCircle:overlay] autorelease]; 
        
        for (ExtCircle *extCircle in circleOverlays) 
        {    
            if (extCircle.Circle == overlay)
            {
                useCircleDefaults=NO;
                cirlceView.fillColor=extCircle.Color;
                cirlceView.alpha=extCircle.Alpha;
                cirlceView.lineWidth=extCircle.lineWidth;
                if(extCircle.strokeColor!=nil)
                {
                    cirlceView.strokeColor=extCircle.strokeColor;
                }
            }
        }
        
        if(useCircleDefaults==YES)
        {
            cirlceView.strokeColor = [UIColor greenColor];
            cirlceView.fillColor = [UIColor greenColor];            
        }
        
        return cirlceView;           
    }
    else
    {
        return (MKOverlayView *)CFDictionaryGetValue(mapLine2View, overlay);
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	if ([self.proxy _hasListeners:@"regionChanged"])
	{
		region = [mapView region];
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
								@"regionChanged",@"type",
								[NSNumber numberWithDouble:region.center.latitude],@"latitude",
								[NSNumber numberWithDouble:region.center.longitude],@"longitude",
								[NSNumber numberWithDouble:region.span.latitudeDelta],@"latitudeDelta",
								[NSNumber numberWithDouble:region.span.longitudeDelta],@"longitudeDelta",nil];
		[self.proxy fireEvent:@"regionChanged" withObject:props];
	}
    //SELECT ANNOTATION WILL NOT ALWAYS WORK IF THE MAPVIEW IS ANIMATING.
    //THIS FORCES A RESELCTION OF THE ANNOTATIONS WITHOUT SENDING OUT EVENTS
    //SEE TIMOB-8431 (IOS 4.3)
    ignoreClicks = YES;
    NSArray* currentSelectedAnnotations = [[mapView selectedAnnotations] retain];
    for (id annotation in currentSelectedAnnotations) {
        [mapView deselectAnnotation:annotation animated:NO];
        [mapView selectAnnotation:annotation animated:NO];
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
			annView.calloutOffset = CGPointMake(-5, 5);
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

@end
