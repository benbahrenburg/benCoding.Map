/**
 * benCoding.Map
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BBSquareImageOverlay.h"
#import <MapKit/MapKit.h>

@implementation BBSquareImageOverlay
@synthesize coordinate,imagePath,alpha,title,color,tag;

- (id) initWithCoordinates:(CLLocationCoordinate2D)upperRightCoordinate withLowerLeftCoordinate:(CLLocationCoordinate2D)lowerLeftCoordinate
{
    
    MKMapPoint lowerLeft = MKMapPointForCoordinate(lowerLeftCoordinate);
    MKMapPoint upperRight = MKMapPointForCoordinate(upperRightCoordinate);
    
    mapRect = MKMapRectMake(lowerLeft.x, upperRight.y, upperRight.x - lowerLeft.x, lowerLeft.y - upperRight.y);
    
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(mapRect), MKMapRectGetMidY(mapRect)));
}

- (MKMapRect)boundingMapRect
{
    return mapRect;
}

-(void) dealloc {
    [super dealloc];
}

@end
