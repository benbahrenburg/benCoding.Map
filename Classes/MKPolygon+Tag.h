//
//  BBMapPolygon.h
//  map
//
//  Created by Ben on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>

@interface MKPolygon (TagExtensions)
@property (nonatomic) int tag;
@end
