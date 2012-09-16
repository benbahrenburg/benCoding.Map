/**
 * benCoding.Map
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "MKPolygon+ViewOptions.h"
@implementation MKPolygon (ViewPropertiesExtensions)
static char colorKey;
static char tagKey;
static char strokeColorKey;
static char alphaKey;
static char lineWidthKey;

- (void) setTag:(int)tag {
    objc_setAssociatedObject( self, &tagKey, [NSNumber numberWithInt:tag], OBJC_ASSOCIATION_RETAIN );
}

- (int) tag
{
    return [objc_getAssociatedObject( self, &tagKey ) intValue];
}

- (void) setAlpha:(NSNumber*)value
{
    objc_setAssociatedObject( self, &alphaKey, value, OBJC_ASSOCIATION_RETAIN );
}

- (NSNumber*) alpha
{
    objc_getAssociatedObject( self, &alphaKey );
}

- (void) setLineWidth:(NSNumber *)value
{
    objc_setAssociatedObject( self, &lineWidthKey, value, OBJC_ASSOCIATION_RETAIN );
}

- (NSNumber*) lineWidth
{
    objc_getAssociatedObject( self, &lineWidthKey );
}

- (void) setColor:(UIColor*)color
{
    objc_setAssociatedObject( self, &colorKey, color, OBJC_ASSOCIATION_RETAIN );
}

- (UIColor*) color
{
    return objc_getAssociatedObject( self, &colorKey );
}

- (void) setStrokeColor:(UIColor*)color
{
    objc_setAssociatedObject( self, &strokeColorKey, color, OBJC_ASSOCIATION_RETAIN );
}

- (UIColor*) strokeColor
{
    return objc_getAssociatedObject( self, &strokeColorKey );
}
@end

