//
//  TransactionTableViewCell.h
//  One
//
//  Created by Baptiste Truchot on 9/7/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reaction;
@class Transaction;

@protocol TransactionTVCProtocol;

@interface TransactionTableViewCell : UITableViewCell

@property (weak, nonatomic) id<TransactionTVCProtocol> delegate;

- (void)initWithTransaction:(Transaction *)transaction;

@end

@protocol TransactionTVCProtocol

- (void)reactToTransaction:(Transaction *)transaction;
- (void)showReaction:(Reaction *)reaction image:(UIImage *)image initialFrame:(CGRect)frame;

@end

