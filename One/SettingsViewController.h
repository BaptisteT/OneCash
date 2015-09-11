//
//  SettingsViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SwitchTableViewCell.h"

@protocol SettingsVCProtocol;

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SwitchTVCProtocol>

@property (weak, nonatomic) id<SettingsVCProtocol> delegate;

@end

@protocol SettingsVCProtocol

- (void)navigateToCardController;
- (void)logoutUser;

@end