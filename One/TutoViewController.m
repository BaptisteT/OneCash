//
//  TutoViewController.m
//  One
//
//  Created by Baptiste Truchot on 11/10/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "TutoViewController.h"

@interface TutoViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation TutoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.tutoText;
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.logoImageView.image = [UIImage imageNamed:self.tutoImage];
}



@end
