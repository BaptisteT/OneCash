//
//  BalanceViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BalanceViewControllerProtocol;

@interface BalanceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<BalanceViewControllerProtocol> delegate;

@end

@protocol BalanceViewControllerProtocol

- (void)navigateToCardController;

@end