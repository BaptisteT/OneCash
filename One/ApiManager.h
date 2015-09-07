//
//  ApiManager.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

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

+ (void)updateCurrentUserInfo:(NSString *)email
                      success:(void(^)())successBlock
                      failure:(void(^)(NSError *error))failureBlock;

+ (void)createStripeCustomerWithToken:(NSString *)token
                        paymentMethod:(PaymentMethod)method
                              success:(void(^)())successBlock
                              failure:(void(^)(NSError *error))failureBlock;

+ (void)findUsersMatchingStartString:(NSString *)startString
                            success:(void(^)(NSString *string, NSArray *users))successBlock
                            failure:(void(^)(NSError *error))failureBlock;
@end
