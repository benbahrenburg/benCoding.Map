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
#import "TiUIView.h"
#import <MapKit/MapKit.h>
#import "TiMapAnnotationProxy.h"
#import "ExtPolygon.h"
#import "ExtCircle.h"

@interface BencodingMapView : TiUIView<MKMapViewDelegate> {
@private
	MKMapView *map;
	BOOL regionFits;
	BOOL animate;
	BOOL loaded;
	BOOL ignoreClicks;
	MKCoordinateRegion region;
	
    // routes
    // dictionaries for object tracking and association
    CFMutableDictionaryRef mapLine2View;   // MKPolyline(route line) -> MKPolylineView(route view)
    CFMutableDictionaryRef mapName2Line;   // NSString(name) -> MKPolyline(route line)
    
	// Click detection
	id<MKAnnotation> hitAnnotation;
	BOOL hitSelect;
	BOOL manualSelect;
    NSMutableArray* polygonOverlays;
    NSMutableArray* circleOverlays;
}

@property (nonatomic, readonly) CLLocationDegrees longitudeDelta;
@property (nonatomic, readonly) CLLocationDegrees latitudeDelta;
@property (nonatomic, readonly) NSArray *customAnnotations;
@property (nonatomic) MKUserTrackingMode userTrackingMode;

#pragma mark Private APIs
-(TiMapAnnotationProxy*)annotationFromArg:(id)arg;
-(NSArray*)annotationsFromArgs:(id)value;

- (TiMapAnnotationProxy*)proxyForAnnotation:(MKAnnotationView*)pinview;

#pragma mark Public APIs
-(void)removeAllCircles:(id)arg;
-(void)removeCircle:(id)args;
-(void)addCircle:(id)args;

-(void)removeAllPolygons:(id)arg;
-(void)removePolygon:(id)args;
-(void)addPolygon:(id)args;

-(void)addAnnotation:(id)args;
-(void)addAnnotations:(id)args;
-(void)setAnnotations_:(id)value;
-(void)removeAnnotation:(id)args;
-(void)removeAnnotations:(id)args;
-(void)removeAllAnnotations:(id)args;
-(void)selectAnnotation:(id)args;
-(void)deselectAnnotation:(id)args;
-(void)zoom:(id)args;
-(void)addRoute:(id)args;
-(void)removeRoute:(id)args;
-(void)firePinChangeDragState:(MKAnnotationView *) pinview newState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState;
-(void)setUserTrackingMode_:(id)args;

#pragma mark Framework
-(void)refreshAnnotation:(TiMapAnnotationProxy*)proxy readd:(BOOL)yn;
-(void)fireClickEvent:(MKAnnotationView *) pinview source:(NSString *)source;

@end