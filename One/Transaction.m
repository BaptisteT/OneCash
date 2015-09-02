//
//  Transaction.m
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "Transaction.h"

@implementation OneTransaction

+ (void)load {
    [self registerSubclass];
}

+ (NSString * __nonnull)parseClassName
{
    return NSStringFromClass([self class]);
}

+ (OneTransaction *)createTransaction
{
    OneTransaction *transaction = [OneTransaction object];
    
    // Security = no write access
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:true];
    [acl setPublicWriteAccess:NO];
    transaction.ACL = acl;
    
    return transaction;
}

@end
