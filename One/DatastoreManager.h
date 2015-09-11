//
//  DatastoreManager.h
//  One
//
//  Created by Baptiste Truchot on 9/8/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatastoreManager : NSObject

+ (void)getTransactionsLocallyAndExecuteSuccess:(void(^)(NSArray *transactions))successBlock
                                        failure:(void(^)(NSError *error))failureBlock;

+ (void)getNumberOfTransactionsSinceDate:(NSDate *)date
                                 success:(void(^)(NSInteger count))successBlock
                                 failure:(void(^)(NSError *error))failureBlock;

+ (NSDate *)getLatestTransactionsRetrievalDate;

+ (void)saveLatestTransactionsRetrievalDate:(NSDate *)date;

+ (void)getRecentUsersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                                failure:(void(^)(NSError *error))failureBlock;

+ (NSDate *)getLastBalanceOpening;

+ (void)setLastBalanceOpeningDate:(NSDate *)date;
@end
