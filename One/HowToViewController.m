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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *howToTextView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation HowToViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Wording
    self.titleLabel.text = NSLocalizedString(@"how_to_title", nil);
    self.howToTextView.text = NSLocalizedString(@"how_to_wording", nil);
    
    // UI
    self.backButton.backgroundColor = [ColorUtils mainGreen];
    self.backButton.layer.cornerRadius = self.backButton.frame.size.height / 2;
    self.titleLabel.textColor = [ColorUtils mainGreen];
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
