/**
 This file has been forked and modified from the Titanium project to add Polygon support
 */ 

/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingMapViewProxy.h"
#import "BencodingMapView.h"
#import "TiMapView.h"

@implementation BencodingMapViewProxy

#pragma mark Internal

-(NSArray *)keySequence
{
    return [NSArray arrayWithObjects:
            @"animate",
            @"location",
            @"regionFit",
            nil];
}

-(void)_destroy
{
	RELEASE_TO_NIL(selectedAnnotation);
	RELEASE_TO_NIL(annotationsToAdd);
	RELEASE_TO_NIL(annotationsToRemove);
	RELEASE_TO_NIL(routesToAdd);
	RELEASE_TO_NIL(routesToRemove);
    
    RELEASE_TO_NIL(polygonsToAdd);
    RELEASE_TO_NIL(polygonsToRemove);
    RELEASE_TO_NIL(circlesToAdd);
    RELEASE_TO_NIL(circlesToRemove);

    RELEASE_TO_NIL(imageOverlaysToRemove);
    RELEASE_TO_NIL(imageOverlaysToAdd);
    
	[super _destroy];
}

-(NSNumber*) longitudeDelta
{
	__block CLLocationDegrees delta = 0.0;
	
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{
			delta = [(BencodingMapView *)[self view] longitudeDelta];
		},YES);
		
	}
	return [NSNumber numberWithDouble:delta];
    
}

-(NSNumber*) latitudeDelta
{
	__block CLLocationDegrees delta = 0.0;
	
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{
			delta = [(BencodingMapView *)[self view] latitudeDelta];
		},YES);
		
	}
	return [NSNumber numberWithDouble:delta];
}

-(void)viewDidAttach
{
	ENSURE_UI_THREAD_0_ARGS;
	BencodingMapView * ourView = (BencodingMapView *)[self view];
    
    for (id arg in annotationsToAdd) {
        [ourView addAnnotation:arg];
    }
    
    for (id arg in annotationsToRemove) {
        [ourView removeAnnotation:arg];
    }
    
    for (id arg in routesToAdd)
    {
        [ourView addRoute:arg];
    }
    
    for (id arg in routesToRemove)
    {
        [ourView removeRoute:arg];
    }
    
    for (id arg in polygonsToAdd)
    {
        [ourView addPolygon:arg];
    }

    for (id arg in polygonsToRemove)
    {
        [ourView removePolygon:arg];
    }
    
    for (id arg in circlesToAdd)
    {
        [ourView addCircle:arg];
    }

    for (id arg in circlesToRemove)
    {
        [ourView removeCircle:arg];
    }

    for (id arg in imageOverlaysToRemove)
    {
        [ourView removeImageOverlay:arg];
    }
    
    for (id arg in imageOverlaysToAdd)
    {
        [ourView addImageOverlay:arg];
    }
    
	[ourView selectAnnotation:selectedAnnotation];
	if (zoomCount > 0) {
		for (int i=0; i < zoomCount; i++) {
			[ourView zoom:[NSNumber numberWithDouble:1.0]];
		}
	}
	else {
		for (int i=zoomCount;i < 0;i++) {
			[ourView zoom:[NSNumber numberWithDouble:-1.0]];
		}
	}
	
	RELEASE_TO_NIL(selectedAnnotation);
	RELEASE_TO_NIL(annotationsToAdd);
	RELEASE_TO_NIL(annotationsToRemove);
	RELEASE_TO_NIL(routesToAdd);
	RELEASE_TO_NIL(routesToRemove);
	RELEASE_TO_NIL(polygonsToAdd);
	RELEASE_TO_NIL(polygonsToRemove);
    RELEASE_TO_NIL(circlesToAdd);
    RELEASE_TO_NIL(circlesToRemove);

    RELEASE_TO_NIL(imageOverlaysToRemove);
    RELEASE_TO_NIL(imageOverlaysToAdd);
    
	[super viewDidAttach];
}

-(TiMapAnnotationProxy*)annotationFromArg:(id)arg
{
	if ([arg isKindOfClass:[TiMapAnnotationProxy class]])
	{
		[(TiMapAnnotationProxy*)arg setDelegate:((TiMapView*)self)];
		[arg setPlaced:NO];
		return arg;
	}
	ENSURE_TYPE(arg,NSDictionary);
	TiMapAnnotationProxy *proxy = [[[TiMapAnnotationProxy alloc] _initWithPageContext:[self pageContext] args:[NSArray arrayWithObject:arg]] autorelease];
    
	[proxy setDelegate:((TiMapView*)self)];
	return proxy;
}

#pragma mark Public API

-(void)zoom:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject)
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] zoom:arg];}, NO);
	}
	else {
		double v = [TiUtils doubleValue:arg];
		// TODO: Find good delta tolerance value to deal with floating point goofs
		if (v == 0.0) {
			return;
		}
		if (v > 0) {
			zoomCount++;
		}
		else {
			zoomCount--;
		}
	}
}

-(void)selectAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject)
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] selectAnnotation:arg];}, NO);
	}
	else {
		if (selectedAnnotation != arg) {
			RELEASE_TO_NIL(selectedAnnotation);
			selectedAnnotation = [arg retain];
		}
	}
}

-(void)deselectAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject)
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] deselectAnnotation:arg];}, NO);
	}
	else {
		RELEASE_TO_NIL(selectedAnnotation);
	}
}

-(void)addAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject)
    TiMapAnnotationProxy* annProxy = [self annotationFromArg:arg];
    [self rememberProxy:annProxy];
    
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addAnnotation:arg];}, NO);
	}
	else 
	{
		if (annotationsToAdd==nil)
		{
			annotationsToAdd = [[NSMutableArray alloc] init];
		}
		if (annotationsToRemove!=nil && [annotationsToRemove containsObject:arg]) 
		{
			[annotationsToRemove removeObject:arg];
		}
		else 
		{
			[annotationsToAdd addObject:arg];
		}
	}
}

-(void)addAnnotations:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSArray)
    NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:[arg count]];
    for (id ann in arg) {
        TiMapAnnotationProxy* annotation = [self annotationFromArg:ann];
        [newAnnotations addObject:annotation];
        [self rememberProxy:annotation];
    }
    
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addAnnotations:newAnnotations];}, NO);
	}
	else {
		for (id annotation in newAnnotations) {
			[self addAnnotation:annotation];
		}
	}
}

-(void)setAnnotations:(id)arg{
    ENSURE_TYPE(arg,NSArray)
    
    NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:[arg count]];
    for (id ann in arg) {
        [newAnnotations addObject:[self annotationFromArg:ann]];
    }
    
    BOOL attached = [self viewAttached];
    __block NSArray* currentAnnotations = nil;
    if (attached) {
        TiThreadPerformOnMainThread(^{
            currentAnnotations = [[(BencodingMapView*)[self view] customAnnotations] retain];
        }, YES);
    }
    else {
        currentAnnotations = annotationsToAdd;
    }
    
    // Because the annotations may contain an annotation proxy and not just
    // descriptors for them, we have to check and make sure there is
    // no overlap and remember/forget appropriately.
    
    for(TiMapAnnotationProxy * annProxy in currentAnnotations) {
        if (![newAnnotations containsObject:annProxy]) {
            [self forgetProxy:annProxy];
        }
    }
    for(TiMapAnnotationProxy* annProxy in newAnnotations) {
        if (![currentAnnotations containsObject:annProxy]) {
            [self rememberProxy:annProxy];
        }
    }
    
    if(attached) {
        TiThreadPerformOnMainThread(^{
            [(BencodingMapView*)[self view] setAnnotations_:newAnnotations];
        }, NO);
        [currentAnnotations release];
    }
    else {
        RELEASE_TO_NIL(annotationsToAdd);
        RELEASE_TO_NIL(annotationsToRemove);
        
        annotationsToAdd = [[NSMutableArray alloc] initWithArray:newAnnotations];
    }
}

-(NSArray*)annotations
{
    if ([self viewAttached]) {
        __block NSArray* currentAnnotations = nil;
        TiThreadPerformOnMainThread(^{
            currentAnnotations = [[(BencodingMapView*)[self view] customAnnotations] retain];
        }, YES);
        return [currentAnnotations autorelease];
    }
    else {
        return annotationsToAdd;
    }
}

-(void)removeAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject)
    
    // For legacy reasons, we can apparently allow the arg here to be a string (0.8 compatibility?!?)
    // and so only need to convert/remember/forget if it is an annotation instead.
    if ([arg isKindOfClass:[TiMapAnnotationProxy class]]) {
        [self forgetProxy:arg];
    }
    
	if ([self viewAttached]) 
	{
        TiThreadPerformOnMainThread(^{
            [(BencodingMapView*)[self view] removeAnnotation:arg];
        }, NO);
	}
	else 
	{
		if (annotationsToRemove==nil)
		{
			annotationsToRemove = [[NSMutableArray alloc] init];
		}
		if (annotationsToAdd!=nil && [annotationsToAdd containsObject:arg]) 
		{
			[annotationsToAdd removeObject:arg];
		}
		else 
		{
			[annotationsToRemove addObject:arg];
		}
	}
}

-(void)removeAnnotations:(id)arg
{
	ENSURE_TYPE(arg,NSArray)
    for (id ann in arg) {
        if ([ann isKindOfClass:[TiMapAnnotationProxy class]]) {
            [self forgetProxy:ann];
        }
    }
    
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{
            [(BencodingMapView*)[self view] removeAnnotations:arg];
        }, NO);
	}
	else {
		for (id annotation in arg) {
			[self removeAnnotation:annotation];
		}
	}
}

-(void)removeAllAnnotations:(id)unused
{
	if ([self viewAttached]) {
        __block NSArray* currentAnnotations = nil;
        TiThreadPerformOnMainThread(^{
            currentAnnotations = [[(BencodingMapView*)[self view] customAnnotations] retain];
        }, YES);
        
        for(id object in currentAnnotations)
        {
            TiMapAnnotationProxy * annProxy = [self annotationFromArg:object];
            [self forgetProxy:annProxy];
        }
        [currentAnnotations release];
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeAllAnnotations:unused];}, NO);
	}
	else 
	{
        for (TiMapAnnotationProxy* annotation in annotationsToAdd) {
            [self forgetProxy:annotation];
        }
        
        RELEASE_TO_NIL(annotationsToAdd);
        RELEASE_TO_NIL(annotationsToRemove);
	}
}

-(void)addRoute:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSDictionary)
	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addRoute:arg];}, NO);
	}
	else 
	{
		if (routesToAdd==nil)
		{
			routesToAdd = [[NSMutableArray alloc] init];
		}
		if (routesToRemove!=nil && [routesToRemove containsObject:arg])
		{
			[routesToRemove removeObject:arg];
		}
		else 
		{
			[routesToAdd addObject:arg];
		}
	}
}

-(void)removeRoute:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSDictionary)
	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeRoute:arg];}, NO);
	}
	else 
	{
		if (routesToRemove==nil)
		{
			routesToRemove = [[NSMutableArray alloc] init];
		}
		if (routesToAdd!=nil && [routesToAdd containsObject:arg])
		{
			[routesToAdd removeObject:arg];
		}
		else 
		{
			[routesToRemove addObject:arg];
		}
	}
}

-(void)removeAllCircles:(id)arg
{
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeAllCircles:arg];}, NO);
	}
	else 
	{        
        RELEASE_TO_NIL(circlesToRemove);
        RELEASE_TO_NIL(circlesToAdd);
	}
}
-(void)removeCircle:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
    
	if ([self viewAttached]) 
	{
        TiThreadPerformOnMainThread(^{
            [(BencodingMapView*)[self view] removeCircle:args];
        }, NO);
	}
	else 
	{
		if (circlesToRemove==nil)
		{
			circlesToRemove = [[NSMutableArray alloc] init];
		}
		if (circlesToAdd!=nil && [circlesToAdd containsObject:args]) 
		{
			[circlesToAdd removeObject:args];
		}
		else 
		{
			[circlesToRemove addObject:args];
		}
	}
}

-(void)addCircle:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
    
    if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addCircle:args];}, NO);
	}
	else 
	{
		if (circlesToAdd==nil)
		{
			circlesToAdd = [[NSMutableArray alloc] init];
		}
		if (circlesToRemove!=nil && [circlesToRemove containsObject:args]) 
		{
			[circlesToRemove removeObject:args];
		}
		else 
		{
			[circlesToAdd addObject:args];
		}
	}        
}

-(void)removeAllPolygons:(id)arg
{
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeAllPolygons:arg];}, NO);
	}
	else 
	{        
        RELEASE_TO_NIL(polygonsToRemove);
        RELEASE_TO_NIL(polygonsToAdd);
	}
}
-(void)removePolygon:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
    
	if ([self viewAttached]) 
	{
        TiThreadPerformOnMainThread(^{
            [(BencodingMapView*)[self view] removePolygon:args];
        }, NO);
	}
	else 
	{
		if (polygonsToRemove==nil)
		{
			polygonsToRemove = [[NSMutableArray alloc] init];
		}
		if (polygonsToAdd!=nil && [polygonsToAdd containsObject:args]) 
		{
			[polygonsToAdd removeObject:args];
		}
		else 
		{
			[polygonsToRemove addObject:args];
		}
	}
}

-(void)addPolygon:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
    
    if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addPolygon:args];}, NO);
	}
	else 
	{
		if (polygonsToAdd==nil)
		{
			polygonsToAdd = [[NSMutableArray alloc] init];
		}
		if (polygonsToRemove!=nil && [polygonsToRemove containsObject:args]) 
		{
			[polygonsToRemove removeObject:args];
		}
		else 
		{
			[polygonsToAdd addObject:args];
		}
	}    
    
}

-(void)removeAllImageOverlays:(id)arg
{
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeAllImageOverlays:arg];}, NO);
	}
	else
	{
        RELEASE_TO_NIL(imageOverlaysToRemove);
        RELEASE_TO_NIL(imageOverlaysToAdd);
	}
}

-(void)removeImageOverlay:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
    
	if ([self viewAttached])
	{
        TiThreadPerformOnMainThread(^{
            [(BencodingMapView*)[self view] removeImageOverlay:args];
        }, NO);
	}
	else
	{
		if (imageOverlaysToRemove==nil)
		{
			imageOverlaysToRemove = [[NSMutableArray alloc] init];
		}
		if (imageOverlaysToAdd!=nil && [imageOverlaysToAdd containsObject:args])
		{
			[imageOverlaysToAdd removeObject:args];
		}
		else
		{
			[imageOverlaysToRemove addObject:args];
		}
	}
}
-(void)addImageOverlay:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
    
    if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addImageOverlay:args];}, NO);
	}
	else
	{
		if (imageOverlaysToAdd==nil)
		{
			imageOverlaysToAdd = [[NSMutableArray alloc] init];
		}
		if (imageOverlaysToRemove!=nil && [imageOverlaysToRemove containsObject:args])
		{
			[imageOverlaysToRemove removeObject:args];
		}
		else
		{
			[imageOverlaysToAdd addObject:args];
		}
	}
}
-(void)addTileOverlayDirectory:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary)
    if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addTileOverlayDirectory:args];}, NO);
	} else {
        // TODO - need to track this to get added
        // For now, just call setTileDirectory on the 'open' even of the window
        // and it will work
    }
}
-(void)removeTileOverlayDirectory:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary)
    if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeTileOverlayDirectory:args];}, NO);
	}
}
-(void)removeAllTileOverlayDirectory:(id)unused
{
    
    if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeAllTileOverlayDirectory:unused];}, NO);
	}
}
-(void)addKML:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary)
	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addKML:args];}, NO);
	}
}

-(void)removeKML:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary)
	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] removeKML:args];}, NO);
	}
}

-(void) addImageOverlayFile:(id)args
{
	ENSURE_SINGLE_ARG(args,NSString)
	if ([self viewAttached])
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addImageOverlayFile:args];}, NO);
	}
}

-(void) addGeoJSON:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary)
	if ([self viewAttached])
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] addGeoJSON:args];}, NO);
	}
}

-(void)clear:(id)unused
{
	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] clear:unused];}, NO);
	}
}

-(void)ZoomToFit:(id)unused
{
  	if ([self viewAttached])
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] ZoomToFit:unused];}, NO);
	}
}

-(void)ZoomOutFull:(id)unused
{
  	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(BencodingMapView*)[self view] ZoomOutFull:unused];}, NO);
	}  
}
@end