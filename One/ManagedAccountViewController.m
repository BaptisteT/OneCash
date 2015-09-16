//
//  ManagedAccountViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "ManagedAccountViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "OneLogger.h"

@interface ManagedAccountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (nonatomic) BOOL isIndividual;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *businessNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *entityTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *ddTextfield;
@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;

@end

@implementation ManagedAccountViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.isIndividual = YES;
    self.termsLabel.hidden = YES;
    self.ddTextfield.hidden = YES;
    self.monthTextField.hidden = YES;
    self.yearTextField.hidden = YES;
    self.registerButton.hidden = YES;
    
    // wording
    self.titleLabel.text = NSLocalizedString(@"managed_account_title", nil);
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    [self.entityTypeSegmentedControl setTitle:NSLocalizedString(@"individual_segment", nil) forSegmentAtIndex:0];
    [self.entityTypeSegmentedControl setTitle:NSLocalizedString(@"company_segment", nil) forSegmentAtIndex:1];
    self.firstNameTextField.placeholder = NSLocalizedString(@"first_name_placeholder", nil);
    self.lastNameTextField.placeholder = NSLocalizedString(@"last_name_placeholder", nil);
    self.businessNameTextField.placeholder = NSLocalizedString(@"business_name_placeholder", nil);
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    self.entityTypeSegmentedControl.tintColor = [ColorUtils mainGreen];

    // Delegate
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.businessNameTextField.delegate = self;
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)entityTypeChanged:(id)sender {
    self.isIndividual = self.entityTypeSegmentedControl.selectedSegmentIndex == 0;
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
        [self.firstNameTextField becomeFirstResponder];
    } else {
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
            self.ddTextfield.hidden = NO;
            self.monthTextField.hidden = NO;
            self.yearTextField.hidden = NO;
            [self.firstNameTextField becomeFirstResponder];
        } else if (self.ddTextfield.isFirstResponder) {
            [self.monthTextField becomeFirstResponder];
        } else if (self.monthTextField.isFirstResponder) {
            [self.yearTextField becomeFirstResponder];
        } else if (self.yearTextField.isFirstResponder) {
            [self.yearTextField resignFirstResponder];
            self.registerButton.hidden = NO;
            self.termsLabel.hidden = NO;
        }
        return NO;
    }
    return YES;
}

@end
