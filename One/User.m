//
//  User.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic pictureURL;
@dynamic firstName;
@dynamic lastName;
@dynamic twitterId;
@dynamic paymentMethod;
@dynamic balance;

+ (void)load {
    [self registerSubclass];
}

+ (User *)currentUser {
    return (User *)[PFUser currentUser];
}

@end
