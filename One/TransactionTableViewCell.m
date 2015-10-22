//
//  TransactionTableViewCell.m
//  One
//
//  Created by Baptiste Truchot on 9/7/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <NSDate+DateTools.h>
#import "Transaction.h"
#import "User.h"

#import "TransactionTableViewCell.h"

#import "ColorUtils.h"

@interface TransactionTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UILabel *nameAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seenImageView;
@property (strong, nonatomic) CAShapeLayer *borderLayer;

@property (strong, nonatomic) Transaction *transaction;

@end


@implementation TransactionTableViewCell

- (void)initWithTransaction:(Transaction *)transaction {
    // Data
    self.transaction = transaction;
    BOOL sendFlag = (transaction.sender == [User currentUser]);
    
    NSString *name;
    
    self.seenImageView.hidden = YES;
   
    // payment received
    if (!sendFlag) {
        self.valueLabel.backgroundColor = [ColorUtils mainGreen];
        self.messageLabel.backgroundColor = [ColorUtils darkGreen];
        if (transaction.message && transaction.message.length > 0) {
            self.messageLabel.hidden = NO;
            self.messageLabel.text = [NSString stringWithFormat:@"%@     ",transaction.message];
        } else {
            self.messageLabel.hidden = YES;
        }
        [transaction.sender setAvatarInImageView:self.userPicture bigSize:NO saveLocally:YES];
        name = [NSString stringWithFormat:@"from $%@, ",transaction.sender.caseUsername];
        
    // cash out
    } else if (transaction.transactionType == kTransactionCashout) {
        self.valueLabel.backgroundColor = [ColorUtils red];
        self.messageLabel.textColor = [ColorUtils red];
        
        self.messageLabel.hidden = NO;
        self.messageLabel.text = [NSString stringWithFormat:@" %@     ",NSLocalizedString(@"cashout_string", nil)];
        
        [transaction.sender setAvatarInImageView:self.userPicture bigSize:NO saveLocally:YES];
        name = @"";
        
    // payment sent
    } else {
        self.valueLabel.backgroundColor = [ColorUtils mainGreen];
        self.messageLabel.textColor = [ColorUtils mainGreen];
        
        if (transaction.message && transaction.message.length > 0) {
            self.messageLabel.hidden = NO;
            self.messageLabel.text = [NSString stringWithFormat:@" %@     ",transaction.message];
        }else {
            self.messageLabel.hidden = YES;
        }
        
        [transaction.receiver setAvatarInImageView:self.userPicture bigSize:NO saveLocally:YES];
        name = [NSString stringWithFormat:@"to $%@, ",transaction.receiver.caseUsername];
        
        self.seenImageView.hidden = !self.transaction.readStatus;

    }
    NSString *time = transaction.createdAt.shortTimeAgoSinceNow;
    self.nameAndTimeLabel.text = [NSString stringWithFormat:@"%@%@",name,time];
    self.valueLabel.text = [NSString stringWithFormat:@"$%lu",(long)transaction.transactionAmount];
    
    // UI
    self.valueLabel.clipsToBounds = YES;
    self.messageLabel.clipsToBounds = YES;
    self.userPicture.clipsToBounds = YES;
    self.userPicture.layer.cornerRadius = self.userPicture.frame.size.height / 2;
    self.userPicture.layer.borderColor = [ColorUtils lightBlack].CGColor;
    self.userPicture.layer.borderWidth = 0.5f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setShapeLayers];
}

- (void)setShapeLayers {
    BOOL sendFlag = (self.transaction.sender == [User currentUser]);
    CAShapeLayer *valueShapeLayer = [CAShapeLayer new];
    CAShapeLayer *messageShapeLayer = [CAShapeLayer new];
    if (!sendFlag) {
        if (self.messageLabel.hidden) {
            valueShapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.valueLabel.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.valueLabel.frame.size.height/2,self.valueLabel.frame.size.height/2)].CGPath;
        } else {
            valueShapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.valueLabel.bounds byRoundingCorners:UIRectCornerTopLeft |UIRectCornerBottomLeft cornerRadii:CGSizeMake(self.valueLabel.frame.size.height/2,self.valueLabel.frame.size.height/2)].CGPath;
        }
        self.valueLabel.layer.mask = valueShapeLayer;
        messageShapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.messageLabel.bounds byRoundingCorners:UIRectCornerBottomRight |UIRectCornerTopRight cornerRadii:CGSizeMake(self.messageLabel.frame.size.height,self.messageLabel.frame.size.height)].CGPath;
        self.messageLabel.layer.mask = messageShapeLayer;
    } else {
        if (self.messageLabel.hidden) {
            valueShapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.valueLabel.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.valueLabel.frame.size.height/2,self.valueLabel.frame.size.height/2)].CGPath;
        } else {
            valueShapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.valueLabel.bounds byRoundingCorners:UIRectCornerTopRight |UIRectCornerBottomRight cornerRadii:CGSizeMake(self.valueLabel.frame.size.height/2,self.valueLabel.bounds.size.height/2)].CGPath;
        }
        self.valueLabel.layer.mask = valueShapeLayer;
        messageShapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.messageLabel.bounds byRoundingCorners:UIRectCornerBottomLeft |UIRectCornerTopLeft cornerRadii:CGSizeMake(self.messageLabel.frame.size.height,self.messageLabel.bounds.size.height)].CGPath;
        self.messageLabel.layer.mask = messageShapeLayer;
        
        // Border
        if (self.borderLayer) {
            [self.borderLayer removeFromSuperlayer];
        }
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        [borderLayer setPath:messageShapeLayer.path];
        [borderLayer setLineWidth:2.0f];
        [borderLayer setStrokeColor:(self.transaction.transactionType == kTransactionCashout ? [ColorUtils red].CGColor : [ColorUtils mainGreen].CGColor)];
        [borderLayer setFillColor:[UIColor clearColor].CGColor];
        borderLayer.frame = self.bounds;
        [self.messageLabel.layer addSublayer:borderLayer];
        self.borderLayer = borderLayer;
    }
}

@end
