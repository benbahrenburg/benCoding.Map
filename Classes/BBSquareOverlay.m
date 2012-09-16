//
//  BBSquareOverlay.m
//  map
//
//  Created by Ben on 9/14/12.
//
//

#import "BBSquareOverlay.h"
#import <MapKit/MapKit.h>

@implementation BBSquareOverlay
@synthesize UpperLeft,UpperRight,BottomLeft, imagePath, color,alpha,title,lineWidth,strokeColor;
- (MKMapRect) mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion
{
    CLLocationCoordinate2D topLeftCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + (coordinateRegion.span.latitudeDelta / 2.0), coordinateRegion.center.longitude - (coordinateRegion.span.longitudeDelta / 2.0));
    
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - (coordinateRegion.span.latitudeDelta / 2.0), coordinateRegion.center.longitude + (coordinateRegion.span.longitudeDelta / 2.0));
    
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x, topLeftMapPoint.y, fabs(bottomRightMapPoint.x - topLeftMapPoint.x), fabs(bottomRightMapPoint.y - topLeftMapPoint.y));
    
    return mapRect;
}

- (MKPolygon*) createSquareFromRadius:(CLLocation*)center withRadius:(float)radius
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center.coordinate, radius*2, radius*2);
    
    CLLocationCoordinate2D  points[4];
    
    //Fill the array with the four corners (center - span/2 in each of four directions)
    points[0] = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2, region.center.longitude - region.span.longitudeDelta/2);
    points[1] = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2, region.center.longitude - region.span.longitudeDelta/2);
    points[2] = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2, region.center.longitude + region.span.longitudeDelta/2);
    points[3] = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2, region.center.longitude +  region.span.longitudeDelta/2);
    
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:points count:4];
    return polygon;
    
}

- (id)initWithParameters:(MKMapPoint) upperLeft
              upperRight:(MKMapPoint)upperRight
              bottomLeft:(MKMapPoint)bottomLeft

{
    if ((self = [self init])) {
        self.UpperLeft=upperLeft;
        self.UpperRight=upperRight;
        self.BottomLeft=bottomLeft;
    }
    
    return self;
}
-(CLLocationCoordinate2D)coordinate {
    //Image center point
    return CLLocationCoordinate2DMake(48.85883, 2.2945);
}

- (MKMapRect)boundingMapRect
{
    //Need to generate a sqaure here based on distance
    
    //Latitue and longitude for each corner point
//    MKMapPoint upperLeft   = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48.85995, 2.2933));
//    MKMapPoint upperRight  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48.85995, 2.2957));
//    MKMapPoint bottomLeft  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48.85758, 2.2933));
    
    //Building a map rect that represents the image projection on the map
    MKMapRect bounds = MKMapRectMake(self.UpperLeft.x, self.UpperLeft.y,
                                     fabs(self.UpperLeft.x - self.UpperRight.x),
                                     fabs(self.UpperLeft.y - self.BottomLeft.y));
    return bounds;
}

-(void) dealloc {
    [super dealloc];
}

@end
