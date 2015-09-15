//
//  User.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/parse.h>

@interface User : PFUser <PFSubclassing>

typedef NS_ENUM(NSInteger,PaymentMethod) {
    kPaymentMethodNone = 0,
    kPaymentMethodApplePay = 1,
    kPaymentMethodStripe = 2,
};

// Server
@property (retain) NSString *caseUsername;
@property (retain) NSString *pictureURL;
@property (retain) NSString *firstName;
@property (retain) NSString *lastName;
@property (retain) NSString *twitterId;
@property (nonatomic) PaymentMethod paymentMethod;
@property (nonatomic) NSInteger balance;
@property (nonatomic) BOOL autoTweet;
@property (retain) NSString *tweetWording;
@property (nonatomic) BOOL verified;
//@property (nonatomic) NSString *managedAccountId;

// Local
@property (nonatomic, strong) UIImage *avatar;

- (void)setAvatarInImageView:(UIImageView *)imageView;
- (BOOL)isEmailVerified;

@end
