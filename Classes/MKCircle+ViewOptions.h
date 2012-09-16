//
//  MKCircle+ViewOptions.h
//  map
//
//  Created by Ben on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>

@interface MKCircle (ViewPropertiesExtensions)
@property (strong, nonatomic) UIColor* color;
@property (nonatomic) int tag;
@property (strong, nonatomic) NSNumber* alpha;
@property (strong, nonatomic) NSNumber* lineWidth;
@property (strong, nonatomic) UIColor* strokeColor;
@end
