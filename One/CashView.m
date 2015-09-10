//
//  CashView.m
//  One
//
//  Created by Baptiste Truchot on 9/6/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "CashView.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "OneLogger.h"


#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface CashView()
@property (weak, nonatomic) IBOutlet UILabel *centralLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftUpOne;
@property (weak, nonatomic) IBOutlet UILabel *rightUpOne;
@property (weak, nonatomic) IBOutlet UILabel *leftBottomOne;
@property (weak, nonatomic) IBOutlet UILabel *rightBottomOne;
@property (nonatomic) CGPoint initialCenter;
@end

@implementation CashView

- (void)initWithFrame:(CGRect)frame andDelegate:(id<CashViewDelegateProtocol>)delegate {
    [self setFrame:frame];
    self.delegate = delegate;
    self.initialCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    // UI
    [self setStaticUI];
    self.centralLabel.textColor = [ColorUtils darkGreen];
    self.centralLabel.adjustsFontSizeToFitWidth = YES;
    self.centralLabel.clipsToBounds = YES;
    self.leftUpOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    self.leftUpOne.textColor = [ColorUtils mainGreen];
    self.rightUpOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(+90));
    self.rightUpOne.textColor = [ColorUtils mainGreen];
    self.leftBottomOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    self.leftBottomOne.textColor = [ColorUtils mainGreen];
    self.rightBottomOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(+90));
    self.rightBottomOne.textColor = [ColorUtils mainGreen];
    self.messageTextField.backgroundColor = [ColorUtils mainGreen];
    self.messageTextField.placeholder = NSLocalizedString(@"message_placeholder", nil);
    self.messageTextField.clipsToBounds = YES;
    self.messageTextField.delegate = self;
    self.messageTextField.layer.cornerRadius = self.messageTextField.frame.size.height / 2;
    self.messageTextField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    
    // Pan Gesture
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    [self addGestureRecognizer:recognizer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // UI
    self.layer.cornerRadius = self.frame.size.height / 40;
    self.centralLabel.layer.cornerRadius = 2./6. * frame.size.width;
}


// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (void)setStaticUI {
    self.messageTextField.hidden = NO;
    self.backgroundColor = [ColorUtils darkGreen];
    self.centralLabel.backgroundColor = [ColorUtils mainGreen];
}

- (void)setMovingUI {
    self.messageTextField.hidden = self.messageTextField.text.length == 0;
    self.backgroundColor = [ColorUtils veryLightGreen];
    self.centralLabel.backgroundColor = [ColorUtils lightGreen];
    [self.delegate adaptUIToCashViewState:YES];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)viewTouchedUp:(id)sender {
    if (CGPointEqualToPoint(self.initialCenter, self.center)) {
        [self setStaticUI];
        [self.delegate adaptUIToCashViewState:NO];
    }
}

- (IBAction)viewTouchedDown:(id)sender {
    [self.messageTextField resignFirstResponder];
    [self setMovingUI];
    if (CGPointEqualToPoint(self.center, self.initialCenter)) {
        [self.layer pop_removeAllAnimations];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.superview];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self setMovingUI];
    }
    if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        CGPoint velocity = [recognizer velocityInView:self.superview];
        POPDecayAnimation *positionAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.delegate = self;
        positionAnimation.deceleration = 0.992;
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        [recognizer.view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    }
}


// --------------------------------------------
#pragma mark - POPAnimationDelegate
// --------------------------------------------

- (void)pop_animationDidApply:(POPDecayAnimation *)anim
{
    CGPoint currentVelocity = [anim.velocity CGPointValue];
    BOOL flag = self.frame.origin.x <= -50
                || self.frame.origin.x + self.frame.size.width >= self.superview.frame.size.width + 50
                || self.frame.origin.y + self.frame.size.height >= self.superview.frame.size.height + 20
                || self.frame.origin.x + self.frame.size.height <= 0
                || fabs(currentVelocity.y) < 200;
    if (flag) {
        [self.layer pop_removeAllAnimations];
    }
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    OneLog(LOCALLOGENABLED,@"anim did stop");
    if ([anim isKindOfClass:[POPDecayAnimation class]]) {
        if (self.center.y < 0) {
            CGFloat xDirection = self.center.x + (self.center.x - self.initialCenter.x) / (self.center.y - self.initialCenter.y) * (-self.frame.size.height- self.center.y);
            [self moveViewToPoint:CGPointMake(xDirection, -self.frame.size.height)
                         velocity:CGPointMake(100, 100)
                       completion:^void(POPAnimation *anim,BOOL completed) {
                           // Create the transaction
                           [self.delegate createTransactionWithCashView:self];
            }];
            [self.delegate adaptUIToCashViewState:NO];
        } else {
            [self moveViewToCenterAndExecute:^void(POPAnimation *anim,BOOL completed) {
                [self.delegate adaptUIToCashViewState:NO];
                [self setStaticUI];
            }];
        }
    }
}

- (void)moveViewToPoint:(CGPoint)point velocity:(CGPoint)velocity completion:(void(^)(POPAnimation *anim,BOOL completed))completionBlock {
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
    positionAnimation.springBounciness = 10;
    positionAnimation.toValue = [NSValue valueWithCGPoint:point];
    positionAnimation.completionBlock = completionBlock;
    [self.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
}

- (void)moveViewToCenterAndExecute:(void(^)(POPAnimation *anim,BOOL completed))completionBlock
{
    OneLog(LOCALLOGENABLED,@"Come back to center");
    [self moveViewToPoint:self.initialCenter velocity:CGPointMake(100, 100) completion:^void(POPAnimation *anim,BOOL completed) {
        [self setStaticUI];
        if (completionBlock) {
            completionBlock(anim, completed);
        }
    }];
}


// --------------------------------------------
#pragma mark - UITextField delegate
// --------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self.messageTextField resignFirstResponder];
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > kMaxMessagesLength)
        return NO;
    textField.text = newString;
    [textField layoutSubviews];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.isEditingMessage = YES;
}

@end
