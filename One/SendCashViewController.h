//
//  SendCashViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CashView.h"
#import "RecipientViewController.h"

@interface SendCashViewController : UIViewController <RecipientVCProtocol, CashViewDelegateProtocol>


@end
