//
//  AccountCardViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountCardVCProtocol;

@interface AccountCardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) id<AccountCardVCProtocol> delegate;

@end

@protocol AccountCardVCProtocol <NSObject>

- (void)returnToBalanceController;

@end