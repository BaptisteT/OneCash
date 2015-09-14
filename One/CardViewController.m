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

#import "ColorUtils.h"  
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"

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
    [self.applePayButton setTitle:NSLocalizedString(@"apple_pay_button_title", nil) forState:UIControlStateNormal];
    [self.manualPayButton setTitle:NSLocalizedString(@"manual_pay_button_title", nil) forState:UIControlStateNormal];
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DesignUtils addBottomBorder:self.applePayButton borderSize:0.5 color:[UIColor lightGrayColor]];
    [DesignUtils addBottomBorder:self.manualPayButton borderSize:0.5 color:[UIColor lightGrayColor]];
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
    [self navigateToSend];
}

- (IBAction)applePayClicked:(id)sender {
    if (![self applePayEnabled]) {
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"apple_pay_unavailable_error_title", nil) andMessage:NSLocalizedString(@"apple_pay_unavailable_error_title", nil)];
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
    [self performSegueWithIdentifier:@"Stripe From Card" sender:nil];
}

- (void)navigateToSend {
    if (self.redirectionViewController && [self.redirectionViewController isKindOfClass:[SendCashViewController class]]) {
        [self.navigationController popToViewController:self.redirectionViewController animated:YES];
    } else {
        [self performSegueWithIdentifier:@"Send From Card" sender:nil];
    }
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
