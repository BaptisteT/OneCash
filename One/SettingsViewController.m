//
//  SettingsViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <LocalAuthentication/LocalAuthentication.h>
#import "NSString+EmailAddresses.h"
#import "SHEmailValidator.h"

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "User.h"

#import "CardViewController.h"
#import "SettingsViewController.h"
#import "SwitchTableViewCell.h"
#import "TweetTableViewCell.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "TrackingUtils.h"

struct {
    NSInteger card;
    NSInteger tweet;
    NSInteger pin;
    NSInteger email;
    NSInteger support;
    NSInteger share;
    NSInteger logout;
    NSInteger typesCount;
} SectionTypes;

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSDictionary *customerCard;
@property (nonatomic) NSInteger tweetCellHeight;
@property (strong, nonatomic) IBOutlet UIView *topBarView;

@end

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

@implementation SettingsViewController {
    BOOL _displayTouchIdSection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.tweetCellHeight = kSettingsCellHeight;
    
    // Touch id
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    _displayTouchIdSection = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    
    // Init section types
    SectionTypes.card = 0;
    SectionTypes.tweet = SectionTypes.card + 1;
    SectionTypes.pin = _displayTouchIdSection ? SectionTypes.tweet + 1 : -1;
    SectionTypes.email = _displayTouchIdSection ? SectionTypes.pin + 1 : SectionTypes.tweet + 1;
    SectionTypes.support = SectionTypes.email + 1;
    SectionTypes.share = SectionTypes.support + 1;
    SectionTypes.logout = SectionTypes.share + 1;
    SectionTypes.typesCount = SectionTypes.logout + 1;
    
    // UI
    self.topBarView.backgroundColor = [ColorUtils mainGreen];
    
    // Wording
    [self.backButton setTitle:NSLocalizedString(@"back_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"settings_title", nil);
    
    // tableview
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    self.settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Explictly set your cell's layout margins
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // fetch
    [self fetchUser];
    
    // Callback
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willBecomeActiveCallback)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    // Get card
    self.customerCard = [DatastoreManager getCardInfo];
    if ([User currentUser].paymentMethod == kPaymentMethodStripe && !self.customerCard) {
        [ApiManager getCustomerCardsAndExecuteSuccess:^(NSArray *cards) {
            self.customerCard = [DatastoreManager getCardInfo];
            [self.settingsTableView reloadData];
        } failure:nil];
    }
}


- (void)willBecomeActiveCallback {
    [self fetchUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Get card
    self.customerCard = [DatastoreManager getCardInfo];
    // Reload
    [self.settingsTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Card From Settings"]) {
        ((CardViewController *) [segue destinationViewController]).redirectionViewController = self;
    }
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)slideSwitched:(BOOL)state ofSection:(NSInteger)section {
    [DesignUtils showProgressHUDAddedTo:self.view];
    NSString *event, *property;
    if (section == SectionTypes.tweet) {
        [User currentUser].autoTweet = state;
        event = EVENT_AUTO_TWEET_CHANGED;
        property = PEOPLE_AUTO_TWEET;
    } else if (section == SectionTypes.pin) {
        [User currentUser].touchId = state;
        event = EVENT_TOUCH_ID_CHANGED;
        property = PEOPLE_TOUCH_ID;
    }
    [ApiManager saveCurrentUserAndExecuteSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [DesignUtils hideProgressHUDForView:self.view];
            NSNumber *isOn = [NSNumber numberWithBool:state];
            [TrackingUtils trackEvent:event properties:@{@"state": isOn}];
            [TrackingUtils setPeopleProperties:@{property: isOn}];
            [self.settingsTableView reloadData];
        });
    } failure:^(NSError *error) {
        if (section == SectionTypes.tweet) {
            [User currentUser].autoTweet = !state;
        } else {
            [User currentUser].touchId = !state;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [DesignUtils hideProgressHUDForView:self.view];
            [self.settingsTableView reloadData];
        });
        
    }];
}

- (void)fetchUser {
    // Fetch and reload
    [ApiManager fetchUser:[User currentUser] success:^{
        [self.settingsTableView reloadData];
    } failure:nil];
}

// --------------------------------------------
#pragma mark - Tableview
// --------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionTypes.typesCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    User *user = [User currentUser];
    if (section == SectionTypes.card) {
        return [[User currentUser] paymentMethodNotAvailable] ? 1 : 2;
    } else if (section == SectionTypes.tweet) {
        return [User currentUser].autoTweet ? 2 : 1;
    } else if (section == SectionTypes.pin) {
        return 2;
    } else if (section == SectionTypes.email) {
        return [user isEmailVerified] ? 1 : 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionTypes.tweet && indexPath.row == 1) {
        return self.tweetCellHeight;
    }
    return kSettingsCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [User currentUser];
    if (indexPath.section == SectionTypes.card) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell"];
            cell.textLabel.text = [[User currentUser] paymentMethodNotAvailable] ? NSLocalizedString(@"no_card_section", nil) : NSLocalizedString(@"card_section", nil);
            cell.backgroundColor = [ColorUtils mainGreen];
            cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            if ([User currentUser].paymentMethod == kPaymentMethodApplePay) {
                cell.textLabel.text = @"Apple Pay";
                cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
            } else if (self.customerCard) {
                cell.textLabel.text = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",self.customerCard[@"last4"]];
                cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else if (indexPath.section == SectionTypes.tweet) {
        if (indexPath.row == 0) {
            SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            [cell setTitle:NSLocalizedString(@"auto_tweet_section", nil) delegate:self section:SectionTypes.tweet andSwitchState:user.autoTweet];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
            [cell initWithTweet:user.tweetWording];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
    } else if (indexPath.section == SectionTypes.pin) {
        if (indexPath.row == 0) {
            SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            [cell setTitle:NSLocalizedString(@"pin_section", nil) delegate:self section:SectionTypes.pin andSwitchState:user.touchId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15];
            cell.textLabel.text = NSLocalizedString(@"pin_section_details", nil);
            cell.textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else if (indexPath.section == SectionTypes.email) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = user.email;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"verify_email", nil);
            cell.textLabel.textColor = [ColorUtils red];
            cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];

        }
        return cell;
    } else if (indexPath.section == SectionTypes.support) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"support_section", nil);
        cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        return cell;
    } else if (indexPath.section == SectionTypes.share) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"share_section", nil);
        cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        return cell;
    } else if (indexPath.section == SectionTypes.logout) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"logout_section", nil);
        cell.textLabel.textColor = [ColorUtils red];
        cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionTypes.card) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"Card From Settings" sender:nil];
        }
    } else if (indexPath.section == SectionTypes.email) {
        if (indexPath.row == 0) {
            // change email
            if ([UIAlertController class] != nil) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"modify_email", nil)
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    [self initEmailTextField:textField];
                }];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_button", nil)
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                  UITextField *textfield = alert.textFields.firstObject;
                                                                          [self saveNewEmail:textfield.text];
                              }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_button", nil) style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"modify_email", nil)
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"cancel_button", nil)
                                                          otherButtonTitles:NSLocalizedString(@"ok_button", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [self initEmailTextField:[alertView textFieldAtIndex:0]];
                [alertView show];
            }
        } else if (indexPath.row == 1) {
            // Verify
            [DesignUtils showProgressHUDAddedTo:self.view];
            [ApiManager resendEmailVerificationAndExecuteSuccess:^{
                [DesignUtils hideProgressHUDForView:self.view];
                [GeneralUtils showAlertWithTitle:nil andMessage:NSLocalizedString(@"verification_email_sent", nil)];
            } failure:^(NSError *error) {
                [DesignUtils hideProgressHUDForView:self.view];
            }];
        }
    } else if (indexPath.section == SectionTypes.support) {
        [TrackingUtils trackEvent:EVENT_HOW_TO properties:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"HowToVC"];
        [self presentViewController:vc animated:YES completion:nil];
    } else if (indexPath.section == SectionTypes.share) {
        [self displayShareOptions];
    } else if (indexPath.section == SectionTypes.logout) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"logout_confirmation_message", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"no_button_title", nil)
                          otherButtonTitles:NSLocalizedString(@"yes_button_title", nil), nil] show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,[self headerHeightForSection:section])];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self headerHeightForSection:section];
}

- (CGFloat)headerHeightForSection:(NSInteger)section {
    return (section == SectionTypes.share || section == SectionTypes.logout) ? 0 : kSettingsHeaderHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}



// --------------------------------------------
#pragma mark - TweetTVC protocol
// --------------------------------------------
- (void)adjustHeightOfTweetCell:(NSInteger)height {
    if (height != self.tweetCellHeight) {
        self.tweetCellHeight = height;
        [self.settingsTableView beginUpdates];
        [self.settingsTableView endUpdates];
    }
}

// --------------------------------------------
#pragma mark - Sharing
// --------------------------------------------

// Share to FB, sms, email.. using UIActivityViewController
- (void)displayShareOptions {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"sharing_text",nil),[User currentUser].caseUsername,kOneWebsiteLink];
    NSArray *activityItems = @[message];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityViewController setValue:NSLocalizedString(@"sharing_email_object", nil) forKey:@"subject"];
    
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        if (completed) {
            [TrackingUtils trackEvent:EVENT_INVITE_SENT properties:@{@"sharing_type" : activityType}];
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - UIAlertView
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:NSLocalizedString(@"logout_confirmation_message", nil)]
        && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"yes_button_title", nil)]) {
        [self.delegate logoutUser];
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"modify_email", nil)]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"yes_button_title", nil)]) {
            [self saveNewEmail:[alertView textFieldAtIndex:0].text];
        }
    }
}

- (void)initEmailTextField:(UITextField *)textField {
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.text = [User currentUser].email;
}

- (void)saveNewEmail:(NSString *)string {
    NSError *error = nil;
    NSString *email = [string stringByCorrectingEmailTypos];
    [[SHEmailValidator validator] validateSyntaxOfEmailAddress:email withError:&error];
    if (error) {
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"invalid_email_title", nil) andMessage:NSLocalizedString(@"invalid_email_message", nil)];
        return;
    }
    [DesignUtils showProgressHUDAddedTo:self.view];
    [User currentUser].email = email;
    [ApiManager saveCurrentUserAndExecuteSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [DesignUtils hideProgressHUDForView:self.view];
            [TrackingUtils trackEvent:EVENT_EMAIL_CHANGED properties:nil];
            [self.settingsTableView reloadData];
        });
    } failure:^(NSError *error) {
        [DesignUtils hideProgressHUDForView:self.view];
        [GeneralUtils showAlertWithTitle:NSLocalizedString(@"save_email_error_title", nil) andMessage:[error.userInfo valueForKey:@"error"]];
    }];

}

// --------------------------------------------
#pragma mark - Misc
// --------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
