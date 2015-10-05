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
    
    if(flag) {
        NSString *balance = [NSString stringWithFormat:@"$%@",[self abbreviateNumber:(int)user.balance]];
        NSString *string = [NSString stringWithFormat:@"%@ %@",balance, user.caseUsername];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
        [text addAttribute:NSForegroundColorAttributeName
                     value:[ColorUtils mainGreen]
                     range:[string rangeOfString:balance]];
        [self.usernameLabel setAttributedText: text];
    } else {
        self.usernameLabel.text = user.caseUsername;
    }
    [user setAvatarInImageView:self.userPicture bigSize:NO saveLocally:NO];
    self.userPicture.layer.cornerRadius = self.userPicture.frame.size.height / 2;
    self.userPicture.clipsToBounds = YES;
    self.userPicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userPicture.layer.borderWidth = 0.5;
    self.certifiedImageView.hidden = ! user.twitterVerified;
    
    self.balanceLabel.backgroundColor = [ColorUtils mainGreen];
    self.balanceLabel.layer.cornerRadius = self.balanceLabel.frame.size.height / 2;
    self.balanceLabel.text = [NSString stringWithFormat:@"$%@",[self abbreviateNumber:(int)user.balance]];
    self.balanceLabel.hidden = YES;
    self.balanceLabel.clipsToBounds = YES;
}

- (IBAction)twitterButtonClicked:(id)sender {
    if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"twitter://user?screen_name=",self.user.username]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://twitter.com/",self.user.username]]];
    }
}



- (NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
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

- (NSString *)floatToString:(float) val {
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
