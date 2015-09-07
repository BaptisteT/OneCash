//
//  CashView.h
//  One
//
//  Created by Baptiste Truchot on 9/6/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CashViewDelegateProtocol;

@interface CashView : UIView

@property (weak, nonatomic) id<CashViewDelegateProtocol> delegate;

@end

@protocol CashViewDelegateProtocol

- (void)createTransactionWithMessage:(NSString *)message;

@end
