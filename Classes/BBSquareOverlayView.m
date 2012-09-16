//
//  BBMapOverlay.m
//  map
//
//  Created by Ben on 9/14/12.
//
//

#import "BBSquareOverlayView.h"

@implementation BBSquareOverlayView
@synthesize ImagePath;

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)ctx
{
    
    UIImage *image          = [[UIImage imageWithContentsOfFile:ImagePath] retain];
    CGImageRef imageReference = image.CGImage;
    
    //Loading and setting the image
    MKMapRect theMapRect    = [self.overlay boundingMapRect];
    CGRect theRect          = [self rectForMapRect:theMapRect];
    
    
    // We need to flip and reposition the image here
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0.0, -theRect.size.height);
    
    //drawing the image to the context
    CGContextDrawImage(ctx, theRect, imageReference);
    
    [image release];
}

@end
