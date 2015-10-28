//
//  Transaction.m
//  One
//
//  Created by Baptiste Truchot on 9/2/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "Reaction.h"
#import "Transaction.h"
#import "User.h"

#import "DesignUtils.h"

@implementation Transaction

@dynamic sender;
@dynamic transactionType;
@dynamic receiver;
@dynamic transactionAmount;
@dynamic message;
@dynamic readStatus;
@dynamic receiverType;
@dynamic reaction;

@synthesize ongoingReaction;

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

- (void)getReactionImageAndExecuteSuccess:(void(^)(UIImage *image))successBlock
                                  failure:(void(^)())failureBlock
{
    if (!self.reaction || self.reaction.reactionType != kReactionImage) {
        if (failureBlock)
            failureBlock();
    } else {
        if (self.reaction.reactionImage) {
            successBlock(self.reaction.reactionImage);
        } else {
            [self.reaction.imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (self.reaction.readStatus) {
                            image = [DesignUtils blurAndRescaleImage:image];
                        }
                        self.reaction.reactionImage = image;
                        successBlock(image);
                    } else {
                        if (failureBlock) failureBlock();
                    }
                });
            }];
        }
    }
}

@end
