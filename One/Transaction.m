//
//  Transaction.m
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "Transaction.h"
#import "User.h"

@implementation Transaction

@dynamic sender;
@dynamic transactionType;
@dynamic receiver;
@dynamic transactionAmount;
@dynamic message;
@dynamic readStatus;
@dynamic receiverType;


+ (void)load {
    [self registerSubclass];
}

+ (NSString * __nonnull)parseClassName
{
    return NSStringFromClass([self class]);
}

+ (Transaction *)transactionWithReceiver:(User *)receiver
                       transactionAmount:(NSInteger)amount
                                    type:(TransactionType)type
                                 message:(NSString *)message
{
    Transaction *transaction = [Transaction object];
    transaction.sender = [User currentUser];
    transaction.receiver = receiver;
    transaction.transactionAmount = amount;
    transaction.transactionType = type;
    transaction.message = message;
    transaction.readStatus = NO;
    return transaction;
}

- (BOOL)containsMessage {
    return self.message && self.message.length > 0;
}

@end
