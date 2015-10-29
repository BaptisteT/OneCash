//
//  TransactionTableViewCell.m
//  One
//
//  Created by Baptiste Truchot on 9/7/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <NSDate+DateTools.h>

#import "Reaction.h"
#import "Transaction.h"
#import "User.h"

#import "TransactionTableViewCell.h"

#import "ColorUtils.h"
#import "DesignUtils.h"

@interface TransactionTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UILabel *nameAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seenImageView;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (weak, nonatomic) IBOutlet UIButton *createReactionButton;
@property (nonatomic, strong) CAShapeLayer *createReactionShapeCircle;
@property (nonatomic, strong) CAShapeLayer *seeReactionShapeCircle;
@property (weak, nonatomic) IBOutlet UIButton *seeReactionButton;

@property (strong, nonatomic) Transaction *transaction;

@end


@implementation TransactionTableViewCell

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

- (void)initWithTransaction:(Transaction *)transaction {
    // Data
    self.transaction = transaction;
    BOOL sendFlag = (transaction.sender == [User currentUser]);
    
    NSString *name;
    
    self.seenImageView.hidden = YES;
    self.userPicture.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    // Create Reaction
    [self animateOngoingReaction:NO];
    if (sendFlag || self.transaction.receiverType == kReceiverAutoRefund) {
        self.createReactionButton.hidden = YES;
    } else {
        self.createReactionButton.hidden = NO;
        if (self.transaction.reaction != nil) {
            [self.createReactionButton setTitle:@"✓" forState:UIControlStateNormal];
            self.createReactionButton.enabled = NO;
        } else {
            [self.createReactionButton setTitle:@"📷" forState:UIControlStateNormal];
            [self animateOngoingReaction:self.transaction.ongoingReaction];
        }
    }

    // See reaction
    self.seeReactionButton.hidden = !sendFlag || !transaction.reaction;
    [self.seeReactionButton setTitle:@"" forState:UIControlStateNormal];
    self.seeReactionButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.seeReactionButton setAdjustsImageWhenHighlighted:NO];
    
    // Picture tap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPicture)];
    [self.userPicture addGestureRecognizer:tapGesture];
   
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
        if (transaction.reaction) {
            [self.seeReactionButton setImage:nil forState:UIControlStateNormal];
            if (transaction.reaction.readStatus == false)
                [self animateDownloadingReaction:YES];
            [self.transaction getReactionImageAndExecuteSuccess:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.seeReactionButton setImage:image forState:UIControlStateNormal];
                    [self animateDownloadingReaction:NO];
                    if (transaction.reaction.readStatus == false) {
                        self.backgroundColor = [ColorUtils veryLightBlack];
                    }
                });
            } failure:nil];
        }
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

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)createReactionButtonClicked:(id)sender {
    self.createReactionButton.enabled = NO;
    [self.delegate reactToTransaction:self.transaction];
    self.createReactionButton.enabled = YES;
}

- (IBAction)seeReactionButtonClicked:(id)sender {
    if (self.transaction.reaction.readStatus == false && self.transaction.reaction.reactionImage) {
        CGRect convertedFrame = [self convertRect:self.seeReactionButton.frame toView:self.superview.superview.superview];
        [self.delegate showReaction:self.transaction.reaction
                              image:self.seeReactionButton.imageView.image
                       initialFrame:convertedFrame];
        self.transaction.reaction.reactionImage = nil;
    }
}

- (void)tapOnPicture {
    [self.delegate displayTwitterOptionsForTransaction:self.transaction];
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------

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

- (void)animateOngoingReaction:(BOOL)flag {
    self.createReactionButton.enabled = !flag;
    
    if (flag) {
        // Add to parent layer
        if (!self.createReactionShapeCircle) {
            [self initLoadingCircleShape];
        }
        [self.createReactionButton.layer addSublayer:self.createReactionShapeCircle];
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
        rotationAnimation.duration = 0.7;
        rotationAnimation.repeatCount = INFINITY;
        [self.createReactionShapeCircle addAnimation:rotationAnimation forKey:@"indeterminateAnimation"];
    } else {
        [self.createReactionShapeCircle removeAllAnimations];
        [self.createReactionShapeCircle removeFromSuperlayer];
    }
}

- (void)animateDownloadingReaction:(BOOL)flag {
    self.seeReactionButton.enabled = !flag;
    
    if (flag) {
        // Add to parent layer
        if (!self.seeReactionShapeCircle) {
            [self initLoadingSeeCircleShape];
        }
        [self.seeReactionButton.layer addSublayer:self.seeReactionShapeCircle];
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
        rotationAnimation.duration = 0.7;
        rotationAnimation.repeatCount = INFINITY;
        [self.seeReactionShapeCircle addAnimation:rotationAnimation forKey:@"indeterminateAnimation"];
    } else {
        [self.seeReactionShapeCircle removeAllAnimations];
        [self.seeReactionShapeCircle removeFromSuperlayer];
    }
}

- (void)initLoadingCircleShape
{
    self.createReactionShapeCircle = [DesignUtils createGradientCircleLayerWithFrame:CGRectMake(0,0,self.createReactionButton.frame.size.width,self.createReactionButton.frame.size.height) borderWidth:1 Color:[ColorUtils mainGreen] subDivisions:100];
}

- (void)initLoadingSeeCircleShape
{
    self.seeReactionShapeCircle = [DesignUtils createGradientCircleLayerWithFrame:CGRectMake(0,0,self.seeReactionButton.frame.size.width,self.seeReactionButton.frame.size.height) borderWidth:1 Color:[ColorUtils mainGreen] subDivisions:100];
}

@end
