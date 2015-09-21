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

#define LAST_TRANSACTIONS_RETRIEVAL @"Latest transactions last retrieval date"
#define LAST_BALANCE_OPENING @"Last Balance opening"
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

+ (NSDate *)getLatestTransactionsRetrievalDate {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs objectForKey:LAST_TRANSACTIONS_RETRIEVAL] ? [prefs objectForKey:LAST_TRANSACTIONS_RETRIEVAL] : [NSDate dateWithTimeIntervalSince1970:0];
}

+ (void)saveLatestTransactionsRetrievalDate:(NSDate *)date {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:date forKey:LAST_TRANSACTIONS_RETRIEVAL];
    [prefs synchronize];
}

+ (NSDate *)getLastBalanceOpening {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs objectForKey:LAST_BALANCE_OPENING] ? [prefs objectForKey:LAST_BALANCE_OPENING] : [NSDate date];
}

+ (void)setLastBalanceOpeningDate:(NSDate *)date {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:date forKey:LAST_BALANCE_OPENING];
    [prefs synchronize];
}

// --------------------------------------------
#pragma mark - load recent users
// --------------------------------------------
+ (void)getRecentUsersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                                failure:(void(^)(NSError *error))failureBlock
{
    PFQuery *query = [User query];
    [query fromLocalDatastore];
    [query setLimit:10];
    [query whereKey:@"objectId" notEqualTo:[User currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
        if (!error) {
            OneLog(LOCALLOGENABLED,@"Datastore => %lu users  found",transactions.count);
            if (successBlock) {
                successBlock(transactions);
            }
        } else {
            // Log details of the failure
            OneLog(LOCALLOGENABLED,@"Error in users from local datastore: %@ %@", error, [error userInfo]);
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}


@end
