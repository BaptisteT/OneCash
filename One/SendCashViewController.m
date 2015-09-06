//
//  SendCashViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "User.h"

#import "SendCashViewController.h"

#import "ColorUtils.h"
#import "DesignUtils.h"

@interface SendCashViewController ()
@property (weak, nonatomic) IBOutlet UIButton *balanceButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickRecipientButton;

@property (strong, nonatomic) User *receiver;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedUserLabel;

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
    self.toLabel.text = NSLocalizedString(@"to", nil);
    [self setSelectedUser:nil];

    // UI
    self.toLabel.textColor = [ColorUtils lightGreen];
    self.view.backgroundColor = [ColorUtils lightGreen];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Recipient From Send"]) {
        ((RecipientViewController *) [segue destinationViewController]).delegate = self;
    }
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
#pragma mark - Recipients delegate
// --------------------------------------------
- (void)setSelectedUser:(User *)user {
    self.receiver = user;
    if (user) {
        self.selectedUserLabel.text = user.username;
        self.selectedUserLabel.textColor = [ColorUtils lightGreen];
    } else {
        self.selectedUserLabel.text = NSLocalizedString(@"recipient_title", nil);
        self.selectedUserLabel.textColor = [UIColor lightGrayColor];
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
