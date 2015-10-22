//
//  UsernameCardView.m
//  One
//
//  Created by Clement Raffenoux on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "UsernameCardView.h"

#import "User.h"
#import "ColorUtils.h"
#import "DesignUtils.h"
#import <UIImage+BlurredFrame.h>


@interface UsernameCardView ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *dollarLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation UsernameCardView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //User
    self.currentUser = [User currentUser];
    
    //UI
    self.backgroundColor = [ColorUtils mainGreen];
    [DesignUtils addShadow:self];
    self.dollarLabel.backgroundColor = [ColorUtils mainGreen];
    self.bottomView.backgroundColor = [ColorUtils mainGreen];
    
    //Avatar
    [self.currentUser setAvatarInImageView:self.avatarImageView bigSize:YES saveLocally:YES];
    
    //Username
    self.usernameLabel.text = [self.currentUser.caseUsername uppercaseString];

    //Title
    NSString *string = NSLocalizedString(@"share_card_title", nil);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange boldRange = [string rangeOfString:@"ONECASH"];
    UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Bold" size:self.titleLabel.font.pointSize];
    [attrString addAttribute: NSFontAttributeName value:boldFont range:boldRange];
    self.titleLabel.attributedText = attrString;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIfNeeded];
    self.dollarLabel.layer.cornerRadius = self.dollarLabel.frame.size.width / 2 ;
    self.dollarLabel.clipsToBounds = YES;
}

- (UIImage *)captureView {
    CGRect rect = self.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
