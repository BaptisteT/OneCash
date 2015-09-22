//
//  ConstantUtils.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GLOBALLOGENABLED YES

@interface ConstantUtils : NSObject
@end

//Mixpanel token
static NSString * const kMixpanelProdToken = @"3fc319f91161a33dab30397701b16f42";
static NSString * const kMixpanelDevToken =  @"506506437bc51d99f01653de9a7712b5";

// Parse
static NSString * const kParseDevApplicationId = @"K2INUP4OggQhZYPbONUhuXj20gaPXmg8HLlQQGjx";
static NSString * const kParseDevClientKey = @"JAmgr9Bu4Oua4bE8fToQshpeNVWDVIrF4cJVMAyz";
static NSString * const kParseProdApplicationId = @"kUoVVYKOU1IwRkRJoKoL1xkxWhqHo5tcqYydwhQm";
static NSString * const kParseProdClientKey = @"jk58nlgw2N8gBVtdOWB05KjPys45Cg4KjMueBmIr";

// Stripe
static NSString * const kStripeTestPublishableKey = @"pk_test_vJ757snlktvqXQsaVU7XHD4i";
static NSString * const kStripeLivePublishableKey = @"pk_live_uyualJWipSrd8tNzfGQDw0Ne";

// Twitter
static NSString * const kTwitterConsumerKey = @"x0mcI75RVimsVZahtSNbhEZWn";
static NSString * const kTwitterConsumerSecret = @"silyysZvTNaNLJxLk1IlJblEh0NhCUPBUXkArgg7of1baAE36u";

// Apple
static NSString * const kApplePayMerchantId = @"merchant.cash.one";

// Web
static NSString * const kOneWebsiteTermsLink = @"http://one.cash/#terms";
static NSString * const kOneWebsiteSupportLink = @"http://one.cash/#support";
static NSString * const kOneWebsiteLink = @"http://one.cash";
static NSString * const kStripeWebsiteTermsLink = @"https://stripe.com/connect/account-terms";

// Notif
static float const kInternalNotifDuration = 3;
static NSInteger const kInternalNotifHeight = 60;
static float const kNotifAnimationDuration = 0.5;

// Image
static NSInteger const kDisplayedPictureBigSize = 1024;
static NSInteger const kDisplayedPictureSmallSize = 128;

// Parse Pin Names
static NSString * const kParseTransactionsName = @"Transactions";
static NSString * const kParseUsersName = @"OneUsers";

// Messages
static NSInteger const kMaxMessagesLength = 30;

// Sending
static float const kAssociationTimerDuration = 2.;
static NSInteger const kAssociationTransactionsLimit = 50;

// Settings
static float const kSettingsHeaderHeight = 25.;
static float const kSettingsCellHeight = 50.;
static float const kMaxTweetLength = 120.;
