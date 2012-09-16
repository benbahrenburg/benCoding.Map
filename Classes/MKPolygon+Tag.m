/**
 * benCoding.Map
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

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
