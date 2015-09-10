//
//  CashView.h
//  One
//
//  Created by Baptiste Truchot on 9/6/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
@import Foundation;
#import <POP/POP.h>
#import <UIKit/UIKit.h>

#import "PaddingTextField.h"

@protocol CashViewDelegateProtocol;

@interface CashView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) id<CashViewDelegateProtocol> delegate;
@property (weak, nonatomic) IBOutlet PaddingTextField *messageTextField;
@property (nonatomic) BOOL isEditingMessage;

- (void)initWithFrame:(CGRect)frame andDelegate:(id<CashViewDelegateProtocol>)delegate ;
- (void)moveViewToCenterAndExecute:(void(^)(POPAnimation *anim,BOOL completed))completionBlock;

@end

@protocol CashViewDelegateProtocol

- (void)createTransactionWithCashView:(CashView *)cashView;
- (void)adaptUIToCashViewState:(BOOL)isMoving;
@end
