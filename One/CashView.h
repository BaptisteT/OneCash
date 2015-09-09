//
//  CashView.h
//  One
//
//  Created by Baptiste Truchot on 9/6/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <POP/POP.h>
#import <UIKit/UIKit.h>

@protocol CashViewDelegateProtocol;

@interface CashView : UIView

@property (weak, nonatomic) id<CashViewDelegateProtocol> delegate;
@property (strong, nonatomic) NSString *message;

- (void)moveViewToCenterAndExecute:(void(^)(POPAnimation *anim,BOOL completed))completionBlock;

@end

@protocol CashViewDelegateProtocol

- (void)createTransactionWithCashView:(CashView *)cashView;
- (void)adaptUIToCashViewState:(BOOL)isMoving;
@end
