//
//  DesignUtils.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <MBProgressHUD.h>

#import "ColorUtils.h"
#import "DesignUtils.h"

@implementation DesignUtils

+ (void)addBottomBorder:(UIView *)view
             borderSize:(float)borderSize
                  color:(UIColor *)color
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f,
                                    view.frame.size.height - borderSize,
                                    view.frame.size.width,
                                    borderSize);
    
    bottomBorder.backgroundColor = color.CGColor;
    [view.layer addSublayer:bottomBorder];
}

+ (void)addTopBorder:(UIView *)view
          borderSize:(float)borderSize
               color:(UIColor *)color
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f,
                                    0.0f,
                                    view.frame.size.width,
                                    borderSize);
    
    bottomBorder.backgroundColor = color.CGColor;
    [view.layer addSublayer:bottomBorder];
}

// Show HUD in view
+ (void)showProgressHUDAddedTo:(UIView *)view {
    [self showProgressHUDAddedTo:view withColor:[ColorUtils mainGreen]];
}

+ (void)showProgressHUDAddedTo:(UIView *)view withColor:(UIColor *)color {
    [DesignUtils showProgressHUDAddedTo:view withColor:color transform:CGAffineTransformIdentity];
}

+ (void)showProgressHUDAddedTo:(UIView *)view withColor:(UIColor *)color transform:(CGAffineTransform)transform {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = color;
    hud.transform = transform;
    [view addSubview:hud];
    [hud show:YES];
}

// Hide HUD form view
+ (void)hideProgressHUDForView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
