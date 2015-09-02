//
//  ApiManager.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "ApiManager.h"
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import "User.h"

#import "ConstantUtils.h"
#import "OneLogger.h"
#import "TrackingUtils.h"

#define ONEAPIMANAGERLOG YES && GLOBALLOGENABLED

@implementation ApiManager

// --------------------------------------------
#pragma mark - Api
// --------------------------------------------

// Check APP version (retrieve potential message and redirection)
+ (void)checkAppVersionAndExecuteSucess:(void(^)(NSDictionary *))successBlock
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [PFCloud callFunctionInBackground:@"checkAppVersion"
                       withParameters:@{ @"version" : version, @"build" : build }
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"checkAppVersion error : %@",error.description);
                                    } else {
                                        if (successBlock) {
                                            successBlock((NSDictionary *)object);
                                        }
                                    }
                                }];
}


// --------------------------------------------
#pragma mark - Log in
// --------------------------------------------
+ (void)logInWithTwitterAndExecuteSuccess:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            OneLog(ONEAPIMANAGERLOG,@"Error - Twitter login - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            OneLog(ONEAPIMANAGERLOG,@"Success - Twitter login - isNew: %d",user.isNew);
            
            // tracking
            [TrackingUtils identifyUser:(User *)user];
            
            // Get twitter info
            [ApiManager getOtherTwitterInfoAndExecuteSuccess:^{
                if (successBlock){
                    successBlock();
                }
            } failure:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
    }];
}


// --------------------------------------------
#pragma mark - Twitter API Call
// --------------------------------------------
+ (void)getOtherTwitterInfoAndExecuteSuccess:(void(^)())successBlock
                            failure:(void(^)(NSError *error))failureBlock
{
    User *user = [User currentUser];
    if (!user) return;
    NSString * twitterUserID = [PFTwitterUtils twitter].userId;
    NSString * twitterScreenName = [PFTwitterUtils twitter].screenName;
    
    if (twitterScreenName && twitterScreenName.length > 0) {
        [user setUsername:twitterScreenName];
    }
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];

//    
//    NSString * urlString = @"https://api.twitter.com/1.1/users/show.json?";
//    if (twitterUserID.length > 0) {
//        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"user_id=%@", twitterUserID]];
//    } else if (twitterScreenName.length > 0) {
//        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"screen_name=%@", twitterScreenName]];
//    } else {
//        OneLog(ONEAPIMANAGERLOG, @"There are no credentials for Twitter login. Something went really wrong !");
//        return;
//    }
//    NSURL *verify = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if ( connectionError == nil) {
            NSError * error = nil;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            OneLog(ONEAPIMANAGERLOG, @"Success - twitter info - %@",result);
            
            NSString * profileImageURL = [result objectForKey:@"profile_image_url_https"];
            if (profileImageURL.length > 0) {
                user.pictureURL = profileImageURL;
            }
            
            NSString * username = [result objectForKey:@"screen_name"];
            if (username.length > 0)
                [user setUsername:[result objectForKey:@"screen_name"]];
            
            NSString * names = [result objectForKey:@"name"];
            if (names.length > 0) {
                NSMutableArray * array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
                if ( array.count > 1){
                    user.lastName = [array lastObject];
                    
                    [array removeLastObject];
                    user.firstName = [array componentsJoinedByString:@" " ];
                }
            }
            if (successBlock) {
                successBlock();
            }
        } else {
            OneLog(ONEAPIMANAGERLOG, @"Failure - twitter info - %@",connectionError);
            if (failureBlock) {
                failureBlock(connectionError);
            }
        }
    }];
}
@end
