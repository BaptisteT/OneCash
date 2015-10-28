//
//  Transaction.h
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/parse.h>

@class Reaction;
@class User;

@interface Transaction : PFObject <PFSubclassing>

typedef NS_ENUM(NSInteger,TransactionType) {
    kTransactionNone = 0,
    kTransactionPayment = 1,
    kTransactionCashout = 2
};

typedef NS_ENUM(NSInteger,ReceiverType) {
    kReceiverNormal = 0,
    kReceiverExternal = 1, // sent to a non user
    kReceiverAutoRefund = 2, // refund transactions
    kReceiverRefunded = 3 // sent to a non user, but refuned 7 days after
};

@property (strong, nonatomic) User *sender;
@property (nonatomic) TransactionType transactionType;
@property (nonatomic) NSInteger transactionAmount; // in $, 1 if kTransactionPayment
@property (strong, nonatomic) User *receiver; // if kTransactionPayment
@property (strong, nonatomic) NSString *message;
@property (nonatomic) BOOL readStatus;
@property (nonatomic) ReceiverType receiverType;
@property (strong, nonatomic) Reaction *reaction;


// local
@property (nonatomic) BOOL ongoingReaction;

+ (Transaction *)transactionWithReceiver:(User *)receiver
                       transactionAmount:(NSInteger)amount
                                    type:(TransactionType)type
                                 message:(NSString *)message;

- (BOOL)containsMessage;

- (void)getReactionImageAndExecuteSuccess:(void(^)(UIImage *image))successBlock
                                  failure:(void(^)())failureBlock;

@end
