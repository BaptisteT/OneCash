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

+ (void)identifyUser:(User *)user signup:(BOOL)flag
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [self setPeopleProperties:@{@"name": user.flashUsername ? user.flashUsername : @"", @"number": user.username, @"score": [NSNumber numberWithInteger:user.score]}];
    
    if (flag) {
        [mixpanel createAlias:user.objectId forDistinctID:mixpanel.distinctId];
        [mixpanel identify:mixpanel.distinctId];
        [TrackingUtils trackEvent:EVENT_USER_SIGNUP properties:nil];
        [TrackingUtils setPeopleProperties:@{@"signup.date": [NSDate date]}];
        [mixpanel flush];
    } else {
        [mixpanel identify:user.objectId];
    }
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

+ (void)incrementPeopleProperty:(NSString *)property {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people increment:property by:[NSNumber numberWithInt:1]];
}

@end
