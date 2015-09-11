//
//  SwitchTableViewCell.m
//  One
//
//  Created by Baptiste Truchot on 9/11/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "SwitchTableViewCell.h"

@interface SwitchTableViewCell()
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSInteger section;

@end

@implementation SwitchTableViewCell

- (void)setTitle:(NSString *)title delegate:(id<SwitchTVCProtocol>)delegate section:(NSInteger)section andSwitchState:(BOOL)state {
    self.titleLabel.text = title;
    self.delegate = delegate;
    self.section = section;
    [self.switchButton setOn:state];
}

- (IBAction)slideButtonSwitched:(id)sender {
    [self.delegate slideSwitched:self.switchButton.isOn ofSection:self.section];
}

@end
