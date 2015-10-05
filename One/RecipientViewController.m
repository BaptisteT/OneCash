//
//  RecipientViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <Social/Social.h>
#import "ApiManager.h"
#import "DatastoreManager.h"
#import "User.h"

#import "RecipientViewController.h"
#import "UserTableViewCell.h"

#import "ColorUtils.h"
#import "DesignUtils.h"
#import "TrackingUtils.h"

#define HEADER_HEIGHT 22

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
@property (strong, nonatomic) NSArray *historicUsers;
@property (strong, nonatomic) NSArray *suggestedUsers;
@property (strong, nonatomic) NSArray *leadingUsers;
@property (strong, nonatomic) NSArray *searchedUsersArray;
@property (strong, nonatomic) NSArray *twitterUsersArray;

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
    self.recipientTextfield.placeholder = NSLocalizedString(@"recipients_search_placeholder", nil);
    
    // UI
    self.topBar.backgroundColor = [ColorUtils mainGreen];
//    [DesignUtils addBottomBorder:self.textfieldContainer borderSize:0.5 color:[ColorUtils mainGreen]];
    self.recipientTextfield.textColor = [ColorUtils mainGreen];
    self.loadingContainer.hidden = YES;
    
    // Table view
    self.recipientsTableView.delegate = self;
    self.recipientsTableView.dataSource = self;
    self.recipientsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Textfield
    self.recipientTextfield.delegate = self;
    
    // Leaders
    [DatastoreManager getLeadersAndExecuteSuccess:^(NSArray *users) {
        if (!self.leadingUsers) {
            self.leadingUsers = users;
            if (self.recipientTextfield.text.length == 0) {
                [self.recipientsTableView reloadData];
            }
        }
    } failure:nil];
    [ApiManager getLeadersAndExecuteSuccess:^(NSArray *users) {
        self.leadingUsers = users;
        if (self.recipientTextfield.text.length == 0) {
            [self.recipientsTableView reloadData];
        }
    } failure:nil];
    
    // Suggested
    [DatastoreManager getSuggestedUsersAndExecuteSuccess:^(NSArray *users) {
        if (!self.suggestedUsers) {
            self.suggestedUsers = users;
            if (self.recipientTextfield.text.length == 0) {
                [self.recipientsTableView reloadData];
            }
        }
    } failure:nil];
    [ApiManager getSuggestedUsersAndExecuteSuccess:^(NSArray *users) {
        self.suggestedUsers = users;
        if (self.recipientTextfield.text.length == 0) {
            [self.recipientsTableView reloadData];
        }
    } failure:nil];
    
    // Recent users
    [DatastoreManager getRecentUsersAndExecuteSuccess:^(NSArray *users) {
        self.historicUsers = users;
        if (self.recipientTextfield.text.length == 0) {
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
    if([self isSearchSection:section]) {
        return self.searchedUsersArray ? self.searchedUsersArray.count : 0;
    } else if ([self isTwitterSection:section]) {
        return self.twitterUsersArray.count;
    } else if ([self isRecentSection:section]) {
        return self.historicUsers.count;
    } else if ([self isSuggestedSection:section]) {
        return self.suggestedUsers.count;
    } else {
        return self.leadingUsers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *userArray;
    if ([self isSearchSection:indexPath.section]) {
        userArray = self.searchedUsersArray;
    } else if ([self isTwitterSection:indexPath.section]) {
        userArray = self.twitterUsersArray;
    } else if ([self isRecentSection:indexPath.section]) {
        userArray = self.historicUsers;
    } else if ([self isSuggestedSection:indexPath.section]) {
        userArray = self.suggestedUsers;
    } else {
        userArray = self.leadingUsers;
    }
    
    UserTableViewCell *cell = (UserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    [cell initWithUser:(User *)userArray[indexPath.row] showBalance:[self isLeaderSection:indexPath.section]];
    cell.delegate = self;
    [cell layoutIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self isSearchSection:section]) {
       return NSLocalizedString(@"search_header", nil);
    } else if ([self isTwitterSection:section]) {
        return NSLocalizedString(@"twitter_header", nil);
    } else if ([self isRecentSection:section]) {
        return NSLocalizedString(@"recent_header", nil);
    } else if ([self isSuggestedSection:section]) {
        return NSLocalizedString(@"suggested_header", nil);
    } else if ([self isLeaderSection:section]) {
        return NSLocalizedString(@"leaderboard_header", nil);
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([self searchedUserSection] != -1) + ([self twitterUserSection] != -1) + ([self recentUserSection] != -1) + ([self leaderboardSection] != -1) + ([self suggestedUserSection] != -1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,HEADER_HEIGHT)];
    tempView.backgroundColor=[UIColor whiteColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,tempView.frame.size.width,22)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = [ColorUtils mainGreen];
    tempLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15];
    tempLabel.text=[self tableView:tableView titleForHeaderInSection:section];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, tempView.frame.size.height - 0.5, tempView.frame.size.width, 0.5)];
    separator.backgroundColor = [ColorUtils mainGreen];
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tempView.frame.size.width, 0.5)];
    separator2.backgroundColor = [ColorUtils mainGreen];
    [tempView addSubview:tempLabel];
    [tempView addSubview:separator];
    [tempView addSubview:separator2];

    
    return tempView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [TrackingUtils trackEvent:EVENT_RECIPIENT_SET properties:@{@"preselected": [NSNumber numberWithBool:self.recipientTextfield.text.length == 0]}];
    UserTableViewCell *cell = (UserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    User *selectedUser = cell.user;
    // External case
    if (!selectedUser.objectId) {
        for (User *user in self.searchedUsersArray) {
            if ([user.username isEqualToString:selectedUser.username]) {
                selectedUser = user;
                break;
            }
        }
    }
    if (selectedUser) {
        [self.delegate setSelectedUser:selectedUser];
        [self close];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.recipientTextfield resignFirstResponder];
}


// --------------------------------------------
#pragma mark - Utils
// --------------------------------------------
- (NSInteger)searchedUserSection {
    return self.recipientTextfield.text.length > 0 ? 0 : -1;
}

- (NSInteger)twitterUserSection {
    return (self.recipientTextfield.text.length > 0 && self.twitterUsersArray.count > 0) ? 1 : -1;
}

- (NSInteger)recentUserSection {
    return (self.recipientTextfield.text.length == 0 && self.historicUsers.count > 0) ? 0 : -1;
}

- (NSInteger)suggestedUserSection {
    return (self.recipientTextfield.text.length == 0 && self.suggestedUsers.count > 0) ? ([self recentUserSection] + 1) : -1;
}

- (NSInteger)leaderboardSection {
    return (self.recipientTextfield.text.length == 0 && self.leadingUsers.count > 0) ? (MAX([self suggestedUserSection],[self recentUserSection]) + 1) : -1;
}

- (BOOL)isSearchSection:(NSInteger)section {
    return section == [self searchedUserSection];
}

- (BOOL)isTwitterSection:(NSInteger)section {
    return section == [self twitterUserSection];
}

- (BOOL)isRecentSection:(NSInteger)section {
    return section == [self recentUserSection];
}

- (BOOL)isSuggestedSection:(NSInteger)section {
    return section == [self suggestedUserSection];
}

- (BOOL)isLeaderSection:(NSInteger)section {
    return section == [self leaderboardSection];
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
        // One Users
        // todo BT : cancel request or put some delay to limit them ?
        [ApiManager findUsersMatchingStartString:self.lastStringSearched
                                         success:^(NSString *string, NSArray *users) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if ([self.lastStringSearched isEqualToString:string]) {
                                                     self.searchedUsersArray = users;
                                                     [self.recipientsTableView reloadData];
                                                     
                                                     // end search indicator
                                                     if (!self.loadingContainer.hidden) {
                                                         self.loadingContainer.hidden = YES;
                                                         [DesignUtils hideProgressHUDForView:self.loadingContainer];
                                                     }
                                                 }
                                             });
                                         } failure:^(NSError *error) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if ([self.lastStringSearched isEqualToString:string]) {
                                                     // end search indicator
                                                     if (!self.loadingContainer.hidden) {
                                                         self.loadingContainer.hidden = YES;
                                                         [DesignUtils hideProgressHUDForView:self.loadingContainer];
                                                     }
                                                 }
                                             });
                                         }];
        
        // Twitter users
        // todo BT : cancel request or put some delay to limit them ?
        [ApiManager getTwitterUsersFromString:self.lastStringSearched
                                      success:^(NSArray *twitterUsers, NSString *string) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if ([self.lastStringSearched isEqualToString:string]) {
                                                  self.twitterUsersArray = twitterUsers;
                                                  [self.recipientsTableView reloadData];
                                              }
                                          });
                                      } failure:nil];
        
    } else {
        self.searchedUsersArray = nil;
        [self.recipientsTableView reloadData];
    }
    
    return NO;
}

// --------------------------------------------
#pragma mark - User TVC Protocl
// --------------------------------------------
- (void)displayTwitterOptionsForUser:(User *)user {
    if ([UIAlertController class] != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@%@",user.caseUsername]
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_button", nil)
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil];
        UIAlertAction *profileAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"navigate_to_twitter_action", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                  if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"twitter://user?screen_name=",user.username]]])
                  {
                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://twitter.com/",user.username]]];
                  }
              }];
        UIAlertAction *followAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"follow_action", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [ApiManager followOnTwitter:user.caseUsername success:nil failure:nil];
                                                              }];
        UIAlertAction *tweetAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"send_tweet_action", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                  SLComposeViewController *twitterCompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                  NSString *caption = [NSString stringWithFormat:@"@%@", [User currentUser].username];
                  [twitterCompose setInitialText:caption];
                  [self presentViewController:twitterCompose
                                     animated:YES
                                   completion:nil];

              }];
        
        [alert addAction:cancelAction];
        [alert addAction:profileAction];
        [alert addAction:followAction];
        [alert addAction:tweetAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // todo BT ios 7
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
