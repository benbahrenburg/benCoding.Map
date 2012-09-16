/**
 * benCoding.Map
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BBSquareImageOverlay : NSObject <MKOverlay> {
    MKMapRect mapRect;
    
}

- (id) initWithCoordinates:(CLLocationCoordinate2D)upperRightCoordinate withLowerLeftCoordinate:(CLLocationCoordinate2D)lowerLeftCoordinate;

- (MKMapRect)boundingMapRect;

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString* imagePath;
@property (strong, nonatomic) NSNumber* alpha;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) UIColor* color;
@property (nonatomic) int tag;

@end