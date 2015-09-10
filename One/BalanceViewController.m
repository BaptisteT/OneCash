//
//  BalanceViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <UIScrollView+SVInfiniteScrolling.h>

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "Transaction.h"
#import "User.h"

#import "BalanceViewController.h"
#import "TransactionTableViewCell.h"

#import "ColorUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"

@interface BalanceViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet UIButton *cashoutButton;
@property (weak, nonatomic) IBOutlet UITableView *transactionsTableView;

@property (weak, nonatomic) IBOutlet UIView *balanceContainer;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDownOne;
@property (weak, nonatomic) IBOutlet UILabel *leftUpOne;
@property (weak, nonatomic) IBOutlet UILabel *rightUpOne;
@property (weak, nonatomic) IBOutlet UILabel *rightDownOne;

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
    
    // Wording
    [self.closeButton setTitle:NSLocalizedString(@"close_button", nil) forState:UIControlStateNormal];
    [self.settingsButton setTitle:NSLocalizedString(@"settings_button", nil) forState:UIControlStateNormal];
    [self.cashoutButton setTitle:NSLocalizedString(@"cashout_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"balance_title", nil);
    self.historyLabel.text = NSLocalizedString(@"history_label", nil);

    // UI
    self.cashoutButton.backgroundColor = [ColorUtils red];
    self.cashoutButton.layer.cornerRadius = self.cashoutButton.frame.size.height / 2;
    [self.closeButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    [self.settingsButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.titleLabel.textColor = [ColorUtils mainGreen];
    self.balanceContainer.backgroundColor = [ColorUtils mainGreen];
    self.balanceContainer.layer.cornerRadius = self.balanceContainer.frame.size.height / 20;
    self.leftDownOne.textColor = [ColorUtils darkGreen];
    self.leftUpOne.textColor = [ColorUtils darkGreen];
    self.rightUpOne.textColor = [ColorUtils darkGreen];
    self.rightDownOne.textColor = [ColorUtils darkGreen];
    self.rightDownOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    self.leftDownOne.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    self.balanceLabel.backgroundColor = [ColorUtils darkGreen];
    self.balanceLabel.clipsToBounds = YES;
    self.balanceLabel.adjustsFontSizeToFitWidth = YES;
    self.balanceLabel.minimumScaleFactor = 0.1;
    
    // Balance
    [self setBalance];
    
    // Table view
    self.transactionsTableView.delegate = self;
    self.transactionsTableView.dataSource = self;
    self.transactionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.transactionsTableView addInfiniteScrollingWithActionHandler:^() {
        [self loadOlderTransactionsRemotely];
    }];
    
    // Update badge
    [ApiManager updateBadge:0];
    
    // Load transactions
    [self loadLatestTransactionsLocally];
    
    // Notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadLatestTransactionsLocally)
                                                 name:@"refresh_transactions_table"
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.balanceLabel.layer.cornerRadius = self.balanceLabel.frame.size.height / 2;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [self setBalance];
    } failure:nil];
}

- (void)loadOlderTransactionsRemotely {
    if (!self.transactions || self.transactions.count == 0) {
        [self.transactionsTableView.infiniteScrollingView stopAnimating];
        return;
    }
    Transaction *oldest = self.transactions.lastObject;
    [ApiManager getTransactionsAroundDate:oldest.createdAt
                                  isStart:NO
                                  success:^(NSArray *transactions) {
                                      [self.transactionsTableView.infiniteScrollingView stopAnimating];
                                      [self.transactions addObjectsFromArray:transactions];
                                      [self.transactionsTableView reloadData];
                                  } failure:^(NSError *error) {
                                      [self.transactionsTableView.infiniteScrollingView stopAnimating];
                                  }];
}

- (void)setBalance {
    NSString *string = [NSString stringWithFormat:@"$%ld",[User currentUser].balance];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = self.balanceLabel.font;
    font = [font fontWithSize:14];
    [attr addAttributes:@{NSFontAttributeName: font, NSBaselineOffsetAttributeName: @10.} range:NSMakeRange(0,1)];
    self.balanceLabel.attributedText = attr;
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

- (IBAction)settingsButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Settings From Balance" sender:nil];
}

- (IBAction)cashoutButtonClicked:(id)sender {
    if ([User currentUser].balance <= 0) {
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"cashout_no_money_title", nil) andMessage:NSLocalizedString(@"cashout_no_money_message", nil)];
    } else if ([User currentUser].paymentMethod == kPaymentMethodNone) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_card_title", nil)
                                    message:NSLocalizedString(@"no_card_message", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"later_", nil)
                          otherButtonTitles:NSLocalizedString(@"add_button", nil), nil] show];
    } else {
        // todo BT
        // cash out function
        [DesignUtils showProgressHUDAddedTo:self.view];
        [ApiManager createCashoutAndExecuteSuccess:^{
            [DesignUtils hideProgressHUDForView:self.view];
            [self loadLatestTransactionsLocally];
        } failure:^(NSError *error) {
            // todo BT
            // analyse different error
            [DesignUtils hideProgressHUDForView:self.view];
            [GeneralUtils showAlertWithTitle:NSLocalizedString(@"cashout_error_title", nil) andMessage:NSLocalizedString(@"cashout_error_message    ", nil)];
        }];
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - Alert View delegate
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:NSLocalizedString(@"no_card_title", nil)]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"add_button", nil)]) {
            [self.delegate navigateToCardController];
        }
    }
}

@end
