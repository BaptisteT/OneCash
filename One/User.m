//
//  User.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "DatastoreManager.h"
#import "User.h"

#import "ConstantUtils.h"
#import "OneLogger.h"
#import "ImageCache.h"
#import "PaymentUtils.h"
#import "UIImageView+UserName.h"

#define LOCALLOGENABLED NO && GLOBALLOGENABLED

@interface User()
@property (nonatomic, strong) UIImage *bigPicture;
@property (nonatomic, strong) UIImage *smallPicture;
@end


@implementation User

@dynamic pictureURL;
@dynamic caseUsername;
@dynamic firstName;
@dynamic lastName;
@dynamic twitterId;
@dynamic paymentMethod;
@dynamic balance;
@dynamic autoTweet;
@dynamic tweetWording;
@dynamic twitterVerified;
@dynamic managedAccountId;
@dynamic birthDate;
@dynamic touchId;
@dynamic userStatus;
@dynamic isExternal;

@synthesize isNewOverride;
@synthesize bigPicture;
@synthesize smallPicture;

+ (void)load {
    [self registerSubclass];
}

+ (User *)currentUser {
    return (User *)[PFUser currentUser];
}

// Set avatar in imageview (download it first if necessary)
- (void)setAvatarInImageView:(UIImageView *)imageView bigSize:(BOOL)sizeFlag saveLocally:(BOOL)savingFlag {
    imageView.userName = self.username;
    imageView.image = nil; // clean
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *picture = sizeFlag ? self.bigPicture : self.smallPicture;
    if (picture) {
        OneLog(LOCALLOGENABLED,@"setAvatar : direct %@",sizeFlag ? @"big" : @"small");
        [imageView setImage:picture];
    } else {
        if (self.bigPicture) {
            OneLog(LOCALLOGENABLED,@"setAvatar : temp big");
            imageView.image = self.bigPicture;
        } else if (self.smallPicture) {
            OneLog(LOCALLOGENABLED,@"setAvatar : temp small");
            imageView.image = self.smallPicture;
        }
        
        CGFloat size = sizeFlag ? kDisplayedPictureBigSize : kDisplayedPictureSmallSize;
        CGSize rescaleSize = {size, size};
        [[ImageCache defaultCache] imageForURL:[NSURL URLWithString:self.pictureURL]
                                          size:rescaleSize
                                          mode:UIViewContentModeScaleAspectFill
                                availableBlock:^(UIImage *image) {
                                        if (image) {
                                            OneLog(LOCALLOGENABLED,@"setAvatar : dl %@",sizeFlag ? @"big" : @"small");
                                            if (sizeFlag) {
                                                self.bigPicture = image;
                                            } else {
                                                self.smallPicture = image;
                                            }
                                            if ([self.username isEqualToString:imageView.userName]) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [imageView setImage:image];
                                                });
                                            }
                                        }
                                }   saveLocally:savingFlag];
    }
}

// Set avatar in button
- (void)setAvatarInButton:(UIButton *)button bigSize:(BOOL)flag {
    [button setImage:nil forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *picture = flag ? self.bigPicture : self.smallPicture;
    if (picture) {
        OneLog(LOCALLOGENABLED,@"setAvatar : direct %@",flag ? @"big" : @"small");
        [button setImage:picture forState:UIControlStateNormal];
    } else {
        if (self.bigPicture) {
            OneLog(LOCALLOGENABLED,@"setAvatar : temp big");
            [button setImage:self.bigPicture forState:UIControlStateNormal];
        } else if (self.smallPicture) {
            OneLog(LOCALLOGENABLED,@"setAvatar : temp small");
            [button setImage:self.smallPicture forState:UIControlStateNormal];
        }
        
        CGFloat size = flag ? kDisplayedPictureBigSize : kDisplayedPictureSmallSize;
        CGSize rescaleSize = {size, size};
        [[ImageCache defaultCache] imageForURL:[NSURL URLWithString:self.pictureURL]
                                          size:rescaleSize
                                          mode:UIViewContentModeScaleAspectFill
                                availableBlock:^(UIImage *image) {
                                    if (image) {
                                        OneLog(LOCALLOGENABLED,@"setAvatar : dl %@",flag ? @"big" : @"small");
                                        if (flag) {
                                            self.bigPicture = image;
                                        } else {
                                            self.smallPicture = image;
                                        }
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [button setImage:image forState:UIControlStateNormal];
                                        });
                                    }
                                }   saveLocally:YES];
    }
}

+ (NSArray *)createUsersFromTwitterResultArray:(NSArray *)twitterUsers
{
    NSMutableArray *results = [NSMutableArray new];
    for (NSDictionary *twitterUser in twitterUsers) {
        User *user = [User new];
        [user updateUserWithTwitterInfo:twitterUser];
        user.isExternal = true;
        [results addObject:user];
    }
    return results;
}

- (void)updateUserWithTwitterInfo:(NSDictionary *)twitterInfo
{
    // Profile picture
    NSString * imageUrl = [twitterInfo objectForKey:@"profile_image_url_https"];
    if (imageUrl) {
        NSString * profileImageURL = [imageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        if (profileImageURL.length > 0 && ![self.pictureURL isEqualToString:profileImageURL]) {
            self.pictureURL = profileImageURL;
        }
    }
    
    // Username
    NSString * username = [twitterInfo objectForKey:@"screen_name"];
    if (username.length > 0 && ![self.caseUsername isEqualToString:username]) {
        self.caseUsername = [twitterInfo objectForKey:@"screen_name"];
        [self setUsername:[self.caseUsername lowercaseString]];
    }
    
    // Id
    NSString * twitterId = [[twitterInfo objectForKey:@"id"] stringValue];
    if (twitterId && twitterId.length > 0 && ![self.twitterId isEqualToString:twitterId]) {
        self.twitterId = twitterId;
    }
    
    // Email
    NSString * email = [twitterInfo objectForKey:@"email"];
    if (email && email.length > 0 && !self.email) {
        self.email = [twitterInfo objectForKey:@"email"];
    }
    
    // Names
    NSString * names = [twitterInfo objectForKey:@"name"];
    if (names.length > 0 && !self.lastName) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
        self.fullName = [[[NSString alloc] initWithData: [names dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding] lowercaseString];
        if ( array.count > 1){
            self.lastName = [array lastObject];
            
            [array removeLastObject];
            self.firstName = [array componentsJoinedByString:@" " ];
        }
    }
    // Certified
    if ([twitterInfo objectForKey:@"verified"] && self.twitterVerified != [[twitterInfo objectForKey:@"verified"] boolValue]) {
        self.twitterVerified = [[twitterInfo objectForKey:@"verified"] boolValue];
    }
}


// Delete image
- (void)deleteCachedImage {
    CGSize rescaleSize = {kDisplayedPictureSmallSize, kDisplayedPictureSmallSize};
    [[ImageCache defaultCache] deleteCashedImageForURL:[NSURL URLWithString:self.pictureURL] size:rescaleSize];
    
}

+ (void)logOut {
    [DatastoreManager cleanLocalData];
    [super logOut];
}

- (BOOL)isEmailVerified {
    if ([self objectForKey:@"emailVerified"]) {
        return [[self objectForKey:@"emailVerified"] boolValue];
    } else {
        return NO;
    }
}

- (BOOL)isNew {
    if (self.isNewOverride) {
        return true;
    } else {
        return [super isNew];
    }
}

- (BOOL)paymentMethodNotAvailable {
    return self.paymentMethod == kPaymentMethodNone || (self.paymentMethod == kPaymentMethodApplePay && ![PaymentUtils applePayEnabled]);
}

@end
