//
//  WelcomeViewController.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "ApiManager.h"

#import "SendCashViewController.h"
#import "WelcomeViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "OneLogger.h"
#import "TrackingUtils.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *howToButton;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;

@end

@implementation WelcomeViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // wording
    self.taglineLabel.text = NSLocalizedString(@"tagline_label", nil);
    [self.loginButton setTitle:NSLocalizedString(@"twitter_button", nil) forState:UIControlStateNormal];
    
    // UI
    self.view.backgroundColor = [ColorUtils mainGreen];
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height / 2;
    [self.loginButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.howToButton.layer.cornerRadius = self.howToButton.frame.size.height / 2;
    [self.howToButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.howToButton.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"Send From Welcome"]) {
        if ([sender boolValue]) {
            ((SendCashViewController *) [segue destinationViewController]).navigateDirectlyToBalance = YES;
        }
    }
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)loginWithTwitter:(id)sender {
    [DesignUtils showProgressHUDAddedTo:self.view withColor:[UIColor whiteColor]];
    [ApiManager logInWithTwitterAndExecuteSuccess:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DesignUtils hideProgressHUDForView:self.view];
            // Rediect to send if email already in / email otherwise
            NSString *email = [User currentUser].email;
            if (email && email.length > 0) {
                [ApiManager saveCurrentUserAndExecuteSuccess:^{
                    if ([User currentUser].isNew) {
                        [self performSegueWithIdentifier:@"Card From Welcome" sender:nil];
                    } else {
                        [self performSegueWithIdentifier:@"Send From Welcome" sender:nil];
                    }
                } failure:^(NSError *error) {
                    // todo BT
                    // do something for the existing email case
                    [User logOut];
                }];
            } else {
               [self performSegueWithIdentifier:@"Email From Welcome" sender:nil];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [User logOut];
            [DesignUtils hideProgressHUDForView:self.view];
        });
    }];
}

- (IBAction)howToButtonClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_HOW_TO properties:nil];
    [self performSegueWithIdentifier:@"How From Welcome" sender:nil];
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
