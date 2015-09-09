//
//  Transaction.m
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

@dynamic sender;
@dynamic transactionType;
@dynamic receiver;
@dynamic transactionAmount;
@dynamic message;

+ (void)load {
    [self registerSubclass];
}

+ (NSString * __nonnull)parseClassName
{
    return NSStringFromClass([self class]);
}



@end
