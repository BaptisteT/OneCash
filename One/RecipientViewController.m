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
#import "DesignUtils.h"
#import "KeyboardUtils.h"

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
    self.toLabel.text = NSLocalizedString(@"to", nil);
    
    // UI
    self.topBar.backgroundColor = [ColorUtils lightGreen];
    self.toLabel.textColor = [ColorUtils lightGreen];
    [DesignUtils addBottomBorder:self.recipientTextfield borderSize:0.2 color:[UIColor lightGrayColor]];
    [DesignUtils addTopBorder:self.textfieldContainer borderSize:0.5 color:[UIColor lightGrayColor]];
    self.recipientTextfield.textColor = [ColorUtils lightGreen];
    
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
    
    // todo BT
    // load list of already used used users

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_layoutFlag) {
        _layoutFlag = NO;
        self.textfieldContainer.translatesAutoresizingMaskIntoConstraints = YES;
//        [self.recipientTextfield becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.recipientTextfield becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // todo BT
    // check if a user with this username exists
    
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

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
// Set status bar color to white
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
