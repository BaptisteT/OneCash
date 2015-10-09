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
#import "TrackingUtils.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface EmailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;

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
    NSString *username = [User currentUser].caseUsername;
    self.topLabel.text = [NSString stringWithFormat:NSLocalizedString(@"top_bar_email", nil), username];
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.validateButton.backgroundColor = [ColorUtils mainGreen];
    self.validateButton.layer.cornerRadius = self.validateButton.frame.size.height / 2;
    self.topView.backgroundColor = [ColorUtils mainGreen];
    [DesignUtils addBottomBorder:self.emailTextField borderSize:0.5 color:[ColorUtils veryLightBlack]];
    [self.emailTextField setValue:[ColorUtils lightBlack]
                       forKeyPath:@"_placeholderLabel.textColor"];
    
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
    [TrackingUtils trackEvent:EVENT_EMAIL_INPUT properties:nil];
    [self.emailTextField resignFirstResponder];
    
    // save user
    [DesignUtils showProgressHUDAddedTo:self.view];
    [User currentUser].email = email;
    [ApiManager saveCurrentUserAndExecuteSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [DesignUtils hideProgressHUDForView:self.view];
            [self performSegueWithIdentifier:@"Card From Email" sender:nil];
        });
    } failure:^(NSError *error) {
        [DesignUtils hideProgressHUDForView:self.view];
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"save_email_error_title", nil) andMessage:[error.userInfo valueForKey:@"error"]];
    }];
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
