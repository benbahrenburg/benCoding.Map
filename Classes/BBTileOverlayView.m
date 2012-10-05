// Initial code provided as part of the WWDC 2010 TileMap App
// For more information please visit
// http://www.shawngrimes.me/2010/12/mapkit-overlays-session-1-overlay-map/
//
//     File: TileOverlay.m
// Abstract:
//     MKOverlay model class representing a tiled raster map overlay described by a directory hierarchy of tile images.
//
//  Version: 1.0
//
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
//
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
//
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Copyright (C) 2010 Apple Inc. All Rights Reserved.
//
//
// An additional copy of the TileMap App can be found below
// https://github.com/klokantech/Apple-WWDC10-TileMap


#import "BBTileOverlayView.h"
#import "BBTileOverlay.h"

@implementation BBTileOverlayView

@synthesize tileAlpha;

- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    if (self = [super initWithOverlay:overlay]) {
        tileAlpha = 0.75;
    }
    return self;
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect
             zoomScale:(MKZoomScale)zoomScale
{
    // Return YES only if there are some tiles in this mapRect and at this zoomScale.
    BBTileOverlay *tileOverlay = (BBTileOverlay *)self.overlay;
    NSArray *tilesInRect = [tileOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    return [tilesInRect count] > 0;    
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    BBTileOverlay *tileOverlay = (BBTileOverlay *)self.overlay;
    
    // Get the list of tile images from the model object for this mapRect.  The
    // list may be 1 or more images (but not 0 because canDrawMapRect would have
    // returned NO in that case).
    NSArray *tilesInRect = [tileOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    
    CGContextSetAlpha(context, tileAlpha);
        
    for (BBImageTile *tile in tilesInRect) {
        // For each image tile, draw it in its corresponding MKMapRect frame
        CGRect rect = [self rectForMapRect:tile.frame];
        UIImage *image = [[[UIImage alloc] initWithContentsOfFile:tile.imagePath] autorelease];
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, 1/zoomScale, 1/zoomScale);
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
        CGContextRestoreGState(context);
    }
}

@end
