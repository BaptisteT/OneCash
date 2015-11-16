//
//  BalanceViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <LocalAuthentication/LocalAuthentication.h>
#import <Social/Social.h>
#import <UIScrollView+SVInfiniteScrolling.h>

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "Reaction.h"
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
@property (strong, nonatomic) User *selectedUser;
@property (weak, nonatomic) IBOutlet UIView *balanceContainer;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;
@property (weak, nonatomic) IBOutlet UIButton *transactionsOnboardingView;
@property (strong, nonatomic) UIView *statusOnboardingView;
@property (strong, nonatomic) NSMutableArray *transactions;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIButton *reactsButton;

// Reaction
@property (strong, nonatomic) Transaction *reactTransaction;
@property (nonatomic, strong) AVAudioPlayer *mainPlayer;

@end

@implementation BalanceViewController{
    BOOL _layoutFlag;
    CGFloat _statusInitialSize;
}


// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init
    _layoutFlag = YES;
    self.transactions = [NSMutableArray new];
    self.statusTextField.delegate = self;
    _statusInitialSize = self.statusTextField.font.pointSize;
    self.reactsButton.hidden = YES;
    
    // Wording
    [self.closeButton setTitle:NSLocalizedString(@"close_button", nil) forState:UIControlStateNormal];
    [self.settingsButton setTitle:NSLocalizedString(@"settings_button", nil) forState:UIControlStateNormal];
    [self.cashoutButton setTitle:NSLocalizedString(@"cashout_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = [User currentUser].caseUsername;
    self.historyLabel.text = NSLocalizedString(@"history_label", nil);
    self.statusTextField.placeholder = NSLocalizedString(@"status_placeholder", nil);
    self.statusTextField.minimumFontSize = 0.1;
    [self.transactionsOnboardingView setTitle:NSLocalizedString(@"no_transactions_tuto", nil) forState:UIControlStateNormal];
    
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
    self.transactionsOnboardingView.backgroundColor = [UIColor whiteColor];
    self.transactionsOnboardingView.layer.borderWidth = 5;
    self.transactionsOnboardingView.layer.borderColor = [UIColor colorWithRed:247./255 green:247./255 blue:247./255 alpha:1].CGColor;
    [self.transactionsOnboardingView setTitleColor:[UIColor colorWithRed:227./255 green:227./255 blue:227./255 alpha:1] forState:UIControlStateNormal];
    self.transactionsOnboardingView.layer.cornerRadius = self.transactionsOnboardingView.frame.size.height / 2;
    self.transactionsOnboardingView.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.transactionsOnboardingView.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *string = NSLocalizedString(@"no_transactions_tuto", nil);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange boldRange = [string rangeOfString:@"Share your username"];
    UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:self.transactionsOnboardingView.titleLabel.font.pointSize];
    [attrString addAttribute: NSFontAttributeName value:boldFont range:boldRange];
    self.transactionsOnboardingView.titleLabel.attributedText = attrString;
    
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
    [self.balanceContainer addGestureRecognizer:tapGesture];
    
    // Update badge
    [ApiManager updateBadge:0];
    
    // Unread reactions
    [self displayUnreadReactionsNumber];
    
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
    [self loadLatestTransactionsLocally:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.transactionsTableView reloadData];
    [self resetOnboardingView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Settings From Balance"]) {
        ((SettingsViewController *) [segue destinationViewController]).delegate = (id<SettingsVCProtocol>)self.delegate;
    } else if ([segueName isEqualToString:@"Managed From Balance"]) {
        ((ManagedAccountViewController *) [segue destinationViewController]).delegate = self;
    } else if ([segueName isEqualToString:@"AccountCard From Balance"]) {
        ((AccountCardViewController *) [segue destinationViewController]).delegate = self;
    } else if ([segueName isEqualToString:@"Camera From Balance"]) {
        ((CameraViewController *) [segue destinationViewController]).delegate = self;
    }
}

// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------
- (void)loadLatestTransactionsLocally {
    [self loadLatestTransactionsLocally:YES];
}

- (void)loadLatestTransactionsLocally:(BOOL)alwaysReload {
    [DatastoreManager getTransactionsLocallyAndExecuteSuccess:^(NSArray *transactions) {
        if (!transactions || transactions.count == 0) {
            [self.view bringSubviewToFront:self.transactionsOnboardingView];
        }
        
        // reload transactions (only if some are new)
        BOOL reload = false;
        if (!alwaysReload && transactions && transactions.count > 0) {
            for (Transaction *transaction in transactions) {
                if (![self.transactions containsObject:transaction]) {
                    reload = true;
                    break;
                }
            }
        } else {
            reload = true;
        }
        if (reload) {
            [self scrollToTop];
            self.transactions = [NSMutableArray arrayWithArray:transactions];
            [self.transactionsTableView reloadData];
        }
        
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
    [DesignUtils adjustFontSizeOfTextField:self.statusTextField maxFontSize:_statusInitialSize constraintSize:CGSizeMake(self.statusTextField.frame.size.width - 10,MAXFLOAT)];
}

// override set transactions to mark as unread
- (void)setTransactions:(NSMutableArray *)transactions {
    _transactions = transactions;
    
    // Mark transactions as read
    NSMutableArray *unreadTransactions = [NSMutableArray new];
    for (Transaction *transaction in transactions) {
        if (transaction.receiver && transaction.receiver == [User currentUser] &&  transaction.readStatus == false) {
            transaction.readStatus = true;
            [unreadTransactions addObject:transaction.objectId];
        }
    }
    [ApiManager markTransactionsAsRead:unreadTransactions success:nil failure:nil];
}

// --------------------------------------------
#pragma mark - Table view
// --------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.transactionsOnboardingView)
        self.transactionsOnboardingView.hidden = (self.transactions.count > 0);
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
    cell.delegate = self;
    [cell layoutIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)scrollToTop {
    [self.transactionsTableView setContentOffset:CGPointZero animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resignStatusFirstResponder];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resignStatusFirstResponder];
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

- (IBAction)reactsButtonClicked:(id)sender {
    if (self.transactions.count == 0) return;
    for (Transaction *transaction in self.transactions) {
        if (transaction.sender == [User currentUser] && transaction.reaction && !transaction.reaction.readStatus) {
            [self.transactionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.transactions indexOfObject:transaction] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            return;
        }
    }
    [self.transactionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.transactions.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [self.transactionsTableView triggerInfiniteScrolling];
}

// --------------------------------------------
#pragma mark - Alert View delegate
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"verify_button", nil)]) {
        [self performSegueWithIdentifier:@"Settings From Balance" sender:nil];
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"camera_access_error_title", nil)]) {
        [GeneralUtils openSettings];
    }
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


// --------------------------------------------
#pragma mark - Onboarding
// --------------------------------------------
- (void)resetOnboardingView {
    if (![DatastoreManager hasLaunchedOnce:@"Status"] && self.statusTextField.text.length == 0) {
        self.statusOnboardingView = [DesignUtils createBubbleAboutView:self.statusTextField
                                                              withText:NSLocalizedString(@"add_status_tuto", nil)
                                                              position:kPositionTop
                                                       backgroundColor:[UIColor whiteColor]
                                                             textColor:[ColorUtils mainGreen]];
        self.statusOnboardingView.layer.borderColor = [ColorUtils mainGreen].CGColor;
        self.statusOnboardingView.layer.borderWidth = 1;
        [self.statusTextField.superview addSubview:self.statusOnboardingView];
    }
}

- (IBAction)transactionOnboardingButtonClicked:(id)sender {
    [self.delegate navigateToShareUsername];
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
    
    // cursor position
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *position = [textField positionFromPosition:beginning offset:range.location + string.length];
    textField.selectedTextRange = [textField textRangeFromPosition:position toPosition:position];
    
    // Font size
    [DesignUtils adjustFontSizeOfTextField:self.statusTextField maxFontSize:_statusInitialSize constraintSize:
     CGSizeMake(self.statusTextField.frame.size.width - 10,MAXFLOAT)];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.statusOnboardingView) {
        [self.statusOnboardingView removeFromSuperview];
        self.statusOnboardingView = nil;
    }
}

// --------------------------------------------
#pragma mark - User TVC Protocl
// --------------------------------------------
- (void)displayTwitterOptionsForTransaction:(Transaction *)transaction {
    User *user = transaction.sender == [User currentUser] ? transaction.receiver : transaction.sender;
    if (user) {
        self.selectedUser = user;
        NSString *tweetActionTitle = (transaction.sender == [User currentUser]) ? NSLocalizedString(@"send_tweet_action", nil) : NSLocalizedString(@"reply_tweet_action", nil);
        if ([UIAlertController class] != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",user.caseUsername]
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_button", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            UIAlertAction *profileAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"navigate_to_twitter_action", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      [self navigateToTwitterProfile];
                                                                  }];
            UIAlertAction *followAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"follow_action", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self followSelectedUser];
                                                                 }];
            UIAlertAction *tweetAction = [UIAlertAction actionWithTitle:tweetActionTitle
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    [self sendTweetToSelectedUser];
                                                                }];
            
            [alert addAction:cancelAction];
            [alert addAction:profileAction];
            [alert addAction:followAction];
            [alert addAction:tweetAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // ios 7
            [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@",user.caseUsername]
                                         delegate:self
                                cancelButtonTitle:NSLocalizedString(@"cancel_button", nil)
                           destructiveButtonTitle:nil
                                otherButtonTitles:NSLocalizedString(@"navigate_to_twitter_action", nil), NSLocalizedString(@"follow_action", nil), tweetActionTitle, nil] showInView:self.view];
        }
    }
}


// --------------------------------------------
#pragma mark - Action sheet delegate
// --------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"navigate_to_twitter_action", nil)]) {
        [self navigateToTwitterProfile];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"follow_action", nil)]) {
        [self followSelectedUser];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"send_tweet_action", nil)] || [buttonTitle isEqualToString:NSLocalizedString(@"reply_tweet_action", nil)]) {
        [self sendTweetToSelectedUser];
    }
}

- (void)navigateToTwitterProfile {
    if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"twitter://user?screen_name=",self.selectedUser.username]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://twitter.com/",self.selectedUser.username]]];
        [TrackingUtils trackEvent:EVENT_TWITTER_PROFILE properties:nil];
    }
}

- (void)followSelectedUser {
    [TrackingUtils trackEvent:EVENT_TWITTER_FOLLOW properties:nil];
    [ApiManager followOnTwitter:self.selectedUser.caseUsername success:nil failure:nil];
}

- (void)sendTweetToSelectedUser {
    SLComposeViewController *twitterCompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *caption = [NSString stringWithFormat:@"@%@", self.selectedUser.username];
    [twitterCompose setInitialText:caption];
    [self presentViewController:twitterCompose
                       animated:YES
                     completion:^() {
                         [TrackingUtils trackEvent:EVENT_TWITTER_TWEET properties:nil];
                     }];
}


// --------------------------------------------
#pragma mark - reaction / Transaction TVC delegate
// --------------------------------------------
- (void)reactToTransaction:(Transaction *)transaction {
    self.reactTransaction = transaction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            [self performSegueWithIdentifier:@"Camera From Balance" sender:nil];
        } else if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"camera_access_error_title", nil)
                                        message:NSLocalizedString(@"camera_access_error_message", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    [self performSegueWithIdentifier:@"Camera From Balance" sender:nil];
                }
            }];
        }
    }
}

- (void)showReaction:(Reaction *)reaction image:(UIImage *)image initialFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnFullScreenReaction:)];
    [imageView addGestureRecognizer:tap];
    [self.view addSubview:imageView];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self animateDisplayImageReaction:imageView];
    [ApiManager markReactionAsRead:reaction success:nil failure:nil];
    
    // Reactions nb
    [reaction unpinInBackgroundWithName:kParseReactionName block:^(BOOL succeeded, NSError * _Nullable error) {
        [self displayUnreadReactionsNumber];
    }];
}

- (void)displayUnreadReactionsNumber {
    [DatastoreManager getNumberOfUnreadReactionsAndExecuteSuccess:^(NSInteger count) {
        NSString *title = count == 1 ? NSLocalizedString(@"new_react_button", nil) : [NSString stringWithFormat:NSLocalizedString(@"new_reacts_button", nil),count];
        [self.reactsButton setTitle:title forState:UIControlStateNormal];
        self.reactsButton.hidden = count == 0;
    } failure:nil];
}

// --------------------------------------------
#pragma mark - Display image reaction
// --------------------------------------------

- (void)animateDisplayImageReaction:(UIImageView *)imageView {
    imageView.frame = self.view.frame;
    [self.transactionsTableView reloadData];
    NSError* error;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"photo-display" ofType:@".m4a"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    self.mainPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    self.mainPlayer.volume = 0.2;
    if (error || ![self.mainPlayer prepareToPlay]) {
        NSLog(@"%@",error);
    } else {
        [self.mainPlayer play];
    }
    imageView.userInteractionEnabled = YES;
}

- (void)tapGestureOnFullScreenReaction:(UITapGestureRecognizer *)sender
{
    [sender.view removeFromSuperview];
}

// --------------------------------------------
#pragma mark - Camera VC Protocol
// --------------------------------------------
- (void)handleImage:(UIImage *)image
{
    Transaction *transaction = self.reactTransaction;
    transaction.ongoingReaction = true;
    [ApiManager reactToTransaction:self.reactTransaction
                         withImage:image
                           success:^{
                               transaction.ongoingReaction = false;
                               [self.transactionsTableView reloadData];
                           } failure:^(NSError *error) {
                               transaction.ongoingReaction = false;
                               [self.transactionsTableView reloadData];
                           }];
}





@end
