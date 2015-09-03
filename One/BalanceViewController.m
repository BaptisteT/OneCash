//
//  BalanceViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "BalanceViewController.h"

#import "ColorUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"

@interface BalanceViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIView *balanceContainer;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet UIButton *cashoutButton;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@end

@implementation BalanceViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Wording
    [self.closeButton setTitle:NSLocalizedString(@"close_button", nil) forState:UIControlStateNormal];
    [self.settingsButton setTitle:NSLocalizedString(@"settings_button", nil) forState:UIControlStateNormal];
    [self.cashoutButton setTitle:NSLocalizedString(@"cashout_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"balance_title", nil);
    self.historyLabel.text = NSLocalizedString(@"history_label", nil);

    // UI
    self.cashoutButton.backgroundColor = [ColorUtils red];
    self.cashoutButton.layer.cornerRadius = self.cashoutButton.frame.size.height / 2;
    [self.closeButton setTitleColor:[ColorUtils lightGreen] forState:UIControlStateNormal];
    [self.settingsButton setTitleColor:[ColorUtils lightGreen] forState:UIControlStateNormal];
    self.titleLabel.textColor = [ColorUtils lightGreen];
    self.balanceContainer.backgroundColor = [ColorUtils lightGreen];
    self.balanceContainer.layer.cornerRadius = self.balanceContainer.frame.size.height;
    
    // Balance
    // todo BT
    
    // Table view
    // todo BT
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)settingsButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Settings From Balance" sender:nil];
}

- (IBAction)cashoutButtonClicked:(id)sender {
    // todo BT
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
