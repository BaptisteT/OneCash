//
//  BalanceViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <LocalAuthentication/LocalAuthentication.h>

#import <UIScrollView+SVInfiniteScrolling.h>

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "Transaction.h"
#import "User.h"

#import "BalanceViewController.h"
#import "SettingsViewController.h"
#import "TransactionTableViewCell.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "TrackingUtils.h"

@interface BalanceViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet UIButton *cashoutButton;
@property (weak, nonatomic) IBOutlet UITableView *transactionsTableView;

@property (weak, nonatomic) IBOutlet UIView *balanceContainer;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

@property (strong, nonatomic) NSMutableArray *transactions;

@end

@implementation BalanceViewController{
    BOOL _layoutFlag;
}


// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init
    _layoutFlag = YES;
    self.transactions = [NSMutableArray new];
    [DatastoreManager setLastBalanceOpeningDate:[NSDate date]];
    self.statusTextField.delegate = self;
    
    // Wording
    [self.closeButton setTitle:NSLocalizedString(@"close_button", nil) forState:UIControlStateNormal];
    [self.settingsButton setTitle:NSLocalizedString(@"settings_button", nil) forState:UIControlStateNormal];
    [self.cashoutButton setTitle:NSLocalizedString(@"cashout_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = [User currentUser].caseUsername;
    self.historyLabel.text = NSLocalizedString(@"history_label", nil);
    self.statusTextField.placeholder = NSLocalizedString(@"status_placeholder", nil);

    // UI
    self.cashoutButton.backgroundColor = [ColorUtils red];
    self.cashoutButton.layer.cornerRadius = self.cashoutButton.frame.size.height / 2;
    self.balanceContainer.backgroundColor = [ColorUtils mainGreen];
    self.balanceLabel.backgroundColor = [ColorUtils darkGreen];
    self.balanceLabel.clipsToBounds = YES;
    self.balanceLabel.adjustsFontSizeToFitWidth = YES;
    self.balanceLabel.minimumScaleFactor = 0.1;
    self.transactionsTableView.bounces = YES;
    [self.transactionsTableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];
    [self.transactionsTableView setScrollIndicatorInsets:[self.transactionsTableView contentInset]];
    
    // Balance
    [self setBalanceAndStatus];
    
    // Table view
    self.transactionsTableView.delegate = self;
    self.transactionsTableView.dataSource = self;
    self.transactionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.transactionsTableView addInfiniteScrollingWithActionHandler:^() {
        [self loadOlderTransactionsRemotely];
    }];
    
    // Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignStatusFirstResponder)];
    [self.view addGestureRecognizer:tapGesture];
    
    // Update badge
    [ApiManager updateBadge:0];
    
    // Notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadLatestTransactionsLocally)
                                                 name:kNotificationRefreshTransactions
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.balanceLabel.layer.cornerRadius = self.balanceLabel.frame.size.height / 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Load transactions
    [self loadLatestTransactionsLocally];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.transactionsTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Last balance date
    [DatastoreManager setLastBalanceOpeningDate:[NSDate date]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Settings From Balance"]) {
        ((SettingsViewController *) [segue destinationViewController]).delegate = (id<SettingsVCProtocol>)self.delegate;
    } else if ([segueName isEqualToString:@"Managed From Balance"]) {
        ((ManagedAccountViewController *) [segue destinationViewController]).delegate = self;
    } else if ([segueName isEqualToString:@"AccountCard From Balance"]) {
        ((AccountCardViewController *) [segue destinationViewController]).delegate = self;
    }
}

// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------
- (void)loadLatestTransactionsLocally {
    [DatastoreManager getTransactionsLocallyAndExecuteSuccess:^(NSArray *transactions) {
        // relaod transactions
        [self scrollToTop];
        self.transactions = [NSMutableArray arrayWithArray:transactions];
        [self.transactionsTableView reloadData];
        
        // reset balance
        [self setBalanceAndStatus];
    } failure:nil];
}

- (void)loadOlderTransactionsRemotely {
    if (!self.transactions || self.transactions.count == 0) {
        [self.transactionsTableView.infiniteScrollingView stopAnimating];
        return;
    }
    Transaction *oldest = self.transactions.lastObject;
    [ApiManager getTransactionsBeforeDate:oldest.createdAt
                                  success:^(NSArray *transactions) {
                                      [self.transactionsTableView.infiniteScrollingView stopAnimating];
                                      [self.transactions addObjectsFromArray:transactions];
                                      [self.transactionsTableView reloadData];
                                  } failure:^(NSError *error) {
                                      [self.transactionsTableView.infiniteScrollingView stopAnimating];
                                  }];
}

- (void)setBalanceAndStatus {
    NSString *string = [NSString stringWithFormat:@"$%ld",(long)[User currentUser].balance];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = self.balanceLabel.font;
    UIColor *color = [ColorUtils mainGreen];
    [attr addAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color} range:NSMakeRange(0,1)];
    self.balanceLabel.attributedText = attr;
    self.statusTextField.text = [User currentUser].userStatus;
}


// --------------------------------------------
#pragma mark - Table view
// --------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Transaction *transaction = (Transaction *)self.transactions[indexPath.row];
    NSString *cellIdentifier;
    if (transaction.sender == [User currentUser]) {
        cellIdentifier = @"TransactionSentCell";
    } else {
        cellIdentifier = @"TransactionReceivedCell";
    }
    TransactionTableViewCell *cell = (TransactionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell initWithTransaction:(Transaction *)self.transactions[indexPath.row]];
    [cell layoutIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)scrollToTop {
    [self.transactionsTableView setContentOffset:CGPointZero animated:YES];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)settingsButtonClicked:(id)sender
{
    [self resignStatusFirstResponder];
    [TrackingUtils trackEvent:EVENT_SETTINGS_CLICKED properties:nil];
    if ([User currentUser].touchId) {
        [self performTouchIdVerificationAndExecuteSuccess:^{
            [self performSegueWithIdentifier:@"Settings From Balance" sender:nil];
        }];
    } else {
        [self performSegueWithIdentifier:@"Settings From Balance" sender:nil];
    }
}

- (IBAction)cashoutButtonClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_CASHOUT_CLICKED properties:nil];
    if ([User currentUser].balance <= 0) {
        [GeneralUtils showAlertWithTitle:nil andMessage:NSLocalizedString(@"cashout_no_money_message", nil)];
    } else if (![[User currentUser] isEmailVerified]) {
        // alert & send back to settings
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"cashout_no_email_message", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"later_", nil)
                          otherButtonTitles:NSLocalizedString(@"verify_button", nil), nil] show];
    } else if (![User currentUser].managedAccountId) {
        if ([User currentUser].touchId) {
            [self performTouchIdVerificationAndExecuteSuccess:^{
                [self performSegueWithIdentifier:@"Managed From Balance" sender:nil];
            }];
        } else {
            [self performSegueWithIdentifier:@"Managed From Balance" sender:nil];
        }
    } else {
        // go directly to card choice
        if ([User currentUser].touchId) {
            [self performTouchIdVerificationAndExecuteSuccess:^{
                [self performSegueWithIdentifier:@"AccountCard From Balance" sender:nil];
            }];
        } else {
            [self performSegueWithIdentifier:@"AccountCard From Balance" sender:nil];
        }
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    [self resignStatusFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)returnToBalanceController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - Alert View delegate
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"verify_button", nil)]) {
        [self performSegueWithIdentifier:@"Settings From Balance" sender:nil];
    }
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// --------------------------------------------
#pragma mark - Touch Id
// --------------------------------------------
- (void)performTouchIdVerificationAndExecuteSuccess:(void(^)())successBlock {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:NSLocalizedString(@"touch_id_title", nil)
                          reply:^(BOOL success, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (success && successBlock) {
                                      successBlock();
                                  }
                              });
                          }];
    } else {
        successBlock();
    }
}

// --------------------------------------------
#pragma mark - UITextField delegate
// --------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self resignStatusFirstResponder];
        return NO;
    }
    if (textField.text.length == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > kMaxStatusLength)
        return NO;
    textField.text = newString;
    return NO;
}

- (void)resignStatusFirstResponder {
    if (self.statusTextField.isFirstResponder){
        [self.statusTextField resignFirstResponder];
        // Save new status
        [User currentUser].userStatus = self.statusTextField.text;
        [ApiManager saveCurrentUserAndExecuteSuccess:^{
            [self setBalanceAndStatus];
        } failure:^(NSError *error) {
            [self setBalanceAndStatus];
        }];
    }
}

@end
