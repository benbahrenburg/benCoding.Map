//
//  BBSquareOverlay.m
//  map
//
//  Created by Ben on 9/14/12.
//
//

#import "BBSquareImageOverlay.h"
#import <MapKit/MapKit.h>

@implementation BBSquareImageOverlay
@synthesize coordinate,imagePath,alpha,title,color,tag;

- (id) initWithCoordinates:(CLLocationCoordinate2D)upperRightCoordinate withLowerLeftCoordinate:(CLLocationCoordinate2D)lowerLeftCoordinate
{
    // self.radarData = imageData;
    
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
