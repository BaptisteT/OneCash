//
//  SendCashViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BalanceViewController.h"
#import "CashView.h"
#import "CustomValueViewController.h"
#import "RecipientViewController.h"
#import "SettingsViewController.h"

@interface SendCashViewController : UIViewController <RecipientVCProtocol, CashViewDelegateProtocol, UIAlertViewDelegate, BalanceViewControllerProtocol, SettingsVCProtocol, CustomValueVCProtocol>

@property (nonatomic) BOOL navigateDirectlyToBalance;
@property (strong, nonatomic) User *receiver;


@end
