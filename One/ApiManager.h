//
//  ApiManager.h
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ApiManager : NSObject

+ (void)checkAppVersionAndExecuteSucess:(void(^)(NSDictionary *))successBlock;

+ (void)logInWithTwitterAndExecuteSuccess:(void(^)())successBlock
                                  failure:(void(^)(NSError *error))failureBlock;

@end
