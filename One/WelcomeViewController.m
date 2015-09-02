//
//  WelcomeViewController.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import <MBProgressHUD.h>

#import "ApiManager.h"

#import "WelcomeViewController.h"

#import "ConstantUtils.h"
#import "OneLogger.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)loginWithTwitter:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ApiManager logInWithTwitterAndExecuteSuccess:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self performSegueWithIdentifier:@"Email From Welcome" sender:nil];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        // todo BT
        // differentiate between expected & unexpected error
    }];
}

@end
