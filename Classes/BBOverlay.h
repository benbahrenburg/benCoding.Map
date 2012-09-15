//
//  BBOverlay.h
//  map
//
//  Created by Ben on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BBOverlay : NSObject


- (id)initWithParameters:(NSString const*) overlayType
                   color:(UIColor*)color
                   alpha:(float)alpha
                   title:(NSString*)title
                 overlay:(NSObject <MKOverlay>*) overlay
               linewidth:(float)linewidth;

- (id)initWithImageFileParameters:(NSString const*) overlayType
                   title:(NSString*)title
                 overlay:(NSObject <MKOverlay>*) overlay
               imagePath:(NSString*)imagePath;

@property (strong, nonatomic) NSString* ImagePath;
@property (strong, nonatomic) NSString const* OverlayType;
@property (strong, nonatomic) UIColor* Color;
@property (strong, nonatomic) NSNumber* Alpha;
@property (strong, nonatomic) NSString* Title;
@property (strong, nonatomic) NSObject <MKOverlay>* Overlay;
@property (strong, nonatomic) NSNumber* lineWidth;
@property (strong, nonatomic) UIColor* strokeColor;

@end
