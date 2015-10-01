//
//  UsernameViewController.m
//  One
//
//  Created by Clement Raffenoux on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <Accounts/Accounts.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Twitter/Twitter.h>

#import "User.h"

#import "ShareUsernameViewController.h"
#import "UsernameCardView.h"

#import "ColorUtils.h"
#import "DesignUtils.h"


@interface ShareUsernameViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *instaShareButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterShareButton;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImage *cardImage;

//Instagram
@property (nonatomic, retain) UIDocumentInteractionController *documentController;

@end

@implementation ShareUsernameViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Init card
    [self createUsernameCard];
    
    //Wording
    NSString *username = [User currentUser].caseUsername;
    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"card_description", nil), username];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.descriptionLabel.text];
    NSRange boldRange = [self.descriptionLabel.text rangeOfString:username];
    UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:self.descriptionLabel.font.pointSize * 1.2];
    [attrString addAttribute: NSFontAttributeName value:boldFont range:boldRange];
    [attrString addAttribute: NSForegroundColorAttributeName value:[UIColor whiteColor] range:boldRange];
    self.descriptionLabel.attributedText = attrString;
    self.topLabel.text = NSLocalizedString(@"card_top_title", nil);

    //UI
    self.closeButton.layer.zPosition = 1;
    self.descriptionLabel.layer.zPosition = 1;
    self.topLabel.layer.zPosition = 1;
    self.instaShareButton.layer.zPosition = 1;
    self.instaShareButton.layer.cornerRadius = self.instaShareButton.frame.size.height / 2;
    self.twitterShareButton.layer.zPosition = 1;
    self.twitterShareButton.layer.cornerRadius = self.twitterShareButton.frame.size.height / 2;
    self.facebookShareButton.layer.zPosition = 1;
    self.facebookShareButton.layer.cornerRadius = self.facebookShareButton.frame.size.height / 2;
    self.shareLabel.layer.zPosition = 1;
    [DesignUtils addShadowToButton:self.instaShareButton];
    [DesignUtils addShadowToButton:self.twitterShareButton];
    [DesignUtils addShadowToButton:self.facebookShareButton];
    
    //Animation
    [self addDollarLabel];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(addDollarLabel)
                                   userInfo:nil
                                    repeats:YES];
}

// --------------------------------------------
#pragma mark - Card
// --------------------------------------------

- (void)createUsernameCard
{
    CGFloat width = self.view.frame.size.width * 0.85;
    CGFloat height = width;
    CGRect frameIV = CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) / 2, width, height);
    UIImageView *cardIV = [[UIImageView alloc] initWithFrame:frameIV];
    CGFloat widthC = 512;
    CGFloat heightC = widthC;
    CGRect frameC = CGRectMake(0, 0, widthC, heightC);
    UsernameCardView *usernameCardView = [[[NSBundle mainBundle] loadNibNamed:@"UsernameCard" owner:self options:nil] objectAtIndex:0];
    [usernameCardView setFrame:frameC];
    [usernameCardView layoutSubviews];
    self.cardImage = [usernameCardView captureView];
    cardIV.image = self.cardImage;
    cardIV.layer.cornerRadius = 5;
    [self.view addSubview:cardIV];
    cardIV.layer.zPosition = 1;
}


// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareInstagram:(id)sender {

    UIImage *image = self.cardImage;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        //convert image into .png format.
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:@"insta.igo"];
        [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
        
        CGRect rect = CGRectMake(0 ,0 , 0, 0);
        NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",fullPath];
        NSURL *igImageHookFile = [NSURL URLWithString:newJpgPath];
        
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        [self.documentController setDelegate:self];
       [self.documentController setUTI:@"com.instagram.exclusivegram"];
        [self.documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
    } else {
        // The user does not have instagram
    }
}


- (IBAction)shareTwitter:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        [DesignUtils showProgressHUDAddedTo:self.view withColor:[UIColor whiteColor]];
        SLComposeViewController *twitterCompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [twitterCompose addImage:self.cardImage];
        [self presentViewController:twitterCompose
                           animated:YES
                         completion:^{
                             [DesignUtils hideProgressHUDForView:self.view];
                         }];
    } else {
        // the user does not have Twitter set up
    }
}

- (IBAction)shareFacebook:(id)sender
{
    UIImage *image = self.cardImage;
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}



// --------------------------------------------
#pragma mark - UI
// --------------------------------------------

- (void)addDollarLabel {
    int rndX = 30 + arc4random() % ((int)(self.view.frame.size.width - 30) - 30);
    
    UILabel *dollarLabel = [[UILabel alloc] initWithFrame:CGRectMake(rndX, -40, 40, 40)];
    
    //UI
    dollarLabel.text = @"$";
    dollarLabel.textAlignment = NSTextAlignmentCenter;
    dollarLabel.backgroundColor = [ColorUtils darkGreen];
    dollarLabel.textColor = [UIColor whiteColor];
    dollarLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    dollarLabel.transform = CGAffineTransformMakeScale(1, 1);
    dollarLabel.layer.zPosition = 0;
    
    [self.view addSubview:dollarLabel];
    dollarLabel.clipsToBounds = YES;
    dollarLabel.layer.cornerRadius = 20;
    
    CGFloat duration = 10 + (arc4random() % 5 - 2);
    [UIView animateWithDuration:0.3 animations:^{
        dollarLabel.transform = CGAffineTransformMakeScale(1, 1);
        dollarLabel.transform = CGAffineTransformMakeRotation(-0.01 * (arc4random() % 20));
    }];
    [UIView animateWithDuration:duration animations:^{
        dollarLabel.alpha = 0;
    }];
    CAKeyframeAnimation *animation = [self createAnimation:dollarLabel.frame];
    animation.duration = duration;
    [dollarLabel.layer addAnimation:animation forKey:@"position"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration /2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [dollarLabel removeFromSuperview];
    });
}

- (CAKeyframeAnimation *)createAnimation:(CGRect)frame {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    
    int height = self.view.frame.size.height / 1.2 + arc4random() % 40 - 20;
    int xOffset = frame.origin.x;
    int yOffset = frame.origin.y;
    int waveWidth = 50;
    CGPoint p1 = CGPointMake(xOffset, height * 0 + yOffset);
    CGPoint p2 = CGPointMake(xOffset, height * 1 + yOffset);
    CGPoint p3 = CGPointMake(xOffset, height * 2 + yOffset);
    CGPoint p4 = CGPointMake(xOffset, height * 2 + yOffset);
    
    CGPathMoveToPoint(path, NULL, p1.x,p1.y);
    
    if (arc4random() % 2) {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x - arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x + arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x - arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    } else {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x + arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x - arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x + arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    }
    animation.path = path;
    animation.calculationMode = kCAAnimationCubicPaced;
    CGPathRelease(path);
    return animation;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
