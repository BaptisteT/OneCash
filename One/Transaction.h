//
//  Transaction.h
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/parse.h>

@class User;

@interface Transaction : PFObject <PFSubclassing>

typedef NS_ENUM(NSInteger,TransactionType) {
    kTransactionNone = 0,
    kTransactionPayment = 1,
    kTransactionCashout = 2
};

@property (nonatomic) User *sender;
@property (nonatomic) TransactionType transactionType;
@property (nonatomic) NSInteger transactionAmount; // in $, 1 if kTransactionPayment
@property (nonatomic) User *receiver; // if kTransactionPayment
@property (nonatomic) NSString *message;
@property (nonatomic) BOOL readStatus;


+ (Transaction *)transactionWithReceiver:(User *)receiver
                       transactionAmount:(NSInteger)amount
                                    type:(TransactionType)type
                                 message:(NSString *)message;

- (BOOL)containsMessage;

@end
