//
//  CameraUtils.h
//  One
//
//  Created by Baptiste Truchot on 10/25/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface CameraUtils : NSObject

// Alloc and return image picker controller
+ (UIImagePickerController *)allocCameraWithSourceType:(UIImagePickerControllerSourceType)sourceType delegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate;

// Add circle overlay to edit view
+ (void)addCircleOverlayToEditView:(UIViewController *)viewController;

@end
