//
//  UserTableViewCell.h
//  One
//
//  Created by Baptiste Truchot on 9/5/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>


@class User;

@interface UserTableViewCell : UITableViewCell

@property (strong, nonatomic) User *user;

- (void)initWithUser:(User *)user;

@end

