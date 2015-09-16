//
//  ManagedAccountViewController.h
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManagedAccountVCProtocol;

@interface ManagedAccountViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<ManagedAccountVCProtocol> delegate;

@end

@protocol ManagedAccountVCProtocol <NSObject>

- (void)returnToBalanceController;

@end