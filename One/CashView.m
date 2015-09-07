//
//  CashView.m
//  One
//
//  Created by Baptiste Truchot on 9/6/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <POP/POP.h>

#import "CashView.h"

#import "ColorUtils.h"
#import "DesignUtils.h"

@interface CashView()
@property (weak, nonatomic) IBOutlet UILabel *centralLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftUpOne;
@property (weak, nonatomic) IBOutlet UILabel *rightUpOne;
@property (weak, nonatomic) IBOutlet UILabel *leftBottomOne;
@property (weak, nonatomic) IBOutlet UILabel *rightBottomOne;
@property (strong, nonatomic) NSString *message;
@property (nonatomic) CGPoint initialCenter;
@end

@implementation CashView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.initialCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    // UI
    [self setStaticUI];
    self.layer.cornerRadius = self.frame.size.height / 40;
    self.centralLabel.backgroundColor = [ColorUtils lightGreen];
    self.centralLabel.textColor = [ColorUtils darkGreen];
    self.centralLabel.adjustsFontSizeToFitWidth = YES;
    self.centralLabel.layer.cornerRadius = 2./6. * frame.size.width;
    self.centralLabel.clipsToBounds = YES;
    self.leftUpOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    self.leftUpOne.textColor = [ColorUtils lightGreen];
    self.rightUpOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(+90));
    self.rightUpOne.textColor = [ColorUtils lightGreen];
    self.leftBottomOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    self.leftBottomOne.textColor = [ColorUtils lightGreen];
    self.rightBottomOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(+90));
    self.rightBottomOne.textColor = [ColorUtils lightGreen];
    
    // Pan Gesture
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    [self addGestureRecognizer:recognizer];
}

- (void)setStaticUI {
    self.backgroundColor = [ColorUtils darkGreen];
}

- (void)setMovingUI {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.superview];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self setMovingUI];
        [self.layer pop_removeAllAnimations];
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.superview];
        POPDecayAnimation *positionAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.delegate = self;
        positionAnimation.deceleration = 0.99;
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        [recognizer.view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    }
}

#pragma mark - POPAnimationDelegate

- (void)pop_animationDidApply:(POPDecayAnimation *)anim
{
    CGPoint currentVelocity = [anim.velocity CGPointValue];
    BOOL flag = self.frame.origin.x <= -20
                || self.frame.origin.x + self.frame.size.width >= self.superview.frame.size.width + 20
                || self.frame.origin.y + self.frame.size.height >= self.superview.frame.size.height + 20
                || fabs(currentVelocity.y) < 100;
    if (flag) {
        [self.layer pop_removeAllAnimations];
    }
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    if ([anim isKindOfClass:[POPDecayAnimation class]]) {
        
        CGPoint currentVelocity = [((POPDecayAnimation *)anim).velocity CGPointValue];
//        CGPoint velocity = CGPointMake(currentVelocity.x, -currentVelocity.y);
        POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
//        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        if (self.center.y < 0) {
            positionAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(currentVelocity.x, currentVelocity.y)];
            positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, - self.frame.size.height / 2)];
            positionAnimation.completionBlock = ^void(POPAnimation *anim,BOOL completed) {
                // Create the transaction
                [self.delegate createTransactionWithMessage:self.message];
                [self removeFromSuperview];
            };
        } else {
            positionAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(currentVelocity.x, -currentVelocity.y)];
            positionAnimation.toValue = [NSValue valueWithCGPoint:self.initialCenter];
            positionAnimation.completionBlock = ^void(POPAnimation *anim,BOOL completed) {
                [self setStaticUI];
            };
        }
        [self.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    }
}

@end
