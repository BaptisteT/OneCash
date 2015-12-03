//
//  CustomValueViewController.h
//  One
//
//  Created by Baptiste Truchot on 12/3/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomValueVCProtocol;

@interface CustomValueViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<CustomValueVCProtocol> delegate;
@property (nonatomic) NSInteger initialValue;

@end

@protocol CustomValueVCProtocol
- (void)updateCashViewStacksValue:(NSInteger)value;
@end

