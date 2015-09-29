//
//  UsernameViewController.m
//  One
//
//  Created by Clement Raffenoux on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "UsernameViewController.h"

#import "ColorUtils.h"

@interface UsernameViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@end

@implementation UsernameViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
