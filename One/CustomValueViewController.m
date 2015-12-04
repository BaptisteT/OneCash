//
//  CustomValueViewController.m
//  One
//
//  Created by Baptiste Truchot on 12/3/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "CustomValueViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"

@interface CustomValueViewController()
@property (weak, nonatomic) IBOutlet UILabel *dollarLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *invalidValueLabel;

@end


@implementation CustomValueViewController

// ----------------------------------------------------------
#pragma Life cycle
// ----------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    self.explanationLabel.text = NSLocalizedString(@"type_amount", nil);
    self.explanationLabel.textColor = [ColorUtils mainGreen];
    self.dollarLabel.textColor = [ColorUtils mainGreen];
    self.invalidValueLabel.hidden = YES;
    self.invalidValueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"excessive_cash_value", nil),kTransactionsLimit];
    
    // Text field
    self.valueTextField.delegate = self;
    self.valueTextField.text = [NSString stringWithFormat:@"%lu",(long)self.initialValue];
    [self.valueTextField becomeFirstResponder];
    
    // Tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAndUpdateValue)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.containerView.layer.cornerRadius = self.containerView.frame.size.height / 10;
}

// ----------------------------------------------------------
#pragma Textfield
// ----------------------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self closeAndUpdateValue];
        return NO;
    }
    NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (value.length > 2) {
        return NO;
    }
    self.invalidValueLabel.hidden = [value integerValue] <= kTransactionsLimit;
    return YES;
}

- (void)closeAndUpdateValue {
    NSInteger newValue = self.valueTextField.text.length > 0 ? [self.valueTextField.text integerValue] : 0;
    if (newValue == 0 || newValue > kTransactionsLimit) {
        newValue = self.initialValue;
    }
    [self.delegate updateCashViewStacksValue:newValue];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
