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
#import "ImageCache.h"
#import "UIImageView+UserId.h"

@interface User()
@property (nonatomic, strong) UIImage *userPicture;
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

@synthesize userPicture;

+ (void)load {
    [self registerSubclass];
}

+ (User *)currentUser {
    return (User *)[PFUser currentUser];
}

// Set avatar in imageview (download it first if necessary)
- (void)setAvatarInImageView:(UIImageView *)imageView bigSize:(BOOL)sizeFlag saveLocally:(BOOL)savingFlag {
    imageView.userId = self.objectId;
    imageView.image = nil; // clean
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.userPicture) {
        [imageView setImage:self.userPicture];
    } else {
        CGFloat size = sizeFlag ? kDisplayedPictureBigSize : kDisplayedPictureSmallSize;
        CGSize rescaleSize = {size, size};
        [[ImageCache defaultCache] imageForURL:[NSURL URLWithString:self.pictureURL]
                                          size:rescaleSize
                                          mode:UIViewContentModeScaleAspectFill
                                availableBlock:^(UIImage *image) {
                                        if (image) {
                                            self.userPicture = image;
                                            NSLog(@"%@ / %@",self.objectId,imageView.userId);
                                            if ([self.objectId isEqualToString:imageView.userId]) {
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
    if (self.userPicture) {
        [button setImage:self.userPicture forState:UIControlStateNormal];
    } else {
        CGFloat size = flag ? kDisplayedPictureBigSize : kDisplayedPictureSmallSize;
        CGSize rescaleSize = {size, size};
        [[ImageCache defaultCache] imageForURL:[NSURL URLWithString:self.pictureURL]
                                          size:rescaleSize
                                          mode:UIViewContentModeScaleAspectFill
                                availableBlock:^(UIImage *image) {
                                    if (image) {
                                        self.userPicture = image;
                                        [button setImage:self.userPicture forState:UIControlStateNormal];
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
        user.objectId = user.username;
        [results addObject:user];
    }
    return results;
}

- (void)updateUserWithTwitterInfo:(NSDictionary *)twitterInfo
{
    // Profile picture
    NSString * profileImageURL = [[twitterInfo objectForKey:@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    
    if (profileImageURL.length > 0 && ![self.pictureURL isEqualToString:profileImageURL]) {
        self.pictureURL = profileImageURL;
    }
    // Username
    NSString * username = [twitterInfo objectForKey:@"screen_name"];
    if (username.length > 0 && ![self.caseUsername isEqualToString:username]) {
        self.caseUsername = [twitterInfo objectForKey:@"screen_name"];
        [self setUsername:[self.caseUsername lowercaseString]];
    }
    
    // Email
    NSString * email = [twitterInfo objectForKey:@"email"];
    if (email.length > 0 && ![self.email isEqualToString:email]) {
        self.email = [twitterInfo objectForKey:@"email"];
    }
    
    // Names
    NSString * names = [twitterInfo objectForKey:@"name"];
    if (names.length > 0 && !self.lastName) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
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


@end
