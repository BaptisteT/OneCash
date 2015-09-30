//
//  UsernameCardView.m
//  One
//
//  Created by Clement Raffenoux on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "UsernameCardView.h"
#import "ColorUtils.h"

@implementation UsernameCardView

- (void)initWithFrame:(CGRect)frame andDelegate:(id<UsernameViewDeletagteProtocol>)delegate {
    [self setFrame:frame];
    self.delegate = delegate;
    self.backgroundColor = [ColorUtils mainGreen];
}

@end
