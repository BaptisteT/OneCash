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


@interface UsernameCardView ()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *dollarLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) User *currentUser;

@end

@implementation UsernameCardView

- (void)initWithFrame:(CGRect)frame andDelegate:(id<UsernameViewDeletagteProtocol>)delegate {
    
    //Init
    [self setFrame:frame];
    self.delegate = delegate;
    
    //User
    self.currentUser = [User currentUser];
    
    //UI
    self.backgroundColor = [ColorUtils mainGreen];
    self.layer.cornerRadius = self.frame.size.height / 80;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 20;
    self.avatarImageView.layer.borderColor = [ColorUtils darkGreen].CGColor;
    self.avatarImageView.layer.borderWidth = 8;
    
    //Avatar
    [self.currentUser setAvatarInImageView:self.avatarImageView bigSize:YES saveLocally:NO];
    
    //Username
    self.usernameLabel.text = self.currentUser.caseUsername;
    
    //Title
    self.titleLabel.text = NSLocalizedString(@"card_title", nil);
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIfNeeded];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.avatarImageView.clipsToBounds = YES;
    self.dollarLabel.layer.cornerRadius = self.dollarLabel.frame.size.width / 2 ;
    self.dollarLabel.clipsToBounds = YES;
}


@end
