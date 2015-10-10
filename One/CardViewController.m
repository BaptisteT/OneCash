//
//  CardViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <Stripe.h>

#import "ApiManager.h"
#import "User.h"

#import "CardViewController.h"
#import "SendCashViewController.h"
#import "HowToViewController.h"

#import "ColorUtils.h"  
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "TrackingUtils.h"

@interface CardViewController () 
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
@property (weak, nonatomic) IBOutlet UIButton *manualPayButton;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *howToButton;

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
    [self.applePayButton setTitle:NSLocalizedString(@"apple_pay_button_title", nil) forState:UIControlStateNormal];
    [self.applePayButton setTitleColor:[ColorUtils lightBlack] forState:UIControlStateNormal];
    [self.manualPayButton setTitle:NSLocalizedString(@"manual_pay_button_title", nil) forState:UIControlStateNormal];
    [self.manualPayButton setTitleColor:[ColorUtils lightBlack] forState:UIControlStateNormal];
    self.explanationLabel.text = NSLocalizedString(@"card_choice_explanation", nil);
    self.topLabel.text = NSLocalizedString(@"top_bar_payment", nil);
    
    // UI
    self.howToButton.layer.cornerRadius = self.howToButton.frame.size.height / 2;
    [self.howToButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    [self.howToButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    self.explanationLabel.numberOfLines = 0;
    self.explanationLabel.textColor = [ColorUtils lightBlack];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DesignUtils addBottomBorder:self.applePayButton borderSize:0.5 color:[ColorUtils veryLightBlack]];
    [DesignUtils addBottomBorder:self.manualPayButton borderSize:0.5 color:[ColorUtils veryLightBlack]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Stripe From Card"]) {
        ((CardViewController *) [segue destinationViewController]).redirectionViewController = self.redirectionViewController;
    }
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)skipButtonClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_CARD_LATER_CLICKED properties:nil];
    [self navigateToSend];
}

- (IBAction)applePayClicked:(id)sender {
    BOOL enabled = [self applePayEnabled];
    [TrackingUtils trackEvent:EVENT_APPLE_PAY_CLICKED properties:@{@"enabled": [NSNumber numberWithBool:enabled]}];
    if (!enabled) {
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"apple_pay_unavailable_error_title", nil) andMessage:NSLocalizedString(@"apple_pay_unavailable_error_message", nil)];
        return;
    } else {
        [User currentUser].paymentMethod = kPaymentMethodApplePay;
        [DesignUtils showProgressHUDAddedTo:self.view];
        [ApiManager saveCurrentUserAndExecuteSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [DesignUtils hideProgressHUDForView:self.view];
                [self navigateToSend];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DesignUtils hideProgressHUDForView:self.view];
                [GeneralUtils showAlertWithTitle:NSLocalizedString(@"unexpected_error_title", nil) andMessage:NSLocalizedString(@"unexpected_error_message", nil)];
            });
        }];
    }
}

- (IBAction)manualCardClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_STRIPE_CLICKED properties:nil];
    [self performSegueWithIdentifier:@"Stripe From Card" sender:nil];
}

- (void)navigateToSend {
    if (self.redirectionViewController && [self.redirectionViewController isKindOfClass:[SendCashViewController class]]) {
        [self.navigationController popToViewController:self.redirectionViewController animated:YES];
    } else {
        [self performSegueWithIdentifier:@"Send From Card" sender:nil];
    }
}

- (IBAction)howToButtonClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_HOW_TO properties:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"HowToVC"];
    [self presentViewController:vc animated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - Apple pay
// --------------------------------------------

- (BOOL)applePayEnabled {
    if ([PKPaymentRequest class]) {
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:kApplePayMerchantId];
        paymentRequest.currencyCode = @"USD";
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
