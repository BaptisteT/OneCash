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
static NSString * const kMixpanelProdToken = @"506506437bc51d99f01653de9a7712b5"; // todo BT
static NSString * const kMixpanelDevToken =  @"506506437bc51d99f01653de9a7712b5";

// Parse
static NSString * const kParseDevApplicationId = @"K2INUP4OggQhZYPbONUhuXj20gaPXmg8HLlQQGjx";
static NSString * const kParseDevClientKey = @"JAmgr9Bu4Oua4bE8fToQshpeNVWDVIrF4cJVMAyz";
static NSString * const kParseProdApplicationId = @"K2INUP4OggQhZYPbONUhuXj20gaPXmg8HLlQQGjx"; // todo BT
static NSString * const kParseProdClientKey = @"JAmgr9Bu4Oua4bE8fToQshpeNVWDVIrF4cJVMAyz"; // todo BT

// Stripe
static NSString * const kStripeTestPublishableKey = @"pk_test_vJ757snlktvqXQsaVU7XHD4i";
static NSString * const kStripeLivePublishableKey = @"pk_live_uyualJWipSrd8tNzfGQDw0Ne";

// Twitter
static NSString * const kTwitterConsumerKey = @"x0mcI75RVimsVZahtSNbhEZWn";
static NSString * const kTwitterConsumerSecret = @"silyysZvTNaNLJxLk1IlJblEh0NhCUPBUXkArgg7of1baAE36u";

// Apple
static NSString * const kApplePayMerchantId = @"merchant.cash.one";

// Web
static NSString * const kOneWebsiteTermsLink = @"http://flashtape.co/#terms"; // todo

// Notif
static float const kInternalNotifDuration = 3;
static NSInteger const kInternalNotifHeight = 60;
static float const kNotifAnimationDuration = 0.5;

// Image
static NSInteger const kDisplayedPictureSize = 128;

// Parse Pin Names
static NSString * const kParseTransactionsName = @"Transactions";

// Messages
static NSInteger const kMaxMessagesLength = 60;

// Sending
static float const kAssociationTimerDuration = 1.;
static NSInteger const kAssociationTransactionsLimit = 10;
