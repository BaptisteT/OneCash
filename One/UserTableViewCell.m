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

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedImageView;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (strong, nonatomic) IBOutlet UIButton *userPictureButton;

@end

@implementation UserTableViewCell

- (void)initWithUser:(User *)user showBalance:(BOOL)flag {
    _user = user;
    self.userStatus.text = user.userStatus;
    self.userStatus.hidden = !user.userStatus || user.userStatus.length == 0;
    self.usernameLabel.text = user.caseUsername;
    [user setAvatarInButton:self.userPictureButton bigSize:NO];
    self.userPictureButton.layer.cornerRadius = self.userPictureButton.frame.size.height/2;
    self.userPictureButton.clipsToBounds = YES;
    self.userPictureButton.layer.borderColor = [ColorUtils lightBlack].CGColor;
    self.userPictureButton.layer.borderWidth = 0.5;
    self.certifiedImageView.hidden = ! user.twitterVerified;
    
    self.balanceLabel.backgroundColor = [ColorUtils mainGreen];
    self.balanceLabel.layer.cornerRadius = self.balanceLabel.frame.size.height / 2;
    self.balanceLabel.text = [NSString stringWithFormat:@"$%@",[self abbreviateNumber:(long)user.balance]];
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

-(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = abbrev.count - 1; i >= 0; i--) {
            
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

@end
