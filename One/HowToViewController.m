//
//  HowToViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "HowToViewController.h"

#import "ColorUtils.h"

@interface HowToViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIScrollView *ScrollView;

@end

@implementation HowToViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ScrollView

    
    // UI
    self.backButton.backgroundColor = [ColorUtils mainGreen];
    self.backButton.layer.cornerRadius = self.backButton.frame.size.height / 2;

}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
