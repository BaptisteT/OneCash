//
//  AccountCardViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import <Stripe.h>

#import "ApiManager.h"

#import "AccountCardViewController.h"

#import "ColorUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "KeyboardUtils.h"
#import "TrackingUtils.h"

@interface AccountCardViewController ()<STPPaymentCardTextFieldDelegate>

@property(strong, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (strong, nonatomic) UIButton *addCardButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *cardTableView;
@property (strong, nonatomic) NSDictionary *managedAccountDictionnary;
@property (strong, nonatomic) NSArray *accounts;

@end

@implementation AccountCardViewController {
    BOOL _showCardTextField;
}

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    _showCardTextField = NO;
    
    // wording
    self.titleLabel.text = NSLocalizedString(@"acount_card_title", nil);
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    
    // table view
    self.cardTableView.delegate = self;
    self.cardTableView.dataSource = self;
    self.cardTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Payment Textfield
    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 10, CGRectGetWidth(self.view.frame) - 60, 40)];
    self.paymentTextField.delegate = self;
    self.addCardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 40, 15, 30, 30)];
    self.addCardButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.addCardButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    [self.addCardButton addTarget:self action:@selector(generateTokenAndCreateCard) forControlEvents:UIControlEventTouchUpInside];
    
    // Get accounts
    [DesignUtils showProgressHUDAddedTo:self.view withColor:[ColorUtils mainGreen] transform:CGAffineTransformIdentity userInteraction:YES];
    [self getManagedAccountAndExecuteSuccess:^{
        [DesignUtils hideProgressHUDForView:self.view];
    } failureBlock:^(NSError *error) {
        [DesignUtils hideProgressHUDForView:self.view];
    }];
    
    // Keyboard Observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cardTableView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self.delegate returnToBalanceController];
}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField
{
    self.addCardButton.hidden = !textField.isValid;
}

// --------------------------------------------
#pragma mark - TableView
// --------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",self.accounts[indexPath.row][@"last4"]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"add_a_card", nil);
        } else {
            [cell addSubview:self.paymentTextField];
            [cell addSubview:self.addCardButton];
            self.addCardButton.hidden = !self.paymentTextField.isValid;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.accounts.count;
    } else {
        return 1 + (_showCardTextField ? 1 : 0);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary *card = self.accounts[indexPath.row];
        if (![card[@"default_for_currency"] boolValue]) {
            // set as default
            [DesignUtils showProgressHUDAddedTo:self.view];
            [ApiManager setCardAsDefaultInManagedAccount:card[@"id"] success:^{
                [self getManagedAccountAndExecuteSuccess:nil failureBlock:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DesignUtils hideProgressHUDForView:self.view];
                    [self checkVerificationAndShowConfirmationAlert];
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DesignUtils hideProgressHUDForView:self.view];
                    [GeneralUtils showAlertWithTitle:NSLocalizedString(@"unexpected_error_title", nil) andMessage:NSLocalizedString(@"unexpected_error_message", nil)];
                });
            }];
        } else {
            [self checkVerificationAndShowConfirmationAlert];
        }
    } else {
        if (indexPath.row == 0) {
            if (!_showCardTextField) {
                _showCardTextField = YES;
                [self.cardTableView reloadData];
                [self.paymentTextField becomeFirstResponder];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// --------------------------------------------
#pragma mark - Card / Account
// --------------------------------------------
- (void)generateTokenAndCreateCard {
    if (![self.paymentTextField isValid]) {
        return;
    }
    [self.paymentTextField resignFirstResponder];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentTextField.cardNumber;
    card.expMonth = self.paymentTextField.expirationMonth;
    card.expYear = self.paymentTextField.expirationYear;
    card.cvc = self.paymentTextField.cvc;
    card.currency = @"usd";
    
    [DesignUtils showProgressHUDAddedTo:self.view];
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [TrackingUtils trackEvent:EVENT_STRIPE_CREATE_TOKEN_WITH_CARD properties:@{@"success" : [NSNumber numberWithBool:(error == nil)]}];
                                                  if (error) {
                                                      [DesignUtils hideProgressHUDForView:self.view];
                                                      [GeneralUtils showAlertWithTitle:NSLocalizedString(@"create_token_with_card_error_title", nil) andMessage:error.localizedDescription];
                                                      [self.paymentTextField clear];
                                                      return;
                                                  }
                                                  [self addCardToAccount:token.tokenId];
                                              });
                                          }];
}

- (void)addCardToAccount:(NSString *)token {
    [ApiManager addCardToManadedAccount:token
                                success:^{
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [DesignUtils hideProgressHUDForView:self.view];
                                        [self.paymentTextField clear];
                                        [self getManagedAccountAndExecuteSuccess:^{
                                            [self checkVerificationAndShowConfirmationAlert];
                                        } failureBlock:nil];
                                    });
                                } failure:^(NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [DesignUtils hideProgressHUDForView:self.view];
                                        NSString *errorDesc = [error.userInfo valueForKey:@"error"];
                                        BOOL showStandardError = YES;
                                        if ([errorDesc containsString:@"stripeMessage"]) {
                                            NSError *jsonError;
                                            NSData *objectData = [errorDesc dataUsingEncoding:NSUTF8StringEncoding];
                                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                                 options:NSJSONReadingMutableContainers
                                                                                                   error:&jsonError];
                                            if ([json valueForKey:@"stripeMessage"]) {
                                                showStandardError = NO;
                                                [GeneralUtils showAlertWithTitle:NSLocalizedString(@"create_stripe_customer_error_title", nil) andMessage:[json valueForKey:@"stripeMessage"]];
                                            }
                                        }
                                        
                                        if (showStandardError) {
                                            [GeneralUtils showAlertWithTitle:NSLocalizedString(@"unexpected_error_title", nil) andMessage:NSLocalizedString(@"unexpected_error_message", nil)];
                                        }
                                    });
                                }];
}

- (void)checkVerificationAndShowConfirmationAlert {
    if (![self.managedAccountDictionnary[@"transfers_enabled"] boolValue]) {
        [ApiManager alertByEmailWithParams:@{@"type":@"transfers disabled", @"userId":[User currentUser].objectId} success:nil failure:nil];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"transfers_disabled_title", nil)
                                    message:[NSString stringWithFormat:NSLocalizedString(@"transfers_disabled_message", nil),[User currentUser].balance]
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                          otherButtonTitles:nil] show];
    } else {
        // Confirmation alert
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_cashout_title", nil)
                                    message:[NSString stringWithFormat:NSLocalizedString(@"confirm_cashout_message", nil),[User currentUser].balance]
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"cancel_button", nil)
                          otherButtonTitles:NSLocalizedString(@"confirm_cashout_button", nil), nil] show];
    }
}
                                                   

- (void)getManagedAccountAndExecuteSuccess:(void(^)())successBlock
                              failureBlock:(void(^)(NSError *error))failureBlock
{
    [ApiManager getManageAccountAndExecuteSuccess:^(NSDictionary *managedAccount) {
        self.managedAccountDictionnary = managedAccount;
        self.accounts = managedAccount[@"external_accounts"][@"data"];
        [self.cardTableView reloadData];
        if (successBlock) {
            successBlock();
        }
    }failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

// --------------------------------------------
#pragma mark - Alertview
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:NSLocalizedString(@"confirm_cashout_title", nil)] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"confirm_cashout_button", nil)]) {
        [DesignUtils showProgressHUDAddedTo:self.view];
        [ApiManager createCashoutAndExecuteSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [DesignUtils hideProgressHUDForView:self.view];
                [self.delegate returnToBalanceController];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DesignUtils hideProgressHUDForView:self.view];
                [GeneralUtils showAlertWithTitle:NSLocalizedString(@"cashout_error_title", nil) andMessage:NSLocalizedString(@"cashout_error_message", nil)];
            });
        }];
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"transfers_disabled_title", nil)]) {
        [self.delegate returnToBalanceController];
    }
}


// ----------------------------------------------------------
#pragma mark Keyboard
// ----------------------------------------------------------
// Move up create comment view on keyboard will show
- (void)keyboardWillShow:(NSNotification *)notification {
    [KeyboardUtils changeFrameOfView:self.cardTableView whenKeyboardMoveNotification:notification];
}

// Move down create comment view on keyboard will hide
- (void)keyboardWillHide:(NSNotification *)notification {
    [KeyboardUtils changeFrameOfView:self.cardTableView whenKeyboardMoveNotification:notification];
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
