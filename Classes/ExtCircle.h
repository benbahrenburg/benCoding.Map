/**
 * benCoding.Map Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ExtCircle : NSObject {
    
}

- (id)initWithParameters:(UIColor*)color alpha:(float)alpha title:(NSString*)title polygon:(MKCircle*) circle linewidth:(float)linewidth;

@property (nonatomic, readwrite, assign) UIColor* Color;
@property (nonatomic, readwrite, assign) float Alpha;
@property (nonatomic, readwrite, assign) NSString* Title;
@property (nonatomic, readwrite, assign) MKCircle* Circle;
@property (nonatomic, readwrite, assign) float lineWidth;
@property (nonatomic, readwrite, assign) UIColor* strokeColor;
@end