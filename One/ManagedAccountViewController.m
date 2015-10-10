//
//  ManagedAccountViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import "ApiManager.h"

#import "AccountCardViewController.h"
#import "ManagedAccountViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "IPUtils.h"
#import "OneLogger.h"
#import "TrackingUtils.h"

@interface ManagedAccountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (nonatomic) BOOL isIndividual;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *businessNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *entityTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthTextfield;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;

@end

@implementation ManagedAccountViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.isIndividual = YES;
    
    // wording
    self.titleLabel.text = NSLocalizedString(@"managed_account_title", nil);
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    [self.entityTypeSegmentedControl setTitle:NSLocalizedString(@"individual_segment", nil) forSegmentAtIndex:0];
    [self.entityTypeSegmentedControl setTitle:NSLocalizedString(@"company_segment", nil) forSegmentAtIndex:1];
    self.firstNameTextField.placeholder = NSLocalizedString(@"first_name_placeholder", nil);
    self.lastNameTextField.placeholder = NSLocalizedString(@"last_name_placeholder", nil);
    self.businessNameTextField.placeholder = NSLocalizedString(@"business_name_placeholder", nil);
    NSString *terms = NSLocalizedString(@"stripe_connected_account", nil);
    NSString *completeString = [NSString stringWithFormat:NSLocalizedString(@"stripe_terms_label", nil),terms];
    [self.registerButton setTitle:NSLocalizedString(@"register_for_cashout", nil) forState:UIControlStateNormal];
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:completeString];
    NSDictionary *attribute = @{NSForegroundColorAttributeName : [ColorUtils mainGreen]};
    [attrString addAttributes:attribute range:[completeString rangeOfString:terms]];
    self.termsLabel.textColor = [ColorUtils lightBlack];
    self.termsLabel.attributedText = attrString;
    self.termsLabel.numberOfLines = 0;
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:15];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.entityTypeSegmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.entityTypeSegmentedControl.layer.cornerRadius = self.entityTypeSegmentedControl.frame.size.height / 2;
    self.entityTypeSegmentedControl.clipsToBounds = YES;
    self.entityTypeSegmentedControl.layer.borderColor = [UIColor whiteColor].CGColor;
    self.entityTypeSegmentedControl.layer.borderWidth = 1.0f;
    [DesignUtils addBottomBorder:self.firstNameTextField borderSize:0.5f color:[ColorUtils veryLightBlack]];
    [self.firstNameTextField setValue:[ColorUtils lightBlack] forKeyPath:@"_placeholderLabel.textColor"];
    [DesignUtils addBottomBorder:self.lastNameTextField borderSize:0.5f color:[ColorUtils veryLightBlack]];
    [self.lastNameTextField setValue:[ColorUtils lightBlack] forKeyPath:@"_placeholderLabel.textColor"];
    [DesignUtils addBottomBorder:self.dayTextField borderSize:0.5f color:[ColorUtils veryLightBlack]];
    [self.dayTextField setValue:[ColorUtils lightBlack] forKeyPath:@"_placeholderLabel.textColor"];
    [DesignUtils addBottomBorder:self.monthTextfield borderSize:0.5f color:[ColorUtils veryLightBlack]];
    [self.monthTextfield setValue:[ColorUtils lightBlack] forKeyPath:@"_placeholderLabel.textColor"];
    [DesignUtils addBottomBorder:self.yearTextField borderSize:0.5f color:[ColorUtils veryLightBlack]];
    [self.yearTextField setValue:[ColorUtils lightBlack] forKeyPath:@"_placeholderLabel.textColor"];
    [DesignUtils addBottomBorder:self.businessNameTextField borderSize:0.5f color:[ColorUtils veryLightBlack]];
    [self.businessNameTextField setValue:[ColorUtils lightBlack] forKeyPath:@"_placeholderLabel.textColor"];
    self.registerButton.layer.cornerRadius = self.registerButton.frame.size.height / 2;
    self.registerButton.backgroundColor = [ColorUtils mainGreen];

    // Delegate
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.businessNameTextField.delegate = self;
    self.dayTextField.delegate = self;
    self.monthTextfield.delegate = self;
    self.yearTextField.delegate = self;
    
    // Tap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponders)];
    [self.view addGestureRecognizer:tapGesture];
    UITapGestureRecognizer *termsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTerms)];
    [self.termsLabel addGestureRecognizer:termsTapGesture];
    self.termsLabel.userInteractionEnabled = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"AccountCard From Managed"]) {
        ((AccountCardViewController *) [segue destinationViewController]).delegate = (id<AccountCardVCProtocol>)self.delegate;
    }
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self.delegate returnToBalanceController];
}

- (IBAction)entityTypeChanged:(id)sender {
    self.isIndividual = self.entityTypeSegmentedControl.selectedSegmentIndex == 0;
}

- (IBAction)registerButtonClicked:(id)sender
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"isIndividual"] = [NSNumber numberWithBool:self.isIndividual];
    if (self.isIndividual) {
        if (self.firstNameTextField.text.length == 0) {
            [GeneralUtils showAlertWithTitle:nil andMessage:NSLocalizedString(@"no_first_name_message", nil)];
            [self.firstNameTextField becomeFirstResponder];
            return;
        } else if (self.lastNameTextField.text.length == 0) {
            [GeneralUtils showAlertWithTitle:nil andMessage:NSLocalizedString(@"no_last_name_message", nil)];
            [self.lastNameTextField becomeFirstResponder];
            return;
        }
        parameters[@"firstName"] = self.firstNameTextField.text;
        parameters[@"lastName"] = self.lastNameTextField.text;
    } else {
        if (self.businessNameTextField.text.length == 0) {
            [GeneralUtils showAlertWithTitle:nil andMessage:NSLocalizedString(@"no_company_name_message", nil)];
            [self.businessNameTextField becomeFirstResponder];
            return;
        }
        parameters[@"businessName"] = self.businessNameTextField.text;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:[self.yearTextField.text integerValue]];
    [components setMonth:[self.monthTextfield.text integerValue]];
    [components setDay:[self.dayTextField.text integerValue]];
    NSDate *date = [calendar dateFromComponents:components];
    if (!date || [date compare:[NSDate date]] == NSOrderedDescending || self.yearTextField.text.length != 4 || self.monthTextfield.text.length > 2 || self.dayTextField.text.length > 2) {
        [GeneralUtils showAlertWithTitle:nil andMessage:NSLocalizedString(@"invalid_date", nil)];
        [self.monthTextfield becomeFirstResponder];
        self.dayTextField.text = @"";
        self.monthTextfield.text = @"";
        self.yearTextField.text = @"";
        return;
    }
    
    parameters[@"birthDay"] = self.dayTextField.text;
    parameters[@"birthMonth"] = self.monthTextfield.text;
    parameters[@"birthYear"] = self.yearTextField.text;

    // Add ip
    parameters[@"iP"] = [IPUtils getIPAddress:YES];
    
    // Create account
    [DesignUtils showProgressHUDAddedTo:self.view];
    [ApiManager createManageAccountWithParameters:parameters
                                          success:^{
                                              [DesignUtils hideProgressHUDForView:self.view];
                                              [TrackingUtils trackEvent:EVENT_CREATE_CASHOUT properties:parameters];
                                              [self performSegueWithIdentifier:@"AccountCard From Managed" sender:nil];
                                          } failure:^(NSError *error) {
                                              [TrackingUtils trackEvent:EVENT_CREATE_CASHOUT_FAIL properties:nil];
                                              [DesignUtils hideProgressHUDForView:self.view];
                                              [GeneralUtils showAlertWithTitle:NSLocalizedString(@"unexpected_error_title", nil) andMessage:NSLocalizedString(@"unexpected_error_message", nil)];
                                          }];
}

- (void)resignResponders {
    [self.view endEditing:YES];
}

// Redirect to terms webpage
- (void)tapOnTerms {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kStripeWebsiteTermsLink]];
}

// --------------------------------------------
#pragma mark - Helpers
// --------------------------------------------
- (void)setIsIndividual:(BOOL)isIndividual {
    _isIndividual = isIndividual;
    
    self.firstNameTextField.hidden = !isIndividual;
    self.lastNameTextField.hidden = !isIndividual;
    self.businessNameTextField.hidden = isIndividual;
    
    if (isIndividual) {
        self.birthdateLabel.text = NSLocalizedString(@"birth_date", nil);
        [self.firstNameTextField becomeFirstResponder];
    } else {
        self.birthdateLabel.text = NSLocalizedString(@"inception_date", nil);
        [self.businessNameTextField becomeFirstResponder];
    }
}

// --------------------------------------------
#pragma mark - Textfield delegate
// --------------------------------------------

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        if (self.firstNameTextField.isFirstResponder) {
            [self.lastNameTextField becomeFirstResponder];
        } else if (self.lastNameTextField.isFirstResponder || self.businessNameTextField.isFirstResponder) {
            [self.monthTextfield becomeFirstResponder];
        } else if (self.monthTextfield.isFirstResponder && self.monthTextfield.text.length == 2) {
            [self.dayTextField becomeFirstResponder];
        } else if (self.dayTextField.isFirstResponder && self.dayTextField.text.length == 2) {
            [self.yearTextField becomeFirstResponder];
        } else if (self.yearTextField.isFirstResponder && self.yearTextField.text.length == 4) {
            [self iphone4MoveViewDown];
            [self.yearTextField resignFirstResponder];
        }
    } else {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (self.monthTextfield.isFirstResponder && self.monthTextfield.text.length == 2) {
            [self.dayTextField becomeFirstResponder];
        } else if (self.dayTextField.isFirstResponder && self.dayTextField.text.length == 2) {
            [self.yearTextField becomeFirstResponder];
        } else if (self.yearTextField.isFirstResponder && self.yearTextField.text.length == 4) {
            [self iphone4MoveViewDown];
            [self.yearTextField resignFirstResponder];
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.monthTextfield || textField == self.dayTextField|| textField == self.yearTextField) {
        [self iphone4MoveViewUp];
    } else {
        [self iphone4MoveViewDown];
    }
}

- (void)iphone4MoveViewUp {
    if (IS_IPHONE_4_OR_LESS) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, -80, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)iphone4MoveViewDown {
    if (IS_IPHONE_4_OR_LESS) {
        self.view.frame = CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height);
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
