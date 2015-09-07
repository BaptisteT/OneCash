//
//  StripeCardViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <Stripe.h>

#import "ApiManager.h"

#import "SendCashViewController.h"  
#import "StripeCardViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "OneLogger.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface StripeCardViewController () <STPPaymentCardTextFieldDelegate>

@property(nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation StripeCardViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Wording
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"done_button", nil) forState:UIControlStateNormal];
    self.topLabel.text = NSLocalizedString(@"stripe_card_title", nil);
    
    // UI
    self.topLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    self.doneButton.backgroundColor = [ColorUtils mainGreen];
    self.doneButton.layer.cornerRadius = self.doneButton.frame.size.height / 2;
    self.doneButton.enabled = NO;
    
    // Payment Textfield
    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, self.doneButton.frame.origin.y - 44 - 30, CGRectGetWidth(self.view.frame) - 30, 44)];
    self.paymentTextField.delegate = self;
    [self.view addSubview:self.paymentTextField];
    [self.paymentTextField becomeFirstResponder];
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField 
{
    self.doneButton.enabled = textField.isValid;
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender {
    if (![self.paymentTextField isValid]) {
        return;
    }

    [DesignUtils showProgressHUDAddedTo:self.view];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentTextField.cardNumber;
    card.expMonth = self.paymentTextField.expirationMonth;
    card.expYear = self.paymentTextField.expirationYear;
    card.cvc = self.paymentTextField.cvc;
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  OneLog(LOCALLOGENABLED,@"FAILURE - create token with card - %@",error.description);
                                                  [DesignUtils hideProgressHUDForView:self.view];
                                                  [GeneralUtils showAlertWithTitle:NSLocalizedString(@"create_token_with_card_error_title", nil) andMessage:NSLocalizedString(@"create_token_with_card_error_message", nil)];
                                                  [self.paymentTextField clear];
                                                  return;
                                              }
                                              
                                              [self sendTokenToServer:token];
                                          }];
}

- (void)sendTokenToServer:(STPToken *)token
{
    [ApiManager createStripeCustomerWithToken:token.tokenId
                                paymentMethod:kPaymentMethodStripe
                                      success:^{
                                          [ApiManager fetchCurrentUserAndExecuteSuccess:nil failure:nil];
                                          [DesignUtils hideProgressHUDForView:self.view];
                                          [self navigateToSend];
                                      } failure:^(NSError *error) {
                                          [DesignUtils hideProgressHUDForView:self.view];
                                          // todo BT
                                          // warm user
                                      }];
}

- (void)navigateToSend {
    if (self.redirectionViewController && [self.redirectionViewController isKindOfClass:[SendCashViewController class]]) {
        [self.navigationController popToViewController:self.redirectionViewController animated:YES];
    } else {
        [self performSegueWithIdentifier:@"Send From Stripe" sender:nil];
    }
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
