//
//  UsernameCardView.h
//  One
//
//  Created by Clement Raffenoux on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
@import Foundation;
#import <UIKit/UIKit.h>

@protocol UsernameViewDeletagteProtocol;

@class User;


@interface UsernameCardView : UIView

@property (weak, nonatomic) id<UsernameViewDeletagteProtocol> delegate;

- (void)initWithFrame:(CGRect)frame andDelegate:(id<UsernameViewDeletagteProtocol>)delegate ;

@end


@protocol UsernameViewDeletagteProtocol
@end

