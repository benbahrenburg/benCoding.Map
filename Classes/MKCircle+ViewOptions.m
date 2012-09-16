//
//  MKCircle+ViewOptions.m
//  map
//
//  Created by Ben on 9/16/12.
//
//
#import "MKCircle+ViewOptions.h"
@implementation MKCircle (ViewPropertiesExtensions)
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

