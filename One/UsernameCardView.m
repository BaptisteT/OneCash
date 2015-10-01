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


@interface UsernameCardView ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *dollarLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) User *currentUser;

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
    self.avatarImageView.layer.borderColor = [ColorUtils darkGreen].CGColor;
    self.avatarImageView.layer.borderWidth = 12;
    self.dollarLabel.backgroundColor = [ColorUtils darkGreen];
    
    //Avatar
    [self.currentUser setAvatarInImageView:self.avatarImageView bigSize:YES saveLocally:NO];
    
    //Username
    NSLog(@"before : %d",self.usernameLabel == nil); //Debug
    self.usernameLabel.text = self.currentUser.caseUsername;
    NSLog(@"after : %d",self.usernameLabel == nil); //Debug

    
    //Title
    self.titleLabel.text = NSLocalizedString(@"share_card_title", nil);
    NSString *string = NSLocalizedString(@"share_card_title", nil); //Debug
    NSLog(@"string : %d",string == nil); //Debug
    NSLog(@"label : %d",self.titleLabel == nil); //Debug
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
    NSRange boldRange = [self.titleLabel.text rangeOfString:@"ONECASH"];
    UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:self.titleLabel.font.pointSize];
    [attrString addAttribute: NSFontAttributeName value:boldFont range:boldRange];
    self.titleLabel.attributedText = attrString;

}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIfNeeded];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.avatarImageView.clipsToBounds = YES;
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
