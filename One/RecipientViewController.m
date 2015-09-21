//
//  RecipientViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "ApiManager.h"
#import "DatastoreManager.h"
#import "User.h"

#import "RecipientViewController.h"
#import "UserTableViewCell.h"

#import "ColorUtils.h"
#import "DesignUtils.h"
#import "KeyboardUtils.h"
#import "TrackingUtils.h"

@interface RecipientViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *recipientsTableView;
@property (weak, nonatomic) IBOutlet UIView *textfieldContainer;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextfield;
@property (weak, nonatomic) IBOutlet UIView *loadingContainer;
// Users
@property (strong, nonatomic) NSString *lastStringSearched;
@property (strong, nonatomic) NSArray *usersArray;

@end

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

@implementation RecipientViewController {
    BOOL _layoutFlag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init
    _layoutFlag = YES;
    
    // wording
    [self.closeButton setTitle:NSLocalizedString(@"close_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"recipient_title", nil);
    
    // UI
    self.topBar.backgroundColor = [ColorUtils mainGreen];
    [DesignUtils addBottomBorder:self.recipientTextfield borderSize:0.2 color:[UIColor lightGrayColor]];
    [DesignUtils addTopBorder:self.textfieldContainer borderSize:0.5 color:[UIColor lightGrayColor]];
    self.recipientTextfield.textColor = [ColorUtils mainGreen];
    self.loadingContainer.hidden = YES;
    
    // Table view
    self.recipientsTableView.delegate = self;
    self.recipientsTableView.dataSource = self;
    self.recipientsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Keyboard Observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Textfield
    self.recipientTextfield.delegate = self;
    
    // Show recent users
    [DatastoreManager getRecentUsersAndExecuteSuccess:^(NSArray *users) {
        if (self.recipientTextfield.text.length == 0) {
            self.usersArray = users;
            [self.recipientsTableView reloadData];
        }
    } failure:nil];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_layoutFlag) {
        _layoutFlag = NO;
        self.textfieldContainer.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.recipientTextfield becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)closeButtonClicked:(id)sender {
    [self close];
}

- (void)close {
    [self.recipientTextfield resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


// --------------------------------------------
#pragma mark - Table view
// --------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.usersArray ? self.usersArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = (UserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    cell.user = (User *)self.usersArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.recipientTextfield.isFirstResponder) {
       return NSLocalizedString(@"search_header", nil);
    }
    return NSLocalizedString(@"recent_header", nil);

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,22)];
    tempView.backgroundColor=[UIColor whiteColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,tempView.frame.size.width,tempView.frame.size.height)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = [ColorUtils mainGreen]; //here you can change the text color of header.
    tempLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15];
    tempLabel.text=[self tableView:tableView titleForHeaderInSection:section];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, tempView.frame.size.height - 0.5, tempView.frame.size.width, 0.5)];
    separator.backgroundColor = [ColorUtils mainGreen];
    
    [tempView addSubview:tempLabel];
    [tempView addSubview:separator];
    
    return tempView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TrackingUtils trackEvent:EVENT_RECIPIENT_SET properties:@{@"preselected": [NSNumber numberWithBool:self.recipientTextfield.text.length == 0]}];
    UserTableViewCell *cell = (UserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    User *selectedUser = cell.user;
    if (selectedUser) {
        [self.delegate setSelectedUser:selectedUser];
        [self close];
    }
}

// --------------------------------------------
#pragma mark - Text field
// --------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] || (textField.text.length == 0 && [string isEqualToString:@" "])) {
        return NO;
    }
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    // check username starting with these strings
    if (textField.text.length > 0) {
        self.lastStringSearched = textField.text;
        // Show HUD if not already
        if (self.loadingContainer.hidden) {
            self.loadingContainer.hidden = NO;
            [DesignUtils showProgressHUDAddedTo:self.loadingContainer withColor:[ColorUtils mainGreen] transform:CGAffineTransformMakeScale(0.5, 0.5)];
        }
        [ApiManager findUsersMatchingStartString:self.lastStringSearched
                                         success:^(NSString *string, NSArray *users) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if ([self.lastStringSearched isEqualToString:string]) {
                                                     self.usersArray = users;
                                                     [self.recipientsTableView reloadData];
                                                     
                                                     // end search indicator
                                                     if (!self.loadingContainer.hidden) {
                                                         self.loadingContainer.hidden = YES;
                                                         [DesignUtils hideProgressHUDForView:self.loadingContainer];
                                                     }
                                                 }
                                             });
                                         } failure:nil];
    } else {
        self.usersArray = nil;
        [self.recipientsTableView reloadData];
    }
    
    return NO;
}

// ----------------------------------------------------------
#pragma mark Keyboard
// ----------------------------------------------------------
// Move up create comment view on keyboard will show
- (void)keyboardWillShow:(NSNotification *)notification {
    [KeyboardUtils pushUpTopView:self.textfieldContainer whenKeyboardWillShowNotification:notification];
}

// Move down create comment view on keyboard will hide
- (void)keyboardWillHide:(NSNotification *)notification {
    [KeyboardUtils pushDownTopView:self.textfieldContainer whenKeyboardWillhideNotification:notification];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
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
