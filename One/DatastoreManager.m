//
//  DatastoreManager.m
//  One
//
//  Created by Baptiste Truchot on 9/8/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "DatastoreManager.h"
#import "Transaction.h"
#import "User.h"

#import "ConstantUtils.h"
#import "OneLogger.h"

#define LAST_BALANCE_OPENING @"Last Balance opening"
#define HAS_LAUNCHED_ONCE @"Has Launched One %@"

#define RECENT_USERS_ARRAY @"Recent Users Array"
#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@implementation DatastoreManager

// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------

+ (void)getTransactionsLocallyAndExecuteSuccess:(void(^)(NSArray *transactions))successBlock
                                        failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [PFQuery queryWithClassName:[Transaction parseClassName]];
    [query fromLocalDatastore];
    [query fromPinWithName:kParseTransactionsName];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query includeKey:@"reaction"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
        if (!error) {
            OneLog(LOCALLOGENABLED,@"Datastore => %lu transactions  found",transactions.count);
            if (successBlock) {
                successBlock(transactions);
            }
        } else {
            // Log details of the failure
            OneLog(LOCALLOGENABLED,@"Error in transactions from local datastore: %@ %@", error, [error userInfo]);
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

+ (void)getNumberOfTransactionsSinceDate:(NSDate *)date
                                 success:(void(^)(NSInteger count))successBlock
                                 failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [PFQuery queryWithClassName:[Transaction parseClassName]];
    [query fromLocalDatastore];
    [query fromPinWithName:kParseTransactionsName];
    [query whereKey:@"createdAt" greaterThan:date];
    [query whereKey:@"sender" notEqualTo:[User currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
        if (!error) {
            if (successBlock) {
                successBlock(transactions.count);
            }
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

+ (NSDate *)getLastBalanceOpening {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs objectForKey:LAST_BALANCE_OPENING] ? [prefs objectForKey:LAST_BALANCE_OPENING] : [NSDate dateWithTimeIntervalSince1970:0];
}

+ (void)setLastBalanceOpeningDate:(NSDate *)date {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:date forKey:LAST_BALANCE_OPENING];
    [prefs synchronize];
}

+ (BOOL)hasLaunchedOnce:(id)sender {
    NSString *string = [NSString stringWithFormat:HAS_LAUNCHED_ONCE,sender];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:string])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:string];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
    return  YES;
}

// --------------------------------------------
#pragma mark - Recent & leader users
// --------------------------------------------
+ (void)getRecentUsersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                                failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [PFQuery queryWithClassName:[Transaction parseClassName]];
    [query fromLocalDatastore];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:20];
    [query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
        if (error != nil) {
            OneLog(LOCALLOGENABLED,@"Failure - getRecentUsersAndExecuteSuccess - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            OneLog(LOCALLOGENABLED,@"Success - getRecentUsersAndExecuteSuccess - %lu found",transactions.count);
            NSMutableOrderedSet *recentUsers = [NSMutableOrderedSet new];
            for (Transaction *transaction in transactions) {
                if (recentUsers.count >= kRecentUserCount) {
                    break;
                }
                if (transaction.sender != [User currentUser]) {
                    [recentUsers addObject:transaction.sender];
                }
                if (transaction.receiver) {
                    if (transaction.receiver != [User currentUser]) {
                        [recentUsers addObject:transaction.receiver];
                    }
                }
            }
            if (successBlock) {
                successBlock([recentUsers array]);
            }
        }
    }];
}

+ (void)getSuggestedUsersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                                failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [User query];
    [query fromLocalDatastore];
    [query fromPinWithName:kParseSuggestedUsersName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (error != nil) {
            OneLog(LOCALLOGENABLED,@"Failure - getSuggestedUsers - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            OneLog(LOCALLOGENABLED,@"Success - getSuggestedUsers - %lu found",users.count);
            if (successBlock) {
                successBlock(users);
            }
        }
    }];
}

+ (void)getLeadersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                            failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [User query];
    [query fromLocalDatastore];
    [query fromPinWithName:kParseLeaderUsersName];
    [query orderByDescending:@"balance"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (error != nil) {
            OneLog(LOCALLOGENABLED,@"Failure - getLeaders - %@",error.description);
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            OneLog(LOCALLOGENABLED,@"Success - getLeaders - %lu found",users.count);
            if (successBlock) {
                successBlock(users);
            }
        }
    }];
}



// --------------------------------------------
#pragma mark - Clean local data
// --------------------------------------------
+ (void)cleanLocalData {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [PFObject unpinAllObjectsInBackgroundWithName:kParseTransactionsName];
}
@end
