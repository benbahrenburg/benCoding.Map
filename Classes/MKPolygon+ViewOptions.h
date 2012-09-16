/**
 * benCoding.Map
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>

@interface MKPolygon (ViewPropertiesExtensions)
@property (strong, nonatomic) UIColor* color;
@property (nonatomic) int tag;
@property (strong, nonatomic) NSNumber* alpha;
@property (strong, nonatomic) NSNumber* lineWidth;
@property (strong, nonatomic) UIColor* strokeColor;
@end
