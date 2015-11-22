//
//  TutoViewController.m
//  One
//
//  Created by Baptiste Truchot on 11/10/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "GeneralUtils.h"

#import "TutoViewController.h"


@interface TutoViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraint;

@end

@implementation TutoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.tutoText;
    self.titleLabel.numberOfLines = 0;
    self.logoImageView.image = [UIImage imageNamed:self.tutoImage];
    
    if (!IS_IPHONE_4_OR_LESS && !IS_IPHONE_5) {
        self.labelTopConstraint.constant = 70;
        self.titleLabel.font = [self.titleLabel.font fontWithSize:20];
    }
}



@end
