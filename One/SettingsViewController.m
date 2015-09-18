//
//  SettingsViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "NSString+EmailAddresses.h"
#import "SHEmailValidator.h"

#import "ApiManager.h"
#import "User.h"

#import "SettingsViewController.h"
#import "SwitchTableViewCell.h"
#import "TweetTableViewCell.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "TrackingUtils.h"

typedef NS_ENUM(NSInteger,SectionTypes) {
    kCardSection = 0,
    kAutoTweetSection = kCardSection + 1,
    kPinSection = 1000,
    kEmailSection = kAutoTweetSection + 1,
    kSupportSection = kEmailSection + 1,
    kShareSection = kSupportSection + 1,
    kLogoutSection = kShareSection + 1,
    kSectionTypesCount = kLogoutSection + 1
};

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSArray *customerCards;
@property (nonatomic) NSInteger tweetCellHeight;

@end

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.tweetCellHeight = kSettingsCellHeight;
    
    // UI
    [self.backButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.titleLabel.textColor = [ColorUtils mainGreen];
    
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
    
    // Callback
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willBecomeActiveCallback)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    // Get card
    [ApiManager getCustomerCardsAndExecuteSuccess:^(NSArray *cards){
        self.customerCards = cards;
        [self.settingsTableView reloadData];
    } failure:nil];
}


- (void)willBecomeActiveCallback {
    // Fetch and reload
    [ApiManager fetchCurrentUserAndExecuteSuccess:^{
        [self.settingsTableView reloadData];
    } failure:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)slideSwitched:(BOOL)state ofSection:(NSInteger)section {
    if (section == kAutoTweetSection) {
        [DesignUtils showProgressHUDAddedTo:self.view];
        [User currentUser].autoTweet = state;
        [ApiManager saveCurrentUserAndExecuteSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [DesignUtils hideProgressHUDForView:self.view];
                NSNumber *isOn = [NSNumber numberWithBool:state];
                [TrackingUtils trackEvent:EVENT_AUTO_TWEET_CHANGED properties:@{@"state": isOn}];
                [TrackingUtils setPeopleProperties:@{PEOPLE_AUTO_TWEET: isOn}];
                [self.settingsTableView reloadData];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DesignUtils hideProgressHUDForView:self.view];
                [self.settingsTableView reloadData];
            });

        }];
    } else if (section == kPinSection) {
        // todo BT
    }
}

// --------------------------------------------
#pragma mark - Tableview
// --------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSectionTypesCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    User *user = [User currentUser];
    if (section == kCardSection) {
        return [User currentUser].paymentMethod > 0 ? 2 : 1;
    } else if (section == kAutoTweetSection) {
        return [User currentUser].autoTweet ? 2 : 1;
    } else if (section == kPinSection) {
        return 2;
    } else if (section == kEmailSection) {
        return [user isEmailVerified] ? 1 : 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kAutoTweetSection && indexPath.row == 1) {
        return self.tweetCellHeight;
    }
    return kSettingsCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [User currentUser];
    if (indexPath.section == kCardSection) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell"];
            cell.textLabel.text = user.paymentMethod == kPaymentMethodNone ? NSLocalizedString(@"no_card_section", nil) : NSLocalizedString(@"card_section", nil);
            cell.backgroundColor = [ColorUtils mainGreen];
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            if ([User currentUser].paymentMethod == kPaymentMethodApplePay) {
                cell.textLabel.text = @"Apple Pay";
            } else if (self.customerCards && self.customerCards.count > 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"XXX XXXX XXXX %@",self.customerCards[0][@"last4"]];
            }
            return cell;
        }
    } else if (indexPath.section == kAutoTweetSection) {
        if (indexPath.row == 0) {
            SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            [cell setTitle:NSLocalizedString(@"auto_tweet_section", nil) delegate:self section:kAutoTweetSection andSwitchState:user.autoTweet];
            return cell;
        } else {
            TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
            [cell initWithTweet:user.tweetWording];
            cell.delegate = self;
            return cell;
        }
    } else if (indexPath.section == kPinSection) {
        if (indexPath.row == 0) {
            SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            [cell setTitle:NSLocalizedString(@"pin_section", nil) delegate:self section:kPinSection andSwitchState:NO]; // todo BT
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.text = NSLocalizedString(@"pin_section_details", nil);
            return cell;
        }
    } else if (indexPath.section == kEmailSection) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = user.email;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"verify_email", nil);
            cell.textLabel.textColor = [ColorUtils red];
        }
        return cell;
    } else if (indexPath.section == kSupportSection) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"support_section", nil);
        return cell;
    } else if (indexPath.section == kShareSection) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"share_section", nil);
        return cell;
    } else if (indexPath.section == kLogoutSection) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"logout_section", nil);
        cell.textLabel.textColor = [ColorUtils red];
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kCardSection) {
        if (indexPath.row == 0)
            [self.delegate navigateToCardController];
    } else if (indexPath.section == kEmailSection) {
        if (indexPath.row == 0) {
            // change email
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"modify_email", nil)
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.keyboardType = UIKeyboardTypeEmailAddress;
                textField.textAlignment = NSTextAlignmentCenter;
                textField.text = [User currentUser].email;
            }];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_button", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      UITextField *textfield = alert.textFields.firstObject;
                                                                      NSError *error = nil;
                                                                      NSString *email = [textfield.text stringByCorrectingEmailTypos];
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
                                                                          [GeneralUtils showAlertWithTitle:NSLocalizedString(@"save_email_error_title", nil) andMessage:NSLocalizedString(@"save_email_error_message", nil)];
                                                                      }];
                                                                  }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_button", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:defaultAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
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
    } else if (indexPath.section == kSupportSection) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kOneWebsiteSupportLink]];
    } else if (indexPath.section == kShareSection) {
        [self displayShareOptions];
    } else if (indexPath.section == kLogoutSection) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"logout_confirmation_message", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"no_button_title", nil)
                          otherButtonTitles:NSLocalizedString(@"yes_button_title", nil), nil] show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,kSettingsHeaderHeight)];
    if (section != kCardSection) {
        CGFloat separatorHeight = 0.3;
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, kSettingsHeaderHeight - separatorHeight, self.view.frame.size.width,separatorHeight)];
        separator.backgroundColor = [self.settingsTableView separatorColor];
        [headerView addSubview:separator];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kShareSection || section == kLogoutSection) {
        return 0;
    } else {
        return kSettingsHeaderHeight;
    }
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
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            [TrackingUtils trackEvent:EVENT_INVITE_SENT properties:@{@"sharing_type" : activityType}];
        }
    };
    [self presentViewController:activityViewController animated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - UIAlertView
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:NSLocalizedString(@"logout_confirmation_message", nil)]
        && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"yes_button_title", nil)]) {
        [self.delegate logoutUser];
    }
}

@end
