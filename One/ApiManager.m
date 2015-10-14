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
                [TrackingUtils trackEvent:EVENT_TWITTER_CONNECT properties:@{@"success": @NO, @"failure": @"login"}];
                OneLog(ONEAPIMANAGERLOG,@"Error - Twitter login - %@",error.description);
                if (failureBlock) {
                    failureBlock(error);
                }
            } else {
                OneLog(ONEAPIMANAGERLOG,@"Success - Twitter login - isNew: %d",user.isNew);
                
                // auth data
                PF_Twitter *twitter = [PFTwitterUtils twitter];
                NSString *userId = twitter.userId;
                NSString *screenName = twitter.screenName;
                NSString *authToken = twitter.authToken;
                NSString *authTokenSecret = twitter.authTokenSecret;
                
                void(^afterLoginBlock)() = ^() {
                    [TrackingUtils identifyUser:[User currentUser]];
                    
                    // Get twitter info
                    [ApiManager getOtherTwitterInfoAndExecuteSuccess:^{
                        [TrackingUtils trackEvent:EVENT_TWITTER_CONNECT properties:@{@"success": @YES}];
                        if (successBlock){
                            successBlock();
                        }
                    } failure:^(NSError *error) {
                        [TrackingUtils trackEvent:EVENT_TWITTER_CONNECT properties:@{@"success": @NO, @"failure": @"otherInfo"}];
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                };
                
                // login case
                if ([[User currentUser].username isEqualToString:[screenName lowercaseString]]) {
                    afterLoginBlock();
                    
                // signup case
                } else {
                    [PFCloud callFunctionInBackground:@"mergeRealAndExternalUser"
                                       withParameters:nil
                                                block:^(id object, NSError *error) {
                                                    if (error != nil) {
                                                        OneLog(ONEAPIMANAGERLOG,@"Failure - postOnTwitter - %@",error.description);
                                                        if (failureBlock) {
                                                            failureBlock(error);
                                                        }
                                                    } else {
                                                        // external case
                                                        if ([object valueForKey:@"re-log"]) {
                                                            [PFTwitterUtils logInWithTwitterId:userId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                                                [User currentUser].isNewOverride = YES;
                                                                afterLoginBlock();
                                                            }];
                                                        } else {
                                                        // No external
                                                            afterLoginBlock();
                                                        }
                                                    }
                                                }];
                }
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
    
    if (twitterUserID && twitterUserID.length > 0 && ![user.twitterId isEqualToString:twitterUserID]) {
        user.twitterId = twitterUserID;
    }
    if (twitterScreenName && twitterScreenName.length > 0  && ![user.caseUsername isEqualToString:twitterScreenName]) {
        user.caseUsername = twitterScreenName;
        [user setUsername:[user.caseUsername lowercaseString]];
    }
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json?skip_status=true&include_email=true"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if ( connectionError == nil) {
            NSError * error = nil;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            OneLog(ONEAPIMANAGERLOG, @"Success - twitter info - %@",result);
            // Update user info
            [user updateUserWithTwitterInfo:result];
            
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

+ (void)getTwitterUsersFromString:(NSString *)string
                          success:(void(^)(NSArray *users, NSString *string))successBlock
                          failure:(void(^)(NSError *error))failureBlock
{
    NSURL *verify = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/search.json?q=%@&count=10",string]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if ( connectionError == nil) {
            NSError * error = nil;
            NSArray * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (successBlock) {
                successBlock([User createUsersFromTwitterResultArray:result], string);
            }
        } else {
            OneLog(ONEAPIMANAGERLOG, @"Failure - twitter users - %@",connectionError);
            if (failureBlock) {
                failureBlock(connectionError);
            }
        }
    }];
}

+ (void)postOnTwitter:(NSString *)wording
              success:(void(^)())successBlock
              failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"postOnTwitter"
                       withParameters:@{ @"postWording" : wording }
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - postOnTwitter - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock((NSDictionary *)object);
                                        }
                                    }
                                }];
}

+ (void)followOnTwitter:(NSString *)followedScreename
                success:(void(^)())successBlock
                failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"followOnTwitter"
                       withParameters:@{ @"followedScreename" : followedScreename }
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - followOnTwitter - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock((NSDictionary *)object);
                                        }
                                    }
                                }];
}

// --------------------------------------------
#pragma mark - User
// --------------------------------------------
+ (void)saveCurrentUserAndExecuteSuccess:(void(^)())successBlock
                                 failure:(void(^)(NSError *error))failureBlock
{
    User *user = [User currentUser]; // there should be unsaved changed (username / picture URL..)
    if (user.isDirty) {
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                OneLog(ONEAPIMANAGERLOG,@"Success - Update User");
                if (successBlock) {
                    successBlock();
                }
                
                // Mixpanel
                NSMutableDictionary *peopleProperty = [NSMutableDictionary new];
                [peopleProperty setObject:[NSNumber numberWithInteger:user.balance] forKey:PEOPLE_BALANCE];
                [peopleProperty setObject:[NSNumber numberWithInteger:user.paymentMethod] forKey:PEOPLE_PAYMENT_METHOD];
                if (user.email) [peopleProperty setObject:user.email forKey:PEOPLE_EMAIL];
                if (user.firstName) [peopleProperty setObject:user.firstName forKey:PEOPLE_FIRST_NAME];
                if (user.lastName) [peopleProperty setObject:user.lastName forKey:PEOPLE_LAST_NAME];
                if (user.caseUsername) [peopleProperty setObject:user.caseUsername forKey:PEOPLE_USERNAME];
                [TrackingUtils setPeopleProperties:peopleProperty];
            } else {
                OneLog(ONEAPIMANAGERLOG,@"Failure - Update User - %@",error.description);
                if (failureBlock) {
                    failureBlock(error);
                }
            }
        }];
    } else {
        if (successBlock ) {
            successBlock();
        }
    }
}

+ (void)resendEmailVerificationAndExecuteSuccess:(void(^)())successBlock
                                         failure:(void(^)(NSError *error))failureBlock
{
    User *user = [User currentUser];
    NSString *email = [User currentUser].email;
    user.email = @"";
    [ApiManager saveCurrentUserAndExecuteSuccess:^{
        user.email = email;
        [ApiManager saveCurrentUserAndExecuteSuccess:^{
            if (successBlock) {
                successBlock();
            }
        } failure:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
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
                                    [TrackingUtils trackEvent:EVENT_STRIPE_CREATE_CUSTOMER properties:@{@"success" : [NSNumber numberWithBool:(error == nil)]}];
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

// Get customer cards
+ (void)getCustomerCardsAndExecuteSuccess:(void(^)(NSArray *cards))successBlock
                                  failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"retrieveCards"
                       withParameters:nil
                                block:^(NSArray *cards, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - retrieveCards - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock(cards);
                                        }
                                    }
                                }];
}

+ (void)findUsersMatchingStartString:(NSString *)startString
                            success:(void(^)(NSString *string, NSArray *users))successBlock
                            failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"findUsersWithSubstring"
                       withParameters:@{@"startString": [startString lowercaseString]}
                                block:^(NSArray *objects, NSError *error) {
                                    if (error == nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Success - findUserMatchingStartString");
                                        if (successBlock) {
                                            successBlock(startString,objects);
                                        }
                                    } else {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - findUserMatchingStartString - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                        
                                    }
                                }];
}

+ (void)fetchUser:(User *)user
          success:(void(^)())successBlock
          failure:(void(^)(NSError *error))failureBlock
{
    [user fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (!error) {
            OneLog(ONEAPIMANAGERLOG,@"Success - Fetch User");
            // Mixpanel
            if ([user.objectId isEqualToString:[User currentUser].objectId]) {
                NSMutableDictionary *peopleProperty = [NSMutableDictionary new];
                [peopleProperty setObject:[NSNumber numberWithInteger:((User *)user).paymentMethod] forKey:PEOPLE_PAYMENT_METHOD];
                [TrackingUtils setPeopleProperties:peopleProperty];
            }
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

+ (void)findUserWithUsername:(NSString *)username
                     success:(void(^)(User *user))successBlock
                     failure:(void(^)(NSError *error))failureBlock
{
    NSString *lowercaseUsername = [username lowercaseString];
    [PFCloud callFunctionInBackground:@"findUserWithUsername"
                       withParameters:@{@"username": lowercaseUsername}
                                block:^(NSArray *objects, NSError *error) {
                                    if (error == nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Success - findUserWithUsername");
                                        if (successBlock) {
                                            successBlock(objects.firstObject);
                                        }
                                    } else {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - findUserWithUsername - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                        
                                    }
                                }];
}

+ (void)createExternalUser:(User *)user
                   success:(void(^)(User *user))successBlock
                   failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"createExternalUser"
                       withParameters:@{@"username": user.username, @"caseUsername": user.caseUsername, @"pictureURL": user.pictureURL, @"twitterId": user.twitterId}
                                block:^(User *user, NSError *error) {
                                    if (error == nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Success - createExternalUser");
                                        if (successBlock) {
                                            successBlock(user);
                                        }
                                    } else {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - createExternalUser - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                        
                                    }
                                }];
}



// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------
// Create payment transactions
+ (void)createPaymentTransactionWithTransaction:(Transaction *)transaction
                                  applePaytoken:(NSString *)token
                                        success:(void(^)(Transaction *returnTransaction))successBlock
                                        failure:(void(^)(NSError *error))failureBlock
{
    // Create transactions => block
    void (^createTransactionsBlock)(Transaction *) = ^(Transaction *paiement) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"receiverId"] = paiement.receiver.objectId;
        if (paiement.message)
            params[@"message"] = paiement.message;
        params[@"transactionAmount"] = [NSNumber numberWithInteger:paiement.transactionAmount];
        if (token)
            params[@"applePayToken"] = token;
        
        NSString *method = paiement.transactionAmount > [User currentUser].balance ? @"balance" : [User currentUser].paymentMethod == kPaymentMethodApplePay ? @"Apple Pay" : @"Manual Card";
        
        [PFCloud callFunctionInBackground:@"createPaymentTransaction"
                           withParameters:params
                                    block:^(NSArray *objects, NSError *error) {
                                        if (error != nil) {
                                            OneLog(ONEAPIMANAGERLOG,@"Failure - createPaymentTransaction - %@",error.description);
                                            if (failureBlock) {
                                                failureBlock(error);
                                            }
                                            [TrackingUtils trackEvent:EVENT_CREATE_PAYMENT_FAIL properties:@{@"amount": [NSNumber numberWithInteger:paiement.transactionAmount], @"message": [NSNumber numberWithBool:(paiement.message !=nil)], @"method": method, @"error":@"create_payment_error", @"externalReceiver": [NSNumber numberWithBool:paiement.receiver.isExternal]}];
                                        } else {
                                            // pin transaction
                                            Transaction *tr = (Transaction *)(objects[0]);
                                            [tr pinInBackgroundWithName:kParseTransactionsName];
                                            if (successBlock) {
                                                successBlock(tr);
                                            }
                                            
                                            // TRACKING
                                            [TrackingUtils trackEvent:EVENT_CREATE_PAYMENT properties:@{@"amount": [NSNumber numberWithInteger:paiement.transactionAmount], @"message": [NSNumber numberWithBool:(paiement.message !=nil)], @"method": method, @"externalReceiver": [NSNumber numberWithBool:paiement.receiver.isExternal]}];
                                            [TrackingUtils incrementPeopleProperty:PEOPLE_SENDING_TOTAL byValue:(int)paiement.transactionAmount];
                                        }
                                    }];
    };
    
    User *receiver = transaction.receiver;
    // Normal case : paiement to other user
    if (receiver.objectId) {
        createTransactionsBlock(transaction);
        
    // External case
    } else {
        if (!receiver.username)
            return;
        [ApiManager findUserWithUsername:transaction.receiver.username
                                 success:^(User *user) {
                                     if (user) {
                                         transaction.receiver = user;
                                         createTransactionsBlock(transaction);
                                     } else {
                                         [ApiManager createExternalUser:transaction.receiver
                                                                success:^(User *user) {
                                                                    transaction.receiver = user;
                                                                    createTransactionsBlock(transaction);
                                                                } failure:^(NSError *error) {
                                                                    if (failureBlock) {
                                                                        failureBlock(error);
                                                                    }
                                                                }];
                                     }
                                 } failure:^(NSError *error) {
                                     if (failureBlock) {
                                         failureBlock(error);
                                     }
                                 }];
    }
}

// Get transactions (either all after date, or 20)
+ (void)getTransactionsBeforeDate:(NSDate *)date
                          success:(void(^)(NSArray *transactions))successBlock
                          failure:(void(^)(NSError *error))failureBlock
{
    User *currentUser = [User currentUser];
    if (!currentUser) {
        if (failureBlock) {
            failureBlock(nil);
        }
        return;
    }
    PFQuery *receiverQuery = [PFQuery queryWithClassName:NSStringFromClass([Transaction class])];
    [receiverQuery whereKey:@"sender" equalTo:currentUser];
    PFQuery *senderQuery = [PFQuery queryWithClassName:NSStringFromClass([Transaction class])];
    [senderQuery whereKey:@"receiver" equalTo:currentUser];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[receiverQuery, senderQuery]];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:20];
    if (date) {
        [query whereKey:@"createdAt" lessThan:date];
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
            if (!date) {
                [PFObject unpinAllObjectsInBackgroundWithName:kParseTransactionsName block:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                        [PFObject pinAllInBackground:transactions withName:kParseTransactionsName block:^(BOOL result, NSError *error) {
                            if (result) {
                                if (successBlock) {
                                    successBlock(transactions);
                                }
                            } else {
                                OneLog(ONEAPIMANAGERLOG,@"Failure - pin transactions - %@",error.description);
                                if (failureBlock) {
                                    failureBlock(error);
                                }
                            }
                            for (Transaction *transaction in transactions) {
                                [transaction.sender pinInBackgroundWithName:kParseUsersName];
                                if (transaction.receiver) {
                                    [transaction.receiver pinInBackgroundWithName:kParseUsersName];
                                }
                            }
                        }];
                    } else {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }
                }];
            } else {
                if (successBlock) {
                    successBlock(transactions);
                }
            }
        }
    }];
}


// Cashout
+ (void)createCashoutAndExecuteSuccess:(void(^)())successBlock
                               failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"createCashoutTransaction"
                       withParameters:nil
                                block:^(NSArray *objects, NSError *error) {
                                    if (error != nil) {
                                        [TrackingUtils trackEvent:EVENT_CREATE_CASHOUT_FAIL properties:nil];
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - createCashoutTransaction - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        Transaction *transaction = (Transaction *)(objects[0]);
                                        [TrackingUtils trackEvent:EVENT_CREATE_CASHOUT properties:@{@"amount": [NSNumber numberWithInteger:transaction.transactionAmount]}];
                                        [TrackingUtils incrementPeopleProperty:PEOPLE_CASHOUT_TOTAL byValue:(int)transaction.transactionAmount];
                                        // pin transaction
                                        [transaction pinInBackgroundWithName:kParseTransactionsName];
                                        if (successBlock) {
                                            successBlock();
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

// --------------------------------------------
#pragma mark - ManageAccount
// --------------------------------------------
// Create managed account
+ (void)createManageAccountWithParameters:(NSDictionary *)parameters
                                  success:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"createManagedAccount"
                       withParameters:parameters
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - createManagedAccount - %@",error.description);
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

// Get managed account
+ (void)getManageAccountAndExecuteSuccess:(void(^)(NSDictionary *stripeAccount))successBlock
                                  failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"getManagedAccount"
                       withParameters:nil
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - getManagedAccount - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock(object);
                                        }
                                    }
                                }];
}

// Add card managed account
+ (void)addCardToManadedAccount:(NSString *)token
                        success:(void(^)())successBlock
                        failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"addCardToManagedAccount"
                       withParameters:@{@"stripeToken":token}
                                block:^(id object, NSError *error) {
                                    [TrackingUtils trackEvent:EVENT_MANAGED_ACCOUNT_ADD_CARD properties:@{@"success" : [NSNumber numberWithBool:(error == nil)]}];
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - addCardToManadedAccount - %@",error.description);
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

// Set card as default to account
+ (void)setCardAsDefaultInManagedAccount:(NSString *)cardId
                                 success:(void(^)())successBlock
                                 failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"setCardAsDefaultInManagedAccount"
                       withParameters:@{@"cardId":cardId}
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - setCardAsDefaultInManagedAccount - %@",error.description);
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

// --------------------------------------------
#pragma mark - Recipients
// --------------------------------------------
// Leaders
+ (void)getLeadersAndExecuteSuccess:(void(^)(NSArray *results))successBlock
                            failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"retrieveLeaders"
                       withParameters:nil
                                block:^(NSArray *results, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - retrieveLeaders - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock(results);
                                        }
                                        // pin
                                        [PFObject unpinAllObjectsInBackgroundWithName:kParseLeaderUsersName
                                                                                block:^(BOOL succeeded, NSError * _Nullable error) {
                                                                                    [PFObject pinAllInBackground:results withName:kParseLeaderUsersName];
                                                                                }];
                                    }
                                }];
}

// Suggested
+ (void)getSuggestedUsersAndExecuteSuccess:(void(^)(NSArray *results))successBlock
                            failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"retrieveSuggestedUsers"
                       withParameters:nil
                                block:^(NSArray *results, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - getSuggestedUsers - %@",error.description);
                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    } else {
                                        if (successBlock) {
                                            successBlock(results);
                                        }
                                        // pin
                                        [PFObject unpinAllObjectsInBackgroundWithName:kParseSuggestedUsersName
                                                                                block:^(BOOL succeeded, NSError * _Nullable error) {
                                                                                    [PFObject pinAllInBackground:results withName:kParseSuggestedUsersName];
                                                                                }];
                                    }
                                }];
}


// --------------------------------------------
#pragma mark - Misc
// --------------------------------------------
// Email Alert
+ (void)alertByEmailWithParams:(NSDictionary *)params
                       success:(void(^)())successBlock
                       failure:(void(^)(NSError *error))failureBlock
{
    [PFCloud callFunctionInBackground:@"alertFromApp"
                       withParameters:params
                                block:^(id object, NSError *error) {
                                    if (error != nil) {
                                        OneLog(ONEAPIMANAGERLOG,@"Failure - alertFromApp - %@",error.description);
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


@end
