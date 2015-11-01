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

+ (void)getNumberOfUnreadReceivedTransactionsAndExecuteSuccess:(void(^)(NSInteger count))successBlock
                                                       failure:(void(^)(NSError *error))failureBlock;

+ (void)getRecentUsersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                                failure:(void(^)(NSError *error))failureBlock;

+ (void)getSuggestedUsersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                                   failure:(void(^)(NSError *error))failureBlock;

+ (void)getLeadersAndExecuteSuccess:(void(^)(NSArray *users))successBlock
                            failure:(void(^)(NSError *error))failureBlock;

+ (void)getNumberOfUnreadReactionsAndExecuteSuccess:(void(^)(NSInteger count))successBlock
                                            failure:(void(^)(NSError *error))failureBlock;

+ (void)cleanLocalData;

+ (BOOL)hasLaunchedOnce:(id)sender;

@end
