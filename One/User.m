//
//  User.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "ImageCache.h"
#import "User.h"

#import "ConstantUtils.h"

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

@synthesize avatar;

+ (void)load {
    [self registerSubclass];
}

+ (User *)currentUser {
    return (User *)[PFUser currentUser];
}

// Set avatar in imageview (download it first if necessary)
- (void)setAvatarInImageView:(UIImageView *)imageView {
    imageView.image = nil; // clean
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.avatar) {
        [imageView setImage:self.avatar];
    } else {
        CGSize rescaleSize = {kDisplayedPictureSize, kDisplayedPictureSize};
        [[ImageCache defaultCache] imageForURL:[NSURL URLWithString:self.pictureURL]
                                              size:rescaleSize
                                              mode:UIViewContentModeScaleAspectFill
                                    availableBlock:^(UIImage *image) {
                                        if (image) {
                                            self.avatar = image;
                                            [imageView setImage:self.avatar];
                                        }
                                    }];
    }
}

// Delete image
- (void)deleteCachedImage {
    CGSize rescaleSize = {kDisplayedPictureSize, kDisplayedPictureSize};
    [[ImageCache defaultCache] deleteCashedImageForURL:[NSURL URLWithString:self.pictureURL] size:rescaleSize];
}

+ (void)logOut {
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
