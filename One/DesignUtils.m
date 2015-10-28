//
//  DesignUtils.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <MBProgressHUD.h>
#import <UIImage+ImageEffects.h>


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

+ (void)addShadow:(UIView *)view {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowOpacity = 0.1;
    view.layer.shadowRadius = 20;
}

+ (void)addShadowToButton:(UIButton *)button {
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 0);
    button.layer.shadowOpacity = 0.1;
    button.layer.shadowRadius = 20;
}

+ (UIView *)createBubbleAboutView:(UIView *)view
                         withText:(NSString *)string
                         position:(OneBubblePosition)position
                  backgroundColor:(UIColor *)backgroundColor
                        textColor:(UIColor *)textColor
{
    // Font
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    // Define height here
    CGFloat height = 34;
    // Width based on the lenght of the string
    CGFloat width = [self widthOfString:string withFont:font] + 30;
    
    // TriangleView
    UIView *triangle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    triangle.backgroundColor = backgroundColor;
    
    // Frame based on the position paremeter
    CGRect frame = CGRectMake(0, 0, width, height);
    UIBezierPath *path = [UIBezierPath new];
    
    if (position == kPositionTop) {
        frame = CGRectMake(view.frame.origin.x + view.frame.size.width / 2 - width / 2, view.frame.origin.y - height - triangle.frame.size.height, width, height);
        
        [path moveToPoint: CGPointMake(0, 0)];
        [path addLineToPoint: CGPointMake(5, 5)];
        [path addLineToPoint: CGPointMake(10, 0)];
        [path addLineToPoint: CGPointMake(0, 0)];
        
        triangle.frame = CGRectMake(view.frame.origin.x + view.frame.size.width / 2 - triangle.frame.size.width / 2 , view.frame.origin.y - triangle.frame.size.height, triangle.frame.size.width, triangle.frame.size.height);
    } else if (position == kPositionBottom) {
        frame = CGRectMake(view.frame.origin.x + view.frame.size.width / 2 - width / 2, view.frame.origin.y + view.frame.size.height + triangle.frame.size.height, width, height);
        
        [path moveToPoint: CGPointMake(0, 10)];
        [path addLineToPoint: CGPointMake(5, 5)];
        [path addLineToPoint: CGPointMake(10, 10)];
        [path addLineToPoint: CGPointMake(0, 10)];
        
        triangle.frame = CGRectMake(view.frame.origin.x + view.frame.size.width / 2 - triangle.frame.size.width / 2 , view.frame.origin.y + view.frame.size.height, triangle.frame.size.width, triangle.frame.size.height);
    } else if (position == kPositionRight) {
        frame = CGRectMake(view.frame.origin.x + view.frame.size.width + triangle.frame.size.width - 1, view.frame.origin.y + view.frame.size.height / 2 - height / 2, width, height);
        
        [path moveToPoint: CGPointMake(10, 0)];
        [path addLineToPoint: CGPointMake(10, 10)];
        [path addLineToPoint: CGPointMake(5, 5)];
        [path addLineToPoint: CGPointMake(10, 0)];
        
        triangle.frame = CGRectMake(view.frame.origin.x + view.frame.size.width, view.frame.origin.y + view.frame.size.height /2 - triangle.frame.size.height /2, triangle.frame.size.width, triangle.frame.size.height);
    } else if (position == kPositionLeft) {
        frame = CGRectMake(view.frame.origin.x - width - triangle.frame.size.width + 1, view.frame.origin.y + view.frame.size.height / 2 - height / 2, width, height);
        
        [path moveToPoint: CGPointMake(0, 0)];
        [path addLineToPoint: CGPointMake(0, 10)];
        [path addLineToPoint: CGPointMake(5, 5)];
        [path addLineToPoint: CGPointMake(0, 0)];
        
        triangle.frame = CGRectMake(view.frame.origin.x - triangle.frame.size.width, view.frame.origin.y + view.frame.size.height /2 - triangle.frame.size.height /2, triangle.frame.size.width, triangle.frame.size.height);
    }
    
    // Triangle mask
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = triangle.bounds;
    mask.path = path.CGPath;
    triangle.layer.mask = mask;

    // Init
    UILabel *bubble = [[UILabel alloc] initWithFrame:frame];
    // UI
    bubble.text = string;
    bubble.backgroundColor = backgroundColor;
    bubble.textColor = textColor;
    bubble.textAlignment = NSTextAlignmentCenter;
    bubble.layer.cornerRadius = bubble.frame.size.height / 2;
    bubble.clipsToBounds = YES;
    bubble.font = font;
    bubble.layer.shadowOffset = CGSizeMake(0, 0);
    bubble.layer.shadowRadius = 3;
    bubble.layer.shadowOpacity = 0.2;
    triangle.layer.shadowOffset = CGSizeMake(0, 0);
    triangle.layer.shadowRadius = 3;
    triangle.layer.shadowOpacity = 0.2;
    
    UIView *bubbleView = [[UIView alloc] init];
    [bubbleView addSubview:triangle];
    [bubbleView addSubview:bubble];
    
    return bubbleView;
};

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

// Show HUD in view
+ (void)showProgressHUDAddedTo:(UIView *)view {
    [self showProgressHUDAddedTo:view withColor:[ColorUtils mainGreen]];
}

+ (void)showProgressHUDAddedTo:(UIView *)view withColor:(UIColor *)color {
    [DesignUtils showProgressHUDAddedTo:view withColor:color transform:CGAffineTransformIdentity userInteraction:NO];
}

+ (void)showProgressHUDAddedTo:(UIView *)view
                     withColor:(UIColor *)color
                     transform:(CGAffineTransform)transform
               userInteraction:(BOOL)flag {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = color;
    hud.transform = transform;
    hud.userInteractionEnabled = !flag;
    [view addSubview:hud];
    [hud show:YES];
}

// Hide HUD form view
+ (void)hideProgressHUDForView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+ (CAShapeLayer *)createGradientCircleLayerWithFrame:(CGRect)frame
                                         borderWidth:(NSInteger)borderWidth
                                               Color:(UIColor *)color
                                        subDivisions:(NSInteger)nbSubDivisions
{
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGFloat red, green, blue, alpha, subAlpha = 0, startAngle = 0, endAngle = DEGREES_TO_RADIANS(360)/nbSubDivisions;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CAShapeLayer *containingLayer = [CAShapeLayer new];
    containingLayer.frame = frame;
    
    for (int i=0; i<nbSubDivisions; i++) {
        CAShapeLayer *subLayer = [CAShapeLayer new];
        subLayer.frame = frame;
        subLayer.fillColor = [UIColor clearColor].CGColor;
        subLayer.lineWidth = borderWidth;
        subLayer.strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:subAlpha].CGColor;
        
        subLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                       radius:frame.size.width/2 + 4
                                                   startAngle:startAngle
                                                     endAngle:endAngle
                                                    clockwise:YES].CGPath;
        [containingLayer addSublayer:subLayer];
        
        // Prepare next subdiv
        subAlpha += alpha / nbSubDivisions;
        startAngle = endAngle;
        endAngle += DEGREES_TO_RADIANS(180)/nbSubDivisions;
    }
    return containingLayer;
}

+ (UIImage *)blurAndRescaleImage:(UIImage *)image {
    UIImage *scaledImage = [self imageWithImage:image scaledByFactor:0.25];
    return [scaledImage applyExtraLightEffect];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledByFactor:(CGFloat)factor {
    CGSize newSize = CGSizeMake(image.size.width*factor, image.size.height*factor);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


// Draw title in Image
+ (UIImage*)drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    NSMutableAttributedString *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",text]];
    [textStyle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, textStyle.length)];
    [textStyle addAttribute:NSFontAttributeName  value:[UIFont systemFontOfSize:80.0] range:NSMakeRange(0, textStyle.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [textStyle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textStyle length])];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [textStyle drawInRect:CGRectIntegral(rect)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)createImageFromView:(UIView *)view
{
    CGRect rect = view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
