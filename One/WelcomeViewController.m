//
//  WelcomeViewController.m
//  One
//
//  Created by Baptiste Truchot on 8/26/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "ApiManager.h"
#import "User.h"

#import "SendCashViewController.h"
#import "TutoViewController.h"
#import "WelcomeViewController.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "OneLogger.h"
#import "TrackingUtils.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface WelcomeViewController ()

@property (strong, nonatomic) UIPageViewController *tutoPageViewController;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageTitles;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *howToButton;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;

@end

@implementation WelcomeViewController

// --------------------------------------------
#pragma mark - Life Cycle
// --------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // wording
    self.taglineLabel.text = NSLocalizedString(@"tagline_label", nil);
    [self.loginButton setTitle:NSLocalizedString(@"twitter_button", nil) forState:UIControlStateNormal];
    NSString *terms = NSLocalizedString(@"terms_of_services", nil);
    NSString *privacy = NSLocalizedString(@"privacy_policy", nil);
    NSString *completeString = [NSString stringWithFormat:NSLocalizedString(@"terms_label", nil),terms,privacy];
    
    // Create the data model
    // todo BT
    _pageTitles = @[NSLocalizedString(@"wemoms_tagline", nil), NSLocalizedString(@"tuto_feed", nil), NSLocalizedString(@"tuto_question", nil)];
    _pageImages = @[@"tuto_image_feed", @"tuto_image_feed", @"tuto_image_question"];
    
    // Page VC
    self.tutoPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.tutoPageViewController.delegate = self;
    self.tutoPageViewController.dataSource = self;
    TutoViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.tutoPageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.tutoPageViewController];
    [self.view insertSubview:self.tutoPageViewController.view atIndex:0];
    [self.tutoPageViewController didMoveToParentViewController:self];
    self.tutoPageViewController.extendedLayoutIncludesOpaqueBars = YES;
    
    // UI
    self.view.backgroundColor = [ColorUtils mainGreen];
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height / 2;
    [self.loginButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    self.howToButton.layer.cornerRadius = self.howToButton.frame.size.height / 2;
    [self.howToButton setTitleColor:[ColorUtils mainGreen] forState:UIControlStateNormal];
    [self.howToButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:completeString];
    UIColor *color =[UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    NSDictionary *attribute = @{NSForegroundColorAttributeName: color};
    [attrString addAttributes:attribute range:[completeString rangeOfString:terms]];
    [attrString addAttributes:attribute range:[completeString rangeOfString:privacy]];
    self.termsLabel.attributedText = attrString;
    self.termsLabel.numberOfLines = 0;
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        self.termsLabel.font = [self.termsLabel.font fontWithSize:14];
    }
    
    // Gesture
    UITapGestureRecognizer *termsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTerms)];
    [self.termsLabel addGestureRecognizer:termsTap];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tutoPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.loginButton.frame.origin.y);
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"Send From Welcome"]) {
        if ([sender boolValue]) {
            ((SendCashViewController *) [segue destinationViewController]).navigateDirectlyToBalance = YES;
        }
    }
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)loginWithTwitter:(id)sender {
    [DesignUtils showProgressHUDAddedTo:self.view withColor:[UIColor whiteColor]];
    [ApiManager logInWithTwitterAndExecuteSuccess:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DesignUtils hideProgressHUDForView:self.view];
            // Rediect to send if email already in / email otherwise
            BOOL isNew = [User currentUser].isNew;
            NSString *email = [User currentUser].email;
            if (email && email.length > 0) {
                [ApiManager saveCurrentUserAndExecuteSuccess:^{
                    if (isNew) {
                        // Alert followers
                        [ApiManager alertTwitterFollowersOnSignUpAndSuccess:nil failure:nil];
                    }
                    [self performSegueWithIdentifier:@"Send From Welcome" sender:nil];
                } failure:^(NSError *error) {
                    // If it's an email issue, go to email
                    if ([[error.userInfo valueForKey:@"error"] containsString:@"email"]) {
                        if (isNew) {
                            [self performSegueWithIdentifier:@"Email From Welcome" sender:nil];
                        } else {
                            [self performSegueWithIdentifier:@"Send From Welcome" sender:nil];
                        }
                    } else {
                        [User logOut];
                    }
                }];
            } else {
               [self performSegueWithIdentifier:@"Email From Welcome" sender:nil];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [User logOut];
            [DesignUtils hideProgressHUDForView:self.view];
        });
    }];
}

- (IBAction)howToButtonClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_HOW_TO properties:nil];
    [self performSegueWithIdentifier:@"How From Welcome" sender:nil];
}

// Redirect to terms webpage
- (void)tapOnTerms {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kOneWebsiteTermsLink]];
}

// --------------------------------------------
#pragma mark - Page View Controller Data Source
// --------------------------------------------

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TutoViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TutoViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (TutoViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TutoViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutoViewController"];
    pageContentViewController.tutoImage = self.pageImages[index];
    pageContentViewController.tutoText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

// --------------------------------------------
#pragma mark - UI
// --------------------------------------------
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
