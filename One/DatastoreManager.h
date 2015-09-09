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


+ (NSDate *)getLatestTransactionsRetrievalDate;

+ (void)saveLatestTransactionsRetrievalDate:(NSDate *)date;
@end