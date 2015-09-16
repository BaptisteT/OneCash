//
//  AccountCardViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import "ApiManager.h"

#import "AccountCardViewController.h"

#import "ColorUtils.h"

@interface AccountCardViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *cardTableView;

@end

@implementation AccountCardViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // wording
    self.titleLabel.text = NSLocalizedString(@"acount_card_title", nil);
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    
    // UI
    self.titleLabel.numberOfLines = 0;
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    
    // table view
    self.cardTableView.delegate = self;
    self.cardTableView.dataSource = self;
    self.cardTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [ApiManager getManageAccountAndExecuteSuccess:^{
        // todo BT
        // get cards
        
        // check the verified
    }failure:nil];
}



// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self.delegate returnToBalanceController];
}

// --------------------------------------------
#pragma mark - TableView
// --------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
