//
//  AppDelegate.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Mixpanel.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "ApiManager.h"
#import "User.h"

#import "ConstantUtils.h"
#import "OneLogger.h"
#import "InternalNotifView.h"
#import "NotifUtils.h"
#import "TrackingUtils.h"

#define ONEAPPDELEGATELOG YES && GLOBALLOGENABLED

@interface AppDelegate ()

@property (strong, nonatomic) NSDate *sessionStartDate;

@property (nonatomic, strong) NSURL *redirectURL;
@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic) BOOL repeat;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parse
    [Parse enableLocalDatastore];
    [Parse setApplicationId:DEBUG ? kParseDevApplicationId : kParseProdApplicationId
                  clientKey:DEBUG ? kParseDevClientKey : kParseProdClientKey];
    
    // Fabrick
    [Fabric with:@[CrashlyticsKit]];
    
    if (!DEBUG) {
        // Mixpanel
        [Mixpanel sharedInstanceWithToken:kMixpanelProdToken launchOptions:launchOptions];
        
        // Track statistics around application opens.
//        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    } else {
        [Mixpanel sharedInstanceWithToken:kMixpanelDevToken launchOptions:launchOptions];
    }
    
    // Obsolete API
    [ApiManager checkAppVersionAndExecuteSucess:^(NSDictionary * resultDictionnary) {
        if (resultDictionnary && [resultDictionnary valueForKey:@"title"]) {
            self.alertTitle = [resultDictionnary valueForKey:@"title"];
            self.alertMessage = [resultDictionnary valueForKey:@"message"];
            self.repeat = [[resultDictionnary valueForKey:@"blocking"] boolValue];
            if ([resultDictionnary valueForKey:@"redirect_url"]) {
                self.redirectURL = [NSURL URLWithString:[resultDictionnary valueForKey:@"redirect_url"]];
            }
            [self createObsoleteAPIAlertView];
        }
    }];
    
    User *currentUser = [User currentUser];
    if (currentUser) {
        // Identify user
        [TrackingUtils identifyUser:[User currentUser] signup:NO];
        
        // Register for notif
        [NotifUtils registerForRemoteNotif];
        // Check if we come from a new message notif
//        NSNumber *notifOpening = [NSNumber numberWithBool:NO];
        NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotif) {
            // todo BT notif opening
        }

        // todo BT sign up redirection
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.sessionStartDate = [NSDate date];
    
//    [FBSDKAppEvents activateApp];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSNumber *seconds = @([[NSDate date] timeIntervalSinceDate:self.sessionStartDate]);
    [TrackingUtils trackEvent:EVENT_SESSION properties:@{@"Length": seconds}];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    OneLog(ONEAPPDELEGATELOG,@"Register for remote notif");
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation[@"user"] = [PFUser currentUser];
    currentInstallation[@"iosSettings"] = [NSNumber numberWithInteger:[NotifUtils getUserNotificationSettings]];
    [currentInstallation saveEventually];
    
    [TrackingUtils setPeopleProperties:@{PROPERTY_ALLOW_NOTIF: currentInstallation[@"iosSettings"]}];
    
    // This sends the deviceToken to Mixpanel
    [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    if ([[userInfo valueForKey:@"notif_type"] isEqualToString:@"xxxxxx"]) {
        if (state == UIApplicationStateActive) {
            // todo BT
        }
    }
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}

// --------------------------------------------
#pragma mark - Internal notif
// --------------------------------------------
- (void)displayInternalNotif:(NSDictionary *)userInfo {
    InternalNotifView *internalNotif = [[[NSBundle mainBundle] loadNibNamed:@"InternalNotifView" owner:self options:nil] objectAtIndex:0];
    UIView * superView = self.window.rootViewController.view;;
    [internalNotif initWithType:[userInfo valueForKey:@"notif_type"] frame:CGRectMake(0, - kInternalNotifHeight, superView.frame.size.width, kInternalNotifHeight) userId:[userInfo valueForKey:@"userId"] alert:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]];
    [superView addSubview:internalNotif];
    [UIView animateWithDuration:kNotifAnimationDuration
                     animations:^(){
                         internalNotif.frame = CGRectMake(0, 0, superView.frame.size.width, kInternalNotifHeight);
                     } completion:nil];
}

// --------------------------------------------
#pragma mark - Alert view
// --------------------------------------------
- (void)createObsoleteAPIAlertView
{
    if (self.alertTitle && self.alertMessage) {
        [[[UIAlertView alloc] initWithTitle:self.alertTitle
                                    message:self.alertMessage
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok",nil] show];
    }
}

// API related alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.redirectURL) {
        [[UIApplication sharedApplication] openURL:self.redirectURL];
        if (self.repeat) {
            [self createObsoleteAPIAlertView];
        }
    }
}

@end
