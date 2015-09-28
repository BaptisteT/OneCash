//
//  TrackingUtils.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "TrackingUtils.h"

#import "Mixpanel.h"
#import <Parse/parse.h>

@implementation TrackingUtils

+ (void)identifyUser:(User *)user
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    if (user.isNew) {
        [mixpanel createAlias:user.objectId forDistinctID:mixpanel.distinctId];
        [mixpanel identify:mixpanel.distinctId];
        [TrackingUtils trackEvent:EVENT_USER_SIGNUP properties:nil];
        [TrackingUtils setPeopleProperties:@{PEOPLE_SIGNUP_DATE: [NSDate date], PEOPLE_SENDING_TOTAL: @0, PEOPLE_CASHOUT_TOTAL: @0}];
    } else {
        [mixpanel identify:user.objectId];
    }
    [mixpanel flush];
}

+ (void)trackEvent:(NSString *)eventName properties:(NSDictionary *)properties
{
    // Parse
    [PFAnalytics trackEventInBackground:eventName block:nil];
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSArray *arrayWithoutMixpanelEventTracking = @[];
    if ([arrayWithoutMixpanelEventTracking indexOfObject:eventName] == NSNotFound) {
        [mixpanel track:eventName properties:properties];
    }
    
    NSArray *arrayWithMixpanelPeopleTracking = @[];
    if ([arrayWithMixpanelPeopleTracking indexOfObject:eventName] != NSNotFound) {
        [mixpanel.people increment:eventName by:[NSNumber numberWithInt:1]];
    }
}

+ (void)setPeopleProperties:(NSDictionary *)properties
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people set:properties];
}

+ (void)incrementPeopleProperty:(NSString *)property byValue:(int)increment{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people increment:property by:[NSNumber numberWithInt:1]];
}

@end
