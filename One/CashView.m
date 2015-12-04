//
//  CashView.m
//  One
//
//  Created by Baptiste Truchot on 9/6/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import <Foundation/Foundation.h>

#import "DatastoreManager.h"
#import "User.h"

#import "CashView.h"
#import "UIButton+NSCopying.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "OneLogger.h"



#define LOCALLOGENABLED NO && GLOBALLOGENABLED

@interface CashView()

@property (weak, nonatomic) IBOutlet UIButton *customValueButton;
@property (strong, nonatomic) NSArray *defaultValueButtons;
@property (weak, nonatomic) IBOutlet UILabel *centralLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftUpOne;
@property (weak, nonatomic) IBOutlet UILabel *leftBottomOne;
@property (weak, nonatomic) IBOutlet UILabel *rightBottomOne;
@property (strong, nonatomic) IBOutlet UILabel *dollarLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (strong, nonatomic) IBOutlet UIButton *addRecipientButton;
@property (strong, nonatomic) IBOutlet UIButton *removeRecipientButton;
@property (strong, nonatomic) IBOutlet UILabel *onboardingLabel;
@property (strong, nonatomic) UIView *onboardingView;
@property (nonatomic) NSInteger cashValue;

@end

@implementation CashView {
    BOOL _decayAnimEnded;
    CGFloat _messageInitialSize;
}

- (void)initWithFrame:(CGRect)frame initialValue:(NSInteger)value andDelegate:(id<CashViewDelegateProtocol>)delegate {
    [self setFrame:frame];
    self.delegate = delegate;
    self.initialCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _messageInitialSize = self.messageTextField.font.pointSize;
    
    // UI
    [self setStaticUI];
    self.centralLabel.textColor = [ColorUtils darkGreen];
    self.centralLabel.adjustsFontSizeToFitWidth = YES;
    self.centralLabel.clipsToBounds = YES;
    self.userPictureImageView.clipsToBounds = YES;
    self.userPictureImageView.layer.borderColor = [ColorUtils darkGreen].CGColor;
    self.userPictureImageView.layer.borderWidth = 10.f;
    self.overlayView.hidden = YES;
    self.usernameLabel.hidden = YES;
    self.dollarLabel.hidden = YES;
    self.removeRecipientButton.backgroundColor = [ColorUtils darkGreen];
    [self.removeRecipientButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    [self.addRecipientButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.onboardingLabel.textColor = [UIColor whiteColor];
    self.leftUpOne.textColor = [ColorUtils darkGreen];
    self.leftBottomOne.textColor = [ColorUtils darkGreen];
    self.rightBottomOne.textColor = [ColorUtils darkGreen];
    self.messageTextField.backgroundColor = [ColorUtils darkGreen];
    self.messageTextField.placeholder = NSLocalizedString(@"message_placeholder", nil);
    self.messageTextField.clipsToBounds = YES;
    self.messageTextField.delegate = self;
    self.messageTextField.layer.cornerRadius = self.messageTextField.frame.size.height / 2;
    self.messageTextField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.messageTextField setValue:[ColorUtils lightGreen]
                    forKeyPath:@"_placeholderLabel.textColor"];
    [self updateRecipient];
    
    // Cash value
    self.cashValue = value;
    self.customValueButton.layer.cornerRadius = self.customValueButton.layer.frame.size.height / 2;
    [self.customValueButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.customValueButton.backgroundColor = [ColorUtils darkGreen];
    
    // Pan Gesture
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    [self addGestureRecognizer:recognizer];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        if (![view isKindOfClass:[UITextField class]]) {
            view.translatesAutoresizingMaskIntoConstraints = YES;
        }
    }
    
    if (!self.defaultValueButtons) {
        [self initChooseValueButtons];
        [self setCashViewValueAndLabelsTo:self.cashValue];
    }
    
    self.centralLabel.layer.cornerRadius = self.centralLabel.frame.size.height / 2;
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.frame.size.height / 2;
    self.overlayView.layer.cornerRadius = self.userPictureImageView.frame.size.height / 2.2;
    self.removeRecipientButton.layer.cornerRadius = self.removeRecipientButton.frame.size.height / 2;
    
    //Onboarding
    if (![DatastoreManager hasLaunchedOnce:@"CardView"]) {
        self.onboardingView = [DesignUtils createBubbleAboutView:self.centralLabel
                                                        withText:NSLocalizedString(@"pick_recipient_tuto", nil)
                                                        position:kPositionTop
                                                 backgroundColor:[UIColor whiteColor]
                                                       textColor:[ColorUtils mainGreen]];
        [self addSubview:self.onboardingView];
        self.onboardingLabel.hidden = YES;
    }
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (void)setStaticUI {
    self.messageTextField.hidden = NO;
    self.backgroundColor = [ColorUtils mainGreen];
    self.centralLabel.backgroundColor = [ColorUtils darkGreen];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.2;
    self.removeRecipientButton.hidden = ([self.delegate receiver] == nil);
    self.onboardingLabel.hidden = NO;
}

- (void)setMovingUI {
    self.messageTextField.hidden = self.messageTextField.text.length == 0;
    [self.delegate adaptUIToCashViewState:YES];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.2;
    if ([self.delegate receiver] == nil) {
    } else {
        [self updateRecipient];
    }
    self.removeRecipientButton.hidden = YES;
    self.onboardingLabel.hidden = YES;
}

- (BOOL)isAtInitialPosition {
    return pow(self.initialCenter.x - self.center.x,2) + pow(self.initialCenter.y - self.center.y,2) < 0.01;
}

-(void)updateRecipient {
    if ([self.delegate receiver] == nil) {
        self.dollarLabel.hidden = YES;
        self.usernameLabel.hidden = YES;
        self.overlayView.hidden = YES;
        self.userPictureImageView.hidden = YES;
        self.usernameLabel.hidden = YES;
        [self.addRecipientButton setTitle:@"+" forState:UIControlStateNormal];
        self.removeRecipientButton.hidden = YES;
        self.onboardingLabel.text = NSLocalizedString(@"recipient_alert", nil);
    } else {
        [[self.delegate receiver] setAvatarInImageView:self.userPictureImageView bigSize:YES saveLocally:YES];
        self.usernameLabel.text = [self.delegate receiver].caseUsername;
        self.dollarLabel.hidden = NO;
        self.usernameLabel.hidden = NO;
        self.overlayView.hidden = NO;
        self.userPictureImageView.hidden = NO;
        [self.addRecipientButton setTitle:@"" forState:UIControlStateNormal];
        self.removeRecipientButton.hidden = NO;
        self.onboardingLabel.text = NSLocalizedString(@"swipe_label", nil);
    }
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)viewTouchedUp:(id)sender {
    if ([self isAtInitialPosition]) {
        [self setStaticUI];
        [self.delegate adaptUIToCashViewState:NO];
    }
}

- (IBAction)viewTouchedDown:(id)sender {
    [self.messageTextField resignFirstResponder];
    [self setMovingUI];
    if ([self isAtInitialPosition]) {
        [self.layer pop_removeAllAnimations];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.superview];
    
    //slow down translation if recipient is empty or translation.y is positive
    if (translation.y > 0 && self.frame.origin.y > 0) {
        translation.y = translation.y / 10;
    } else if ([self.delegate receiver] == nil) {
        translation.y = -MAX(translation.y / 5,5);
        recognizer.view.center = CGPointMake(recognizer.view.center.x, MAX(recognizer.view.center.y + translation.y, ([[UIScreen mainScreen] bounds].size.height - 20)/2));
    } else {
        recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                             recognizer.view.center.y + translation.y * 1.6);
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.messageTextField resignFirstResponder];
        [self setMovingUI];
        [self setValueButtonsToNonSelectionMode];
        [self.delegate addNewCashSubview];
        CGFloat rads;
        if ([self.delegate receiver] == nil) {
            [self.delegate showPickRecipientAlert];
        } else {
            NSLog(@"%f",translation.y);
            CGFloat factor = MIN(1,fabs(translation.y)/10);
            if (translation.x < 0) {
                rads = 30 * factor;
            } else {
                rads = -30 * factor;
            }
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(rads));
            } completion:nil];
        }
    }

    if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        CGPoint velocity = [recognizer velocityInView:self.superview];
        velocity.x = 0;
        velocity.y = (velocity.y > 0 ? 1 : -1) * MAX(5,fabs(velocity.y)) ;
        POPDecayAnimation *positionAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.delegate = self;
        positionAnimation.deceleration = 0.992;
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        _decayAnimEnded = NO;
        [recognizer.view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
        recognizer.enabled = YES;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

-(IBAction)recipientPressed:(id)sender {
    [self.onboardingView removeFromSuperview];
    self.onboardingLabel.hidden = NO;
    self.onboardingView = nil;
    [self.delegate recipientButtonClicked];
}

-(IBAction)removeRecipientPressed:(id)sender {
    [self.delegate removeRecipientButtonClicked];
}

- (IBAction)valueButtonClicked:(id)sender {
    BOOL selectionState = !CGRectEqualToRect(self.customValueButton.frame,((UIButton *)self.defaultValueButtons.firstObject).frame);
    
    if (selectionState) {
        if ([((UIButton *)sender).titleLabel.text isEqualToString:@"+"]) {
            [self.delegate showCustomValueVC];
        } else {
            NSInteger value = [[((UIButton *)sender).titleLabel.text substringFromIndex:1] intValue];
            [self setCashViewValueAndLabelsTo:value];
            [self.delegate updateCashViewStacksValue:value];
        }
    } else {
        [self.customValueButton setTitle:@"+" forState:UIControlStateNormal];
        [self setValueButtonsToSelectionMode];
    }
}


// --------------------------------------------
#pragma mark - CashView value
// --------------------------------------------
- (void)setCashViewValueAndLabelsTo:(NSInteger)value
{
    self.cashValue = value;
    for (UILabel *label in @[self.leftUpOne, self.leftBottomOne, self.rightBottomOne]) {
        label.text = [NSString stringWithFormat:@"$%lu",(long)value];
    }
    
    [self setValueButtonsToNonSelectionMode];
}

- (void)setValueButtonsToSelectionMode {
    NSInteger index = self.defaultValueButtons.count;
    for (UIButton *button in self.defaultValueButtons) {
        CGRect frame = self.customValueButton.frame;
        frame.origin.x -= index * (button.frame.size.width + 5);
        [UIView animateWithDuration:0.25 animations:^{
            button.frame = frame;
        }];
        index--;
    }
}

- (void)setValueButtonsToNonSelectionMode {
    NSString *selectedButtonTitle = [NSString stringWithFormat:@"$%lu",(long)self.cashValue];
    BOOL customSelected = YES;
    for (UIButton *button in self.defaultValueButtons) {
        [UIView animateWithDuration:0.25 animations:^{
            button.frame = self.customValueButton.frame;
        }];
        if ([button.titleLabel.text isEqualToString:selectedButtonTitle]) {
            [self bringSubviewToFront:button];
            button.backgroundColor = [UIColor whiteColor];
            customSelected = NO;
        } else {
            button.backgroundColor = [ColorUtils darkGreen];
        }
    }
    if (customSelected) {
        [self.customValueButton setTitle:selectedButtonTitle forState:UIControlStateNormal];
        self.customValueButton.backgroundColor = [UIColor whiteColor];
        [self bringSubviewToFront:self.customValueButton];
    } else {
        self.customValueButton.backgroundColor = [ColorUtils darkGreen];
    }
}

- (NSInteger)getCashViewValue {
    return self.cashValue;
}

- (void)initChooseValueButtons {
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *buttonTitle in @[@"$1",@"$5",@"$10"]) {
        UIButton *button = [self.customValueButton copy];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [self insertSubview:button belowSubview:self.customValueButton];
        [array addObject:button];
        [button addTarget:self action:@selector(valueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.defaultValueButtons = array;
}


// --------------------------------------------
#pragma mark - POPAnimationDelegate
// --------------------------------------------

- (void)pop_animationDidApply:(POPDecayAnimation *)anim
{
    CGPoint currentVelocity = [anim.velocity CGPointValue];
    BOOL flag = self.frame.origin.y + self.frame.size.height <= 0
                || fabs(currentVelocity.y) < 100;
    if (flag && !_decayAnimEnded) {
        [self.layer pop_removeAllAnimations];
    }
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    _decayAnimEnded = YES;
    OneLog(LOCALLOGENABLED,@"anim did stop");
    if ([anim isKindOfClass:[POPDecayAnimation class]]) {
        if (self.center.y < 0 && [self.delegate receiver] != nil) {
            CGFloat xDirection = self.center.x + (self.center.x - self.initialCenter.x) / (self.center.y - self.initialCenter.y) * (-self.frame.size.height- self.center.y);
            if (self.frame.origin.y + self.frame.size.height > 0) {
                [self moveViewToPoint:CGPointMake(xDirection, -self.frame.size.height)
                             velocity:CGPointMake(100, 100)
                           completion:^void(POPAnimation *anim,BOOL completed) {
                               // Create the transaction
                               [self.delegate createTransactionWithCashView:self];
                }];
            } else {
                // Create the transaction directly
                [self.delegate createTransactionWithCashView:self];
            }
            [self.delegate adaptUIToCashViewState:NO];
        } else {
            [self.delegate resetCashSubiewsStack];
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
    positionAnimation.springBounciness = 0;
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
    
    // cursor position
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *position = [textField positionFromPosition:beginning offset:range.location + string.length];
    textField.selectedTextRange = [textField textRangeFromPosition:position toPosition:position];
    
    // Font size
    [DesignUtils adjustFontSizeOfTextField:self.messageTextField maxFontSize:_messageInitialSize constraintSize:CGSizeMake(self.frame.size.width - 40,MAXFLOAT)];
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.isEditingMessage = YES;
}

@end
