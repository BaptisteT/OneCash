//
//  RecipientViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserTableViewCell.h"

@protocol RecipientVCProtocol;
@class User;

@interface RecipientViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UserTVCProtocol, UIActionSheetDelegate>

@property (weak, nonatomic) id <RecipientVCProtocol> delegate;

@end

@protocol RecipientVCProtocol

- (void)setSelectedUser:(User *)user;

@end