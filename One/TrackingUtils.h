//
//  TrackingUtils.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#define EVENT_USER_SIGNUP @"user.signup"
#define EVENT_SESSION @"session"

#define PROPERTY_ALLOW_NOTIF @"notif.allowed"

@interface TrackingUtils : NSObject

+ (void)identifyUser:(User *)user;

+ (void)trackEvent:(NSString *)eventName properties:(NSDictionary *)properties;

+ (void)setPeopleProperties:(NSDictionary *)properties;

+ (void)incrementPeopleProperty:(NSString *)property;

@end
