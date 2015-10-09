//
//  HowToViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "HowToViewController.h"

#import "ColorUtils.h"
#import <MessageUI/MessageUI.h>

@interface HowToViewController () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *answerLabel;
@property (strong, nonatomic) IBOutlet UIView *topBarview;
@property (strong, nonatomic) IBOutlet UIButton *contactButton;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;

@property (strong, nonatomic) IBOutlet UILabel *title1;
@property (strong, nonatomic) IBOutlet UILabel *title2;
@property (strong, nonatomic) IBOutlet UILabel *title3;
@property (strong, nonatomic) IBOutlet UILabel *title4;
@property (strong, nonatomic) IBOutlet UILabel *title5;
@property (strong, nonatomic) IBOutlet UILabel *title6;
@property (strong, nonatomic) IBOutlet UILabel *title7;
@property (strong, nonatomic) IBOutlet UILabel *title8;
@property (strong, nonatomic) IBOutlet UILabel *title9;

@property (strong, nonatomic) IBOutlet UILabel *answer1;
@property (strong, nonatomic) IBOutlet UILabel *answer2;
@property (strong, nonatomic) IBOutlet UILabel *answer3;
@property (strong, nonatomic) IBOutlet UILabel *answer4;
@property (strong, nonatomic) IBOutlet UILabel *answer5;
@property (strong, nonatomic) IBOutlet UILabel *answer6;
@property (strong, nonatomic) IBOutlet UILabel *answer7;
@property (strong, nonatomic) IBOutlet UILabel *answer8;
@property (strong, nonatomic) IBOutlet UILabel *answer9;

@end

@implementation HowToViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Wording
    self.title1.text = NSLocalizedString(@"how_title_1", nil);
    self.title2.text = NSLocalizedString(@"how_title_2", nil);
    self.title3.text = NSLocalizedString(@"how_title_3", nil);
    self.title4.text = NSLocalizedString(@"how_title_4", nil);
    self.title5.text = NSLocalizedString(@"how_title_5", nil);
    self.title6.text = NSLocalizedString(@"how_title_6", nil);
    self.title7.text = NSLocalizedString(@"how_title_7", nil);
    self.title8.text = NSLocalizedString(@"how_title_8", nil);
    self.title9.text = NSLocalizedString(@"how_title_9", nil);
    
    self.answer1.text = NSLocalizedString(@"how_answer_1", nil);
    self.answer2.text = NSLocalizedString(@"how_answer_2", nil);
    self.answer3.text = NSLocalizedString(@"how_answer_3", nil);
    self.answer4.text = NSLocalizedString(@"how_answer_4", nil);
    self.answer5.text = NSLocalizedString(@"how_answer_5", nil);
    self.answer6.text = NSLocalizedString(@"how_answer_6", nil);
    self.answer7.text = NSLocalizedString(@"how_answer_7", nil);
    self.answer8.text = NSLocalizedString(@"how_answer_8", nil);
    self.answer9.text = NSLocalizedString(@"how_answer_9", nil);
    
   [self.contactButton setTitle:NSLocalizedString(@"how_button", nil) forState:UIControlStateNormal];
    self.endLabel.text = NSLocalizedString(@"how_end_label", nil);
    self.topLabel.text = NSLocalizedString(@"how_to_title", nil);
    
    // UI
    for (UILabel *label in self.titleLabel) {
        label.textColor = [ColorUtils mainGreen];
    }
    self.topBarview.backgroundColor = [ColorUtils mainGreen];
    self.contactButton.layer.cornerRadius = self.contactButton.frame.size.height/2;
    self.contactButton.backgroundColor = [ColorUtils mainGreen];

}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)supportButtonPressed:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"support@one.cash"]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
