//
//  WildcardGestureRecognizer.h
//  Copyright 2010 Floatopian LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UIGestureRecognizer {
    TouchesEventBlock touchesBeganCallback;
}
@property(copy) TouchesEventBlock touchesBeganCallback;


@end
