//
//  CardViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <Stripe.h>

#import "CardViewController.h"

#import "ColorUtils.h"  
#import "ConstantUtils.h"

@interface CardViewController ()
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
@property (weak, nonatomic) IBOutlet UIButton *manualPayButton;

@end

@implementation CardViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // wording
    [self.skipButton setTitle:NSLocalizedString(@"later_", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"card_title", nil);
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils lightGreen];
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)skipButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Send From Card" sender:nil];
}

- (IBAction)applePayClicked:(id)sender {
    if (![self applePayEnabled]) {
        // todo BT
        // alert user
        return;
    }
    [self performSegueWithIdentifier:@"Send From Card" sender:nil];
}

- (IBAction)manualCardClicked:(id)sender {
    [self performSegueWithIdentifier:@"Stripe From Card" sender:nil];
}


// --------------------------------------------
#pragma mark - Apple pay
// --------------------------------------------

- (BOOL)applePayEnabled {
    if ([PKPaymentRequest class]) {
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:kApplePayMerchantId];
        return [Stripe canSubmitPaymentRequest:paymentRequest];
    }
    return NO;
}


// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
// Set status bar color to white
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
