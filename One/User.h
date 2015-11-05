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
@property (retain) NSString *fullName;
@property (retain) NSString *twitterId;
@property (nonatomic) PaymentMethod paymentMethod;
@property (nonatomic) NSInteger balance;
@property (nonatomic) BOOL autoTweet;
@property (nonatomic) BOOL touchId;
@property (retain) NSString *tweetWording;
@property (nonatomic) BOOL twitterVerified;
@property (nonatomic) NSString *managedAccountId;
@property (nonatomic) NSDate *birthDate;
@property (nonatomic) NSString *userStatus;
@property (nonatomic) BOOL isExternal;

// local
@property (nonatomic) BOOL isNewOverride;

- (void)setAvatarInImageView:(UIImageView *)imageView bigSize:(BOOL)sizeFlag saveLocally:(BOOL)savingFlag;
- (void)setAvatarInButton:(UIButton *)button bigSize:(BOOL)flag;
- (BOOL)isEmailVerified;
- (void)updateUserWithTwitterInfo:(NSDictionary *)twitterInfo;

+ (NSArray *)createUsersFromTwitterResultArray:(NSArray *)twitterUsers;

- (BOOL)isNew;
- (BOOL)paymentMethodNotAvailable;

@end
