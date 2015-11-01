//
//  CameraViewController.m
//  One
//
//  Created by Baptiste Truchot on 10/27/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "CameraViewController.h"

#import "ConstantUtils.h"
#import "DesignUtils.h"

@interface CameraViewController ()

// Camera
@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlipButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
// Edit
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *photoConfirmButton;
@property (weak, nonatomic) IBOutlet UIButton *photoDeleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *stickerImageView;


@end

@implementation CameraViewController {
    BOOL _displayCamera;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.view.backgroundColor = [UIColor blackColor];
    _displayCamera = YES;
    [self allocAndInitFullScreenCamera];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.photoConfirmButton.hidden = YES;
    self.photoDeleteButton.hidden = YES;
//    self.stickerImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_displayCamera) {
        [self presentViewController:self.imagePickerController animated:NO completion:NULL];
    } else if (self.imageView.image) {
        self.photoConfirmButton.hidden = NO;
        self.photoDeleteButton.hidden = NO;
        self.stickerImageView.hidden = NO;
    }
}


// ----------------------------------------------------------
#pragma mark Preview
// ----------------------------------------------------------
- (IBAction)cancelPhotoButtonClicked:(id)sender
{
    self.imageView.image = nil;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePickerController animated:NO completion:NULL];
}

- (IBAction)checkButtonClicked:(id)sender
{
    self.photoConfirmButton.hidden = YES;
    self.photoDeleteButton.hidden = YES;
    UIImage *image = [DesignUtils createImageFromView:self.view];
    [self.delegate handleImage:image];
    [self dismissViewControllerAnimated:NO completion:nil];
}


// ----------------------------------------------------------
#pragma mark ImagePickerController
// ----------------------------------------------------------

// Alloc the impage picker controller
- (void) allocAndInitFullScreenCamera
{
    // Create custom camera view
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.delegate = self;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    // Custom buttons
    imagePickerController.showsCameraControls = NO;
    imagePickerController.allowsEditing = NO;
    imagePickerController.navigationBarHidden=YES;
    
    NSString *xibName = @"CameraOverlay";
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
    UIView* myView = [ nibViews objectAtIndex: 0];
    myView.frame = self.view.frame;
    
    imagePickerController.cameraOverlayView = myView;
    
    double cameraHeight = self.view.frame.size.width * kCameraAspectRatio;
    double translationFactor = (self.view.frame.size.height - cameraHeight) / 2;
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, translationFactor);
    imagePickerController.cameraViewTransform = translate;
    
    double rescalingRatio = self.view.frame.size.height / cameraHeight;
    CGAffineTransform scale = CGAffineTransformScale(translate, rescalingRatio, rescalingRatio);
    imagePickerController.cameraViewTransform = scale;
    
    // flash disactivated by default
    imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    self.imagePickerController = imagePickerController;
}

// Display the relevant part of the photo once taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editInfo
{
    UIImage *originalImage =  [editInfo objectForKey:UIImagePickerControllerOriginalImage];
    UIImageOrientation orientation = self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
    self.imageView.image = [UIImage imageWithCGImage:originalImage.CGImage scale:1.0 orientation:orientation];
    [self closeCamera];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self closeCamera];
}


- (IBAction)takePictureButtonClicked:(id)sender {
    [self.imagePickerController takePicture];
}


- (IBAction)flipCameraButtonClicked:(id)sender
{
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self closeCamera];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)closeCamera
{
    _displayCamera = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
    [self setNeedsStatusBarAppearanceUpdate];
}

// ----------------------------------------------------------
#pragma mark UI
// ----------------------------------------------------------
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
