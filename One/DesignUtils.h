//
//  DesignUtils.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

@import Foundation;
@import UIKit;

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

@interface DesignUtils : NSObject

typedef NS_ENUM(NSInteger,OneBubblePosition) {
    kPositionTop = 0,
    kPositionRight = 1,
    kPositionBottom = 2,
    kPositionLeft = 4
};

+ (void)addBottomBorder:(UIView *)view borderSize:(float)borderSize color:(UIColor *)color;

+ (void)addTopBorder:(UIView *)view borderSize:(float)borderSize color:(UIColor *)color;

+ (void)addShadow:(UIView *)view;

+ (void)addShadowToButton:(UIButton *)button;

+ (void)showProgressHUDAddedTo:(UIView *)view;

+ (void)showProgressHUDAddedTo:(UIView *)view withColor:(UIColor *)color;

+ (void)hideProgressHUDForView:(UIView *)view;

+ (void)showProgressHUDAddedTo:(UIView *)view withColor:(UIColor *)color transform:(CGAffineTransform)transform userInteraction:(BOOL)flag;

+ (UIView *)createBubbleAboutView:(UIView *)view
                         withText:(NSString *)string
                         position:(OneBubblePosition)position
                  backgroundColor:(UIColor *)backgroundColor
                        textColor:(UIColor *)textColor;

+ (CAShapeLayer *)createGradientCircleLayerWithFrame:(CGRect)frame
                                         borderWidth:(NSInteger)borderWidth
                                               Color:(UIColor *)color
                                        subDivisions:(NSInteger)nbSubDivisions;

+ (UIImage *)blurAndRescaleImage:(UIImage *)image;

+ (UIImage*)drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point;

+ (UIImage*)createImageFromView:(UIView *)view;

@end
