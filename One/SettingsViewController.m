//
//  SettingsViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "ApiManager.h"
#import "User.h"

#import "SettingsViewController.h"
#import "SwitchTableViewCell.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "TrackingUtils.h"

typedef NS_ENUM(NSInteger,SectionTypes) {
    kCardSection = 0,
    kAutoTweetSection = 1,
    kPinSection = 2,
    kEmailSection = 3,
    kSupportSection = 4,
    kShareSection = 5,
    kLogoutSection = 6,
    kSectionTypesCount = 7
};

// todo BT add current card 4 digits or APPle pay to card section

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)slideSwitched:(BOOL)state ofSection:(NSInteger)section {
    if (section == kAutoTweetSection) {
        
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
    if (section == kAutoTweetSection) {
        return 1;
    } else if (section == kPinSection) {
        return 2;
    } else if (section == kEmailSection) {
        return 1 + ([user isEmailVerified] ? 0 : 1);
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSettingsCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [User currentUser];
    if (indexPath.section == kCardSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell"];
        cell.textLabel.text = user.paymentMethod == kPaymentMethodNone ? NSLocalizedString(@"no_card_section", nil) : NSLocalizedString(@"card_section", nil);
        cell.backgroundColor = [ColorUtils mainGreen];
        return cell;
    } else if (indexPath.section == kAutoTweetSection) {
        SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        [cell setTitle:NSLocalizedString(@"auto_tweet_section", nil) delegate:self section:kAutoTweetSection andSwitchState:user.autoTweet];
        return cell;
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
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"email_section", nil),user.email];
        } else {
            cell.textLabel.text = NSLocalizedString(@"email_verification", nil);
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
        [self.delegate navigateToCardController];
    } else if (indexPath.section == kEmailSection) {
        if (indexPath.row == 0) {
            // todo BT
            // change email
        } else {
            // todo BT
            // alert to explain email 
            [ApiManager resendEmailVerification];
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
