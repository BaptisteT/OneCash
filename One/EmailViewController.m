//
//  EmailViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "NSString+EmailAddresses.h"
#import "SHEmailValidator.h"

#import "ApiManager.h"
#import "User.h"

#import "EmailViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "OneLogger.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface EmailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end

@implementation EmailViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // wording
    self.titleLabel.text = NSLocalizedString(@"email_title_label", nil);
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    [self.validateButton setTitle:NSLocalizedString(@"done_button", nil) forState:UIControlStateNormal];
    NSString *terms = NSLocalizedString(@"terms_of_services", nil);
    NSString *privacy = NSLocalizedString(@"privacy_policy", nil);
    NSString *completeString = [NSString stringWithFormat:NSLocalizedString(@"terms_label", nil),terms,privacy];
    
    // UI
    self.titleLabel.numberOfLines = 0;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:completeString];
    NSDictionary *attribute = @{NSForegroundColorAttributeName : [ColorUtils lightGreen]};
    [attrString addAttributes:attribute range:[completeString rangeOfString:terms]];
    [attrString addAttributes:attribute range:[completeString rangeOfString:privacy]];
    self.termsLabel.textColor = [UIColor lightGrayColor];
    self.termsLabel.attributedText = attrString;
    self.termsLabel.numberOfLines = 0;
    self.validateButton.backgroundColor = [ColorUtils lightGreen];
    self.validateButton.layer.cornerRadius = self.validateButton.frame.size.height / 2;
    self.topView.backgroundColor = [ColorUtils lightGreen];
    [DesignUtils addBottomBorder:self.emailTextField borderSize:0.5 color:[UIColor lightGrayColor]];
    
    // Gesture
    UITapGestureRecognizer *termsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTerms)];
    [self.termsLabel addGestureRecognizer:termsTap];
    
    // First responder
    self.emailTextField.delegate = self;
    [self.emailTextField becomeFirstResponder];
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)backButtonClicked:(id)sender {
    [User logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

// Save user email (& other info - not saved) and move on
- (IBAction)validateButtonClicked:(id)sender {
    // Validate email
    NSError *error = nil;
    NSString *email = [self.emailTextField.text stringByCorrectingEmailTypos];
    [[SHEmailValidator validator] validateSyntaxOfEmailAddress:email withError:&error];
    if (error) {
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"invalid_email_title", nil) andMessage:NSLocalizedString(@"invalid_email_message", nil)];
        return;
    }
    [self.emailTextField resignFirstResponder];
    
    // save user
    [DesignUtils showProgressHUDAddedTo:self.view];
    [ApiManager updateCurrentUserInfo:email
                              success:^{
                                  [DesignUtils hideProgressHUDForView:self.view];
                                  [self performSegueWithIdentifier:@"Card From Email" sender:nil];
                              } failure:^(NSError *error) {
                                  [DesignUtils hideProgressHUDForView:self.view];
                                  [GeneralUtils showAlertWithTitle:NSLocalizedString(@"save_email_error_title", nil) andMessage:NSLocalizedString(@"save_email_error_message", nil)];
                              }];
}

// Redirect to terms webpage
- (void)tapOnTerms {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kOneWebsiteTermsLink]];
}

// --------------------------------------------
#pragma mark - Textfield delegate
// --------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self validateButtonClicked:nil];
        return NO;
    }
    return YES;
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
