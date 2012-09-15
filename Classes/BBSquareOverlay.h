//
//  BBSquareOverlay.h
//  map
//
//  Created by Ben on 9/14/12.
//
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BBSquareOverlay : NSObject <MKOverlay> {
    
}
- (id)initWithParameters:(MKMapPoint) upperLeft
                          upperRight:(MKMapPoint)upperRight
                          bottomLeft:(MKMapPoint)bottomLeft;

- (MKMapRect)boundingMapRect;
@property (readwrite, nonatomic) MKMapPoint UpperLeft;
@property (readwrite, nonatomic) MKMapPoint UpperRight;
@property (readwrite, nonatomic) MKMapPoint BottomLeft;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end