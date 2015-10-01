//
//  UserTableViewCell.m
//  One
//
//  Created by Baptiste Truchot on 9/5/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "User.h"

#import "ColorUtils.h"
#import "UserTableViewCell.h"

@interface UserTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedImageView;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;

@end

@implementation UserTableViewCell

- (void)initWithUser:(User *)user showBalance:(BOOL)flag {
    _user = user;
    self.userStatus.text = user.userStatus;
    self.userStatus.hidden = !user.userStatus || user.userStatus.length == 0;
    self.usernameLabel.text = user.caseUsername;
    [user setAvatarInImageView:self.userPicture bigSize:NO saveLocally:NO];
    self.userPicture.layer.cornerRadius = self.userPicture.frame.size.height / 2;
    self.userPicture.clipsToBounds = YES;
    self.userPicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userPicture.layer.borderWidth = 0.5;
    self.certifiedImageView.hidden = ! user.twitterVerified;
    
    self.balanceLabel.backgroundColor = [ColorUtils mainGreen];
    self.balanceLabel.layer.cornerRadius = self.balanceLabel.frame.size.height / 2;
    self.balanceLabel.text = [NSString stringWithFormat:@"$%lu",(long)user.balance];
    self.balanceLabel.hidden = !flag;
    self.balanceLabel.clipsToBounds = YES;
}

- (IBAction)twitterButtonClicked:(id)sender {
    NSString *username = self.user.username;
    if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"twitter://user?screen_name=",username]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://twitter.com/",username]]];
    }
}

@end
