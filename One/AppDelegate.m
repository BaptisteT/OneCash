//
//  AppDelegate.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Fabric/Fabric.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Crashlytics/Crashlytics.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Mixpanel.h>
#import <Parse/Parse.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import "SSKeychain.h"
#import <Stripe.h>

#import "AppDelegate.h"
#import "ApiManager.h"
#import "User.h"

#import "WelcomeViewController.h"

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
#if DEBUG
    BOOL debug = true;
#else
    BOOL debug = false;
#endif
    debug = false;
    //Stop app pausing other sound.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // Parse
    [Parse enableLocalDatastore];
    [Parse setApplicationId:debug ? kParseDevApplicationId : kParseProdApplicationId
                  clientKey:debug ? kParseDevClientKey : kParseProdClientKey];
    
    // Twitter
    [PFTwitterUtils initializeWithConsumerKey:kTwitterConsumerKey
                               consumerSecret:kTwitterConsumerSecret];

    // Fabrick
    [Fabric with:@[CrashlyticsKit]];
    
    // Obsolete API
    [ApiManager checkAppVersionAndExecuteSucess:^(NSDictionary * resultDictionnary) {
        if (resultDictionnary && [resultDictionnary valueForKey:@"title"]) {
            // custom screen ??
            self.alertTitle = [resultDictionnary valueForKey:@"title"];
            self.alertMessage = [resultDictionnary valueForKey:@"message"];
            self.repeat = [[resultDictionnary valueForKey:@"blocking"] boolValue];
            if ([resultDictionnary valueForKey:@"redirect_url"]) {
                self.redirectURL = [NSURL URLWithString:[resultDictionnary valueForKey:@"redirect_url"]];
            }
            [self createObsoleteAPIAlertView];
        }
    }];
    
    if (!debug) {
        // Mixpanel
        [Mixpanel sharedInstanceWithToken:kMixpanelProdToken launchOptions:launchOptions];
        
        // Track statistics around application opens.
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
        // Stripe
        [Stripe setDefaultPublishableKey:kStripeLivePublishableKey];
    } else {
        [Mixpanel sharedInstanceWithToken:kMixpanelDevToken launchOptions:launchOptions];
        [Stripe setDefaultPublishableKey:kStripeTestPublishableKey];
    }
    
    User *currentUser = [User currentUser];
    
    // if no email => log out
    if (currentUser && (!currentUser.email || currentUser.email.length == 0) ) {
        currentUser = nil;
        [User logOut];
    }

    if (currentUser) {
        // Identify user
        [TrackingUtils identifyUser:[User currentUser]];
        [ApiManager fetchUser:[User currentUser] success:nil failure:nil];
        [self logFabrikUser];
        
        // Check if we come from a new message notif
        NSNumber *notifOpening = [NSNumber numberWithBool:NO];
        NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotif) {
            if ([[remoteNotif valueForKey:@"notif_type"] isEqualToString:kNotifTypeNewTransaction]) {
                notifOpening = [NSNumber numberWithBool:YES];
            }
        }

        // Navigate
        WelcomeViewController* welcomeViewController = (WelcomeViewController *)  self.window.rootViewController.childViewControllers[0];
        [welcomeViewController performSegueWithIdentifier:@"Send From Welcome" sender:notifOpening];
    }
    
    // Activity
    BOOL isAvailable = (&UIApplicationLaunchOptionsUserActivityDictionaryKey != NULL);
    if (isAvailable) {
        NSDictionary *activityDic = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
        if (activityDic) {
            if ([[activityDic objectForKey:UIApplicationLaunchOptionsUserActivityTypeKey] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
                NSUserActivity *activity = (NSUserActivity *) [activityDic objectForKey:@"UIApplicationLaunchOptionsUserActivityKey"];
                [self performSelector:@selector(handleDeepLink:) withObject:activity.webpageURL afterDelay:1];
            }
        }
    }
    
    // URL
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        [self performSelector:@selector(handleDeepLink:) withObject:url afterDelay:1];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.sessionStartDate = [NSDate date];
    [FBSDKAppEvents activateApp];
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
    NSString *deviceId = [SSKeychain passwordForService:@"deviceIdentifier" account:@"cash.one"];
    if (!deviceId || deviceId.length == 0) {
        deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:deviceId forService:@"deviceIdentifier" account:@"cash.one"];
    }
    currentInstallation[@"deviceIdentifier"] = deviceId;
    currentInstallation[@"iosSettings"] = [NSNumber numberWithInteger:[NotifUtils getUserNotificationSettings]];
    [currentInstallation saveEventually];
    
    [TrackingUtils setPeopleProperties:@{PEOPLE_ALLOW_NOTIF: currentInstallation[@"iosSettings"]}];
    
    // This sends the deviceToken to Mixpanel
    [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    if ([[userInfo valueForKey:@"notif_type"] isEqualToString:kNotifTypeReadTransaction] || [[userInfo valueForKey:@"notif_type"] isEqualToString:kNotifTypeNewTransaction]) {
        if (state == UIApplicationStateActive) {
            // internal notif
            [self displayInternalNotif:userInfo];
            
            // load latest transactions
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTransactionPushReceived
                                                                object:nil
                                                              userInfo:nil];
            
            // Vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushClicked
                                                                object:nil
                                                              userInfo:nil];
        }
    } else if ([[userInfo valueForKey:@"notif_type"] isEqualToString:kNotifTypeReaction]) {
        if (state == UIApplicationStateActive) {
            // internal notif
            [self displayInternalNotif:userInfo];
            
            // load latest transactions
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReactionPushReceived
                                                                object:nil
                                                              userInfo:nil];
            
            // Vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushClicked
                                                                object:nil
                                                              userInfo:nil];
        }
    } else if ([[userInfo valueForKey:@"notif_type"] isEqualToString:kNotifTypeSignup]) {
        if (state == UIApplicationStateActive) {
            // internal notif
            [self displayInternalNotif:userInfo];
            
            // Vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // deeplink
    [self handleDeepLink:url];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


// Handle hyperlink
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        [self handleDeepLink:url];
    }
    return true;
}

- (void)handleDeepLink:(NSURL *)url
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:true];
    if ([components.host containsString:@"one.cash"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserURLScheme
                                                            object:nil
                                                          userInfo:@{@"username": [[url path] stringByReplacingOccurrencesOfString:@"/" withString:@""]}];
    }
}



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
    if (self.alertTitle || self.alertMessage) {
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

// --------------------------------------------
#pragma mark - Fabrik
// --------------------------------------------
- (void)logFabrikUser {
    User *user = [User currentUser];
    [CrashlyticsKit setUserIdentifier:user.objectId];
    if (user.email)
        [CrashlyticsKit setUserEmail:user.email];
    [CrashlyticsKit setUserName:user.caseUsername];
}


@end
