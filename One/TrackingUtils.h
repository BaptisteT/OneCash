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
#define EVENT_SESSION @"session" // property : length (seconds)
#define EVENT_TWITTER_CONNECT @"twitter_connect" 
#define EVENT_TWITTER_CONNECT_FAIL @"twitter_connect.fail" // property : cause
#define EVENT_HOW_TO @"how_to.clicked"
#define EVENT_EMAIL_INPUT @"email.input"
#define EVENT_EMAIL_CHANGED @"email.changed"
#define EVENT_CARD_LATER_CLICKED @"card_later.clicked"
#define EVENT_APPLE_PAY_CLICKED @"apple_pay.clicked" 
#define EVENT_STRIPE_CLICKED @"stripe.clicked"
#define EVENT_STRIPE_CREATE_TOKEN_WITH_CARD @"stripe.card.token.create" // property : success
#define EVENT_STRIPE_CREATE_CUSTOMER @"stripe.customer.create" // property : success
#define EVENT_CASH_SWIPED @"cash.swiped"
#define EVENT_CREATE_PAYMENT @"payment.create" // property : amount, message, method
#define EVENT_CREATE_PAYMENT_FAIL @"payment.fail" // property : amount, message, method, error
#define EVENT_CASHOUT_CLICKED @"cashout.clicked"
#define EVENT_MANAGED_ACCOUNT_CREATE @"managed_account.create" // property : all params of managed account
#define EVENT_MANAGED_ACCOUNT_FAIL @"managed_account.fail"
#define EVENT_MANAGED_ACCOUNT_ADD_CARD @"managed_account.card.add" // property : success
#define EVENT_CREATE_CASHOUT @"cashout.create" // property : amount
#define EVENT_CREATE_CASHOUT_FAIL @"cashout.fail"
#define EVENT_INVITE_SENT @"invite.sent" // property : sharing_type
#define EVENT_SETTINGS_CLICKED @"settings.clicked"
#define EVENT_BALANCE_CLICKED @"balance.clicked"
#define EVENT_RECIPIENT_CLICKED @"recipient.clicked"
#define EVENT_RECIPIENT_SET @"recipient.set" // property : preselected
#define EVENT_AUTO_TWEET_CHANGED @"auto_tweet.changed" // property : state
#define EVENT_TOUCH_ID_CHANGED @"touchId.changed" // property : state
#define EVENT_SHARE_USERNAME_CLICKED @"share_username.clicked"
#define EVENT_SHARE_INSTAGRAM @"share.instagram"
#define EVENT_SHARE_TWITTER @"share.twitter"
#define EVENT_SHARE_FACEBOOK @"share.facebook"
#define EVENT_TWITTER_FOLLOW @"twitter.follow"
#define EVENT_TWITTER_PROFILE @"twitter.profile"
#define EVENT_TWITTER_TWEET @"twitter.tweet"
#define EVENT_REACTION_CREATE @"reaction.create"
// refund transactions

// Reactions


#define PEOPLE_SIGNUP_DATE @"signup.date"
#define PEOPLE_ALLOW_NOTIF @"notif"
#define PEOPLE_PAYMENT_METHOD @"payment_method"
#define PEOPLE_USERNAME @"username"
#define PEOPLE_EMAIL @"email"
#define PEOPLE_FIRST_NAME @"first_name"
#define PEOPLE_LAST_NAME @"last_name"
#define PEOPLE_BALANCE @"balance"
#define PEOPLE_SENDING_TOTAL @"payment_sent.total"
#define PEOPLE_CASHOUT_TOTAL @"cashout.total"
#define PEOPLE_AUTO_TWEET @"auto_tweet"
#define PEOPLE_TOUCH_ID @"touchId"

@interface TrackingUtils : NSObject

+ (void)identifyUser:(User *)user;

+ (void)trackEvent:(NSString *)eventName properties:(NSDictionary *)properties;

+ (void)setPeopleProperties:(NSDictionary *)properties;

+ (void)incrementPeopleProperty:(NSString *)property byValue:(int)increment;

@end
