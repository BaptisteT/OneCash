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

+ (void)load {
    [self registerSubclass];
}

//+ (User *)createUserWithUsername:(NSString *)username
//                           email:(NSString *)email
//                        password:(NSString *)password
//{
//    User *user = (User *)[PFUser user];
//    user.username = @"my name";
//    user.password = @"my pass";
//    user.email = @"email@example.com";
//    return user;
//}

+ (User *)currentUser {
    return (User *)[PFUser currentUser];
}

@end
