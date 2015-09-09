//
//  ApiManager.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <ParseTwitterUtils/ParseTwitterUtils.h>

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "Transaction.h"
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
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - checkAppVersion - %@",error.description);
                                    } else {
                                        if (successBlock) {
                                            successBlock((NSDictionary *)object);
                                        }
                                    }
                                }];
}


// --------------------------------------------
#pragma mark - Twitter log in
// --------------------------------------------
+ (void)logInWithTwitterAndExecuteSuccess:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock
{
    @try {
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
    @catch (NSException * e) {
        OneLog(ONEAPIMANAGERLOG,@"Exception: %@", e);
        if (failureBlock) {
            failureBlock(nil);
        }
    }
}

+ (void)getOtherTwitterInfoAndExecuteSuccess:(void(^)())successBlock
                                     failure:(void(^)(NSError *error))failureBlock
{
    User *user = [User currentUser];
    if (!user) {
        if (failureBlock) {
            failureBlock(nil);
        }
        return;
    }

    NSString * twitterUserID = [PFTwitterUtils twitter].userId;
    NSString * twitterScreenName = [PFTwitterUtils twitter].screenName;
    
    if (twitterUserID && twitterUserID.length > 0) {
        user.twitterId = twitterUserID;
    }
    if (twitterScreenName && twitterScreenName.length > 0) {
        user.caseUsername = twitterScreenName;
        [user setUsername:[user.caseUsername lowercaseString]];
    }
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];

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
            if (username.length > 0) {
                user.caseUsername = [result objectForKey:@"screen_name"];
                [user setUsername:[user.caseUsername lowercaseString]];
            }
            
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



// --------------------------------------------
#pragma mark - User
// --------------------------------------------
+ (void)updateCurrentUserInfo:(NSString *)email
                      success:(void(^)())successBlock
                      failure:(void(^)(NSError *error))failureBlock
{
    User *user = [User currentUser]; // there should be unsaved changed (username / picture URL..)
    user.email = email;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            OneLog(ONEAPIMANAGERLOG,@"Success - Update User");
            if (successBlock) {
                successBlock();
            }
        } else {
            OneLog(ONEAPIMANAGERLOG,@"Failure - Update User - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

+ (void)createStripeCustomerWithToken:(NSString *)token
                        paymentMethod:(PaymentMethod)method
                              success:(void(^)())successBlock
                              failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"createStripeCustomer"
                       withParameters:@{ @"stripeToken" : token, @"paymentMethod" : [NSNumber numberWithInteger:method] }
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - createStripeCustomer - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock();
                                        }
                                    }
                                }];
}

+ (void)findUsersMatchingStartString:(NSString *)startString
                            success:(void(^)(NSString *string, NSArray *users))successBlock
                            failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [User query];
    [query whereKey:@"username" hasPrefix:startString];
    [query setLimit:10];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (error != nil) {
            OneLog(ONEAPIMANAGERLOG,@"Failure - findUserMatchingStartString - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            OneLog(ONEAPIMANAGERLOG,@"Success - findUserMatchingStartString - %lu users found",users.count);
            if (successBlock) {
                successBlock(startString, users);
            }
        }
    }];
}

+ (void)fetchCurrentUserAndExecuteSuccess:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock
{
    [[User currentUser] fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (!error) {
            OneLog(ONEAPIMANAGERLOG,@"Success - Fetch User");
            if (successBlock) {
                successBlock();
            }
        } else {
            OneLog(ONEAPIMANAGERLOG,@"Failure - Fetch User - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------
+ (void)createPaymentTransactionWithReceiver:(User *)receiver
                                     message:(NSString *)message
                                     success:(void(^)())successBlock
                                     failure:(void(^)(NSError *error))failureBlock
{
    NSDictionary *params = message ? @{ @"receiverId" : receiver.objectId, @"message" : message } : @{ @"receiverId" : receiver.objectId};
    [PFCloud callFunctionInBackground:@"createPaymentTransaction"
                       withParameters:params
                                block:^(Transaction *object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - createPaymentTransaction - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        // pin transaction
                                        [object pinInBackgroundWithName:kParseTransactionsName];
                                        if (successBlock) {
                                            successBlock();
                                        }
                                    }
                                }];
}

// Get transactions (either all after date, or 20)
+ (void)getTransactionsAroundDate:(NSDate *)date
                          isStart:(BOOL)isStartDate
                          success:(void(^)(NSArray *transactions))successBlock
                          failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *receiverQuery = [PFQuery queryWithClassName:NSStringFromClass([Transaction class])];
    [receiverQuery whereKey:@"sender" equalTo:[User currentUser]];
    PFQuery *senderQuery = [PFQuery queryWithClassName:NSStringFromClass([Transaction class])];
    [senderQuery whereKey:@"receiver" equalTo:[User currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[receiverQuery, senderQuery]];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query orderByDescending:@"createdAt"];
    if (isStartDate) {
        [query whereKey:@"createdAt" greaterThanOrEqualTo:date];
        [query setLimit:200]; // everything above from
    } else {
        [query whereKey:@"createdAt" lessThan:date];
        [query setLimit:20];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
        if (error != nil) {
            OneLog(ONEAPIMANAGERLOG,@"Failure - getTransactionsFromDate - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            OneLog(ONEAPIMANAGERLOG,@"Success - getTransactionsFromDate - %lu found",transactions.count);
            // pin transactions (lastest ONLY !)
            if (isStartDate) {
                [DatastoreManager saveLatestTransactionsRetrievalDate:[NSDate date]];
                [PFObject pinAllInBackground:transactions withName:kParseTransactionsName];
            }
            if (successBlock) {
                successBlock(transactions);
            }
        }
    }];
}

// --------------------------------------------
#pragma mark - Installation
// --------------------------------------------

+ (void)updateBadge:(NSInteger)count {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (!currentInstallation.objectId || currentInstallation.badge != count) {
        OneLog(ONEAPIMANAGERLOG,@"Update Badge");
        currentInstallation.badge = count;
        [currentInstallation saveEventually];
    }
}

@end
