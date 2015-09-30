//
//  UsernameViewController.m
//  One
//
//  Created by Clement Raffenoux on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "UsernameViewController.h"

#import "ColorUtils.h"
#import "User.h"

@interface UsernameViewController ()
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@end

@implementation UsernameViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Init card
    [self createUsernameCard];
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// --------------------------------------------
#pragma mark - Card
// --------------------------------------------

-(void)createUsernameCard {
    CGFloat width = self.view.frame.size.width * 0.85;
    CGFloat height = width;
    CGRect frame = CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) / 2, width, height);
    UsernameCardView *usernameCardView = [[[NSBundle mainBundle] loadNibNamed:@"UsernameCard" owner:self options:nil] objectAtIndex:0];
    [usernameCardView initWithFrame:frame andDelegate:self];
    [self.view insertSubview:usernameCardView atIndex:0];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

-(IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

-(User *)currentUser {
    User *currentUser = [User currentUser];
    return currentUser;
}

@end
