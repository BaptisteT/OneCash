//
//  NotifUtils.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface NotifUtils : NSObject

// Resgister user notification settings (request permission to user on 1st call)
+ (void)registerForRemoteNotif;

// Get token without asking notif permissions --> for silent notif (ios8 + only)
+ (void)registerForSilentRemoteNotif;

+ (BOOL)isRegisteredForRemoteNotification;

+ (NSUInteger)getUserNotificationSettings;

@end
