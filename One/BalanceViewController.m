//
//  BalanceViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
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
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@property (weak, nonatomic) IBOutlet UIView *balanceContainer;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDownOne;
@property (weak, nonatomic) IBOutlet UILabel *leftUpOne;
@property (weak, nonatomic) IBOutlet UILabel *rightUpOne;
@property (weak, nonatomic) IBOutlet UILabel *rightDownOne;

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
    NSString *string = [NSString stringWithFormat:@"$%ld",[User currentUser].balance];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = self.balanceLabel.font;
    font = [font fontWithSize:font.pointSize / 2];
    [attr addAttributes:@{NSFontAttributeName: font, NSBaselineOffsetAttributeName: @10.} range:NSMakeRange(0,1)];
    self.balanceLabel.attributedText = attr;
    
    // Table view
    [DesignUtils addTopBorder:self.historyTableView borderSize:0.5 color:[UIColor lightGrayColor]];
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    self.historyTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.balanceLabel.layer.cornerRadius = self.balanceLabel.frame.size.height / 2;
}

// --------------------------------------------
#pragma mark - Table view
// --------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionTableViewCell *cell = (TransactionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TransactionCell"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
