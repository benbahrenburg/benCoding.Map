/**
 * benCoding.Map Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ExtCircle.h"
@implementation ExtCircle

@synthesize Color,Alpha,Title,Circle,lineWidth,strokeColor;


- (id)initWithParameters:(UIColor*)color alpha:(float)alpha title:(NSString*)title polygon:(MKCircle*) circle linewidth:(float)linewidth{
    
    if ((self = [self init])) {
        self.Color=color;
        self.Alpha=[NSNumber numberWithFloat:alpha];
        self.Title=title;
        self.Circle=circle;
        self.lineWidth=[NSNumber numberWithFloat:linewidth];
    }
    
    return self;
}
@end
