//
//  RecipientViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "User.h"

#import "RecipientViewController.h"
#import "UserTableViewCell.h"

#import "ColorUtils.h"

@interface RecipientViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *recipientsTableView;
@property (weak, nonatomic) IBOutlet UIView *textfieldContainer;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextfield;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@end

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

@implementation RecipientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // wording
    [self.closeButton setTitle:NSLocalizedString(@"close_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"recipient_title", nil);
    self.toLabel.text = NSLocalizedString(@"to", nil);
    
    // UI
    self.topBar.backgroundColor = [ColorUtils lightGreen];
    self.toLabel.textColor = [ColorUtils lightGreen];
    
    // Table view
    self.recipientsTableView.delegate = self;
    self.recipientsTableView.dataSource = self;
    self.recipientsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Textfield
    self.recipientTextfield.delegate = self;
    
    // todo BT
    // load list of already used used users
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



// --------------------------------------------
#pragma mark - Table view
// --------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = (UserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    cell.user = [User currentUser];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

// --------------------------------------------
#pragma mark - Text field
// --------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // todo BT
    // check if a user with this username exists
    
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
