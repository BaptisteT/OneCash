//
//  UserTableViewCell.m
//  One
//
//  Created by Baptiste Truchot on 9/5/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "User.h"

#import "UserTableViewCell.h"

@interface UserTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedImageView;

@end

@implementation UserTableViewCell

- (void)setUser:(User *)user {
    _user = user;
    self.usernameLabel.text = user.caseUsername;
    [user setAvatarInImageView:self.userPicture];
    self.userPicture.layer.cornerRadius = self.userPicture.frame.size.height / 2;
    self.userPicture.clipsToBounds = YES;
    self.userPicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userPicture.layer.borderWidth = 0.5;
    
    self.certifiedImageView.hidden = ! user.twitterVerified;
}

@end
