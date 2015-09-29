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
                                            if ([self.objectId isEqualToString:imageView.userId]) {
                                                [imageView setImage:image];
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
