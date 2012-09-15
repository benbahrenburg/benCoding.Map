//
//  BBOverlay.m
//  map
//
//  Created by Ben on 9/16/12.
//
//

#import "BBOverlay.h"

@implementation BBOverlay
@synthesize ImagePath,OverlayType, Color,Alpha, Title, Overlay,lineWidth,strokeColor;

- (id)initWithParameters:(NSString const*) overlayType
                   color:(UIColor*)color
                   alpha:(float)alpha
                   title:(NSString*)title
                 overlay:(NSObject <MKOverlay>*) overlay
               linewidth:(float)linewidth
{
    if ((self = [self init])) {
        self.OverlayType=overlayType;
        self.Color=color;
        self.Alpha=[NSNumber numberWithFloat:alpha];
        self.Title=title;
        self.Overlay=overlay;
        self.lineWidth=[NSNumber numberWithFloat:linewidth];
    }
    
    return self;
}
- (id)initWithImageFileParameters:(NSString const*) overlayType
                            title:(NSString*)title
                          overlay:(NSObject <MKOverlay>*) overlay
                        imagePath:(NSString*)imagePath
{
    if ((self = [self init])) {
        self.OverlayType=overlayType;
        self.Title=title;
        self.Overlay=overlay;
        self.ImagePath=imagePath;
    }
    
    return self;
}
- (id)initWithParametersAndPath:(UIColor*)color alpha:(float)alpha
                          title:(NSString*)title overlay:(NSObject <MKOverlay>*) overlay
                          linewidth:(float)linewidth imagePath:(NSString*)imagePath
{
    if ((self = [self init])) {
        self.Color=color;
        self.Alpha=[NSNumber numberWithFloat:alpha];
        self.Title=title;
        self.Overlay=overlay;
        self.lineWidth=[NSNumber numberWithFloat:linewidth];
    }
    
    return self;
}
@end
