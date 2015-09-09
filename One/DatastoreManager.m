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

#define LATEST_TRANSACTIONS_RETRIEVAL @"Lastest transaction retrieval date"
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

+ (NSDate *)getLatestTransactionsRetrievalDate {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs objectForKey:LATEST_TRANSACTIONS_RETRIEVAL] ? [prefs objectForKey:LATEST_TRANSACTIONS_RETRIEVAL] : [NSDate dateWithTimeIntervalSince1970:0];
}

+ (void)saveLatestTransactionsRetrievalDate:(NSDate *)date {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:date forKey:LATEST_TRANSACTIONS_RETRIEVAL];
    [prefs synchronize];
}
@end
