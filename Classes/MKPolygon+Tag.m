//
//  BBMapPolygon.m
//  map
//
//  Created by Ben on 9/16/12.
//
//

#import "MKPolygon+Tag.h"
@implementation MKPolygon (TagExtensions)
static char tagKey;

- (void) setTag:(int)tag {
    objc_setAssociatedObject( self, &tagKey, [NSNumber numberWithInt:tag], OBJC_ASSOCIATION_RETAIN );
}

- (int) tag {
    return [objc_getAssociatedObject( self, &tagKey ) intValue];
}

@end
