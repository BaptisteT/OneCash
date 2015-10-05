//
//  UserTableViewCell.h
//  One
//
//  Created by Baptiste Truchot on 9/5/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserTVCProtocol;

@class User;

@interface UserTableViewCell : UITableViewCell

@property (strong, nonatomic) User *user;
@property (weak, nonatomic) id<UserTVCProtocol> delegate;

- (void)initWithUser:(User *)user showBalance:(BOOL)flag;

@end

@protocol UserTVCProtocol

- (void)displayTwitterOptionsForUser:(User *)user;

@end
