//
//  ApiManager.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"
@class Transaction;

@interface ApiManager : NSObject

// --------------------------------------------
#pragma mark - Api
// --------------------------------------------

+ (void)checkAppVersionAndExecuteSucess:(void(^)(NSDictionary *))successBlock;

// --------------------------------------------
#pragma mark - Log in
// --------------------------------------------

+ (void)logInWithTwitterAndExecuteSuccess:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock;

// --------------------------------------------
#pragma mark - User
// --------------------------------------------

+ (void)saveCurrentUserAndExecuteSuccess:(void(^)())successBlock
                                 failure:(void(^)(NSError *error))failureBlock;

+ (void)createStripeCustomerWithToken:(NSString *)token
                        paymentMethod:(PaymentMethod)method
                              success:(void(^)())successBlock
                              failure:(void(^)(NSError *error))failureBlock;

+ (void)findUsersMatchingStartString:(NSString *)startString
                            success:(void(^)(NSString *string, NSArray *users))successBlock
                            failure:(void(^)(NSError *error))failureBlock;

+ (void)fetchCurrentUserAndExecuteSuccess:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock;

+ (void)resendEmailVerification;

// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------
+ (void)createPaymentTransactionWithTransaction:(Transaction *)transaction
                                        success:(void(^)())successBlock
                                        failure:(void(^)(NSError *error))failureBlock;

+ (void)getTransactionsAroundDate:(NSDate *)date
                          isStart:(BOOL)isStartDate
                          success:(void(^)(NSArray *transactions))successBlock
                          failure:(void(^)(NSError *error))failureBlock;

// Cashout
+ (void)createCashoutAndExecuteSuccess:(void(^)())successBlock
                               failure:(void(^)(NSError *error))failureBlock;

// --------------------------------------------
#pragma mark - Installation
// --------------------------------------------

+ (void)updateBadge:(NSInteger)count;

@end
