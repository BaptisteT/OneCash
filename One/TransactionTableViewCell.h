//
//  TransactionTableViewCell.h
//  One
//
//  Created by Baptiste Truchot on 9/7/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Transaction;

@interface TransactionTableViewCell : UITableViewCell

- (void)initWithTransaction:(Transaction *)transaction;

@end
