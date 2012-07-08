/**
 * benCoding.Map Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */


#import "ExtPolygon.h"

@implementation ExtPolygon

@synthesize Color,Alpha,Title,Polygon,lineWidth,strokeColor;


- (id)initWithParameters:(UIColor*)color alpha:(float)alpha title:(NSString*)title polygon:(MKPolygon*) polygon linewidth:(float)linewidth{
    
    if ((self = [self init])) {
        self.Color=color;
        self.Alpha=alpha;
        self.Title=title;
        self.Polygon=polygon;
        self.lineWidth=linewidth;
    }
    
    return self;
}
@end
