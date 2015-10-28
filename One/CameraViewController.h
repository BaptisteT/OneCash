//
//  CameraViewController.h
//  One
//
//  Created by Baptiste Truchot on 10/27/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraVCProtocol;

@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) id<CameraVCProtocol> delegate;

@end

@protocol CameraVCProtocol

- (void)handleImage:(UIImage *)image;

@end