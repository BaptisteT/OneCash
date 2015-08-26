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
static NSString * const kMixpanelProdToken = @"51d7f02e924b3babe98ea09ca2dd423b";
static NSString * const kMixpanelDevToken =  @"63dfc77a4f9c9db92af63498197bb327";

// Parse
static NSString * const kParseDevApplicationId = @"Posts";
static NSString * const kParseDevClientKey = @"Posts";
static NSString * const kParseProdApplicationId = @"Posts";
static NSString * const kParseProdClientKey = @"Posts";

// Notif
static float const kInternalNotifDuration = 3;
static NSInteger const kInternalNotifHeight = 60;
static float const kNotifAnimationDuration = 0.5;