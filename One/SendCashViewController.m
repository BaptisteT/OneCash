//
//  SendCashViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "SendCashViewController.h"

#import "ColorUtils.h"
#import "DesignUtils.h"

@interface SendCashViewController ()
@property (weak, nonatomic) IBOutlet UIButton *balanceButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickRecipientButton;

@end

@implementation SendCashViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Wording
    [self.balanceButton setTitle:NSLocalizedString(@"balance_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"send_controller_title", nil);
    
    // UI
    self.view.backgroundColor = [ColorUtils lightGreen];
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)balanceButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Balance From Send" sender:nil];
}

// payment if balance > 0
// else if apple pay => payment
// else

- (IBAction)pickRecipientButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Recipient From Send" sender:nil];
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
