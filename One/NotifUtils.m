//
//  NotifUtils.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "NotifUtils.h"

@implementation NotifUtils

#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// Resgister user notification settings (request permission to user on 1st call)
// On iOS 7, acceptance  a token
+ (void)registerForRemoteNotif
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) { // ios 8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

// Get token without asking notif settings --> for silent notif (ios8 + only)
+ (void)registerForSilentRemoteNotif
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) { // ios 8
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

+ (BOOL)isRegisteredForRemoteNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) { // ios 8
        return ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications] && [[UIApplication sharedApplication] currentUserNotificationSettings] > 0);
    } else { // ios 7
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] > 0;
    }
}

+ (NSUInteger)getUserNotificationSettings
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS8+
        if (![UIApplication sharedApplication].isRegisteredForRemoteNotifications) {
            return 0;
        } else {
            return [UIApplication sharedApplication].currentUserNotificationSettings.types;
        }
    } else {
        // iOS7 and below
        return [UIApplication sharedApplication].enabledRemoteNotificationTypes;
    }
}

@end
