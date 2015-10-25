//
//  BalanceViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "ManagedAccountViewController.h"
#import "AccountCardViewController.h"
#import "TransactionTableViewCell.h"

@protocol BalanceViewControllerProtocol;

@interface BalanceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ManagedAccountVCProtocol, AccountCardVCProtocol, UITextFieldDelegate, UIActionSheetDelegate, TransactionTVCProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) id<BalanceViewControllerProtocol> delegate;

@end

@protocol BalanceViewControllerProtocol

- (void)navigateToCardController;
- (void)navigateToShareUsername;

@end