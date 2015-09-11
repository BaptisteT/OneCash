//
//  SwitchTableViewCell.h
//  One
//
//  Created by Baptiste Truchot on 9/11/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchTVCProtocol;

@interface SwitchTableViewCell : UITableViewCell

@property (weak, nonatomic) id<SwitchTVCProtocol> delegate;
- (void)setTitle:(NSString *)title delegate:(id<SwitchTVCProtocol>)delegate section:(NSInteger)section andSwitchState:(BOOL)state;

@end

@protocol SwitchTVCProtocol

- (void)slideSwitched:(BOOL)state ofSection:(NSInteger)section;

@end
