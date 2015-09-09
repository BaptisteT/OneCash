//
//  SendCashViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "Reachability.h"

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "User.h"

#import "CardViewController.h"
#import "SendCashViewController.h"
#import "CashView.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "OneLogger.h"   

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface SendCashViewController ()
@property (weak, nonatomic) IBOutlet UIButton *balanceButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickRecipientButton;

@property (strong, nonatomic) User *receiver;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *swipeTutoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tutoArrow;

@property (nonatomic) NSInteger ongoingTransactionsCount;

@property (strong, nonatomic) Reachability *internetReachableFoo;

@end

@implementation SendCashViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.ongoingTransactionsCount = 0;
    
    // Wording
    [self.balanceButton setTitle:NSLocalizedString(@"balance_button", nil) forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"send_controller_title", nil);
    self.toLabel.text = NSLocalizedString(@"to", nil);
    [self setSelectedUser:nil];
    self.swipeTutoLabel.text = NSLocalizedString(@"swipe_to_send", nil);

    // UI
    self.toLabel.textColor = [ColorUtils mainGreen];
    self.view.backgroundColor = [ColorUtils mainGreen];
    [DesignUtils addTopBorder:self.pickRecipientButton borderSize:0.5 color:[UIColor lightGrayColor]];
    
    // Cash view
    [self addNewCashSubview];
    [self addNewCashSubview];
    
    // Load server data
    [self loadLatestTransactions];
    
    // Internet connection
    [self testInternetConnection];
    
    // Callback
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willBecomeActiveCallback)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadLatestTransactions)
                                                 name:@"new_transaction"
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DesignUtils addBottomBorder:self.selectedUserLabel borderSize:0.2 color:[UIColor lightGrayColor]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Recipient From Send"]) {
        ((RecipientViewController *) [segue destinationViewController]).delegate = self;
    } else if ([segueName isEqualToString:@"Card From Send"]) {
        ((CardViewController *) [segue destinationViewController]).redirectionViewController = self;
    } else if ([segueName isEqualToString:@"Balance From Send"]) {
        ((BalanceViewController *) [segue destinationViewController]).delegate = self;
    }
}

- (void)willBecomeActiveCallback {
    // load new transactions
    [self loadLatestTransactions];
}
// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)balanceButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Balance From Send" sender:nil];
}

- (IBAction)pickRecipientButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Recipient From Send" sender:nil];
}

- (void)navigateToCardController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"Card From Send" sender:nil];
}

// --------------------------------------------
#pragma mark - Transactions
// --------------------------------------------
- (void)loadLatestTransactions {
    [ApiManager getTransactionsAroundDate:[DatastoreManager getLatestTransactionsRetrievalDate]
                                  isStart:YES
                                  success:^(NSArray *transactions) {
                                      // send notif to balance controller for refresh
                                      [[NSNotificationCenter defaultCenter] postNotificationName: @"refresh_transactions_table"
                                                                                          object:nil
                                                                                        userInfo:nil];
                                      // todo BT
                                      // badge ?
                                  }
                                  failure:nil];
}

// --------------------------------------------
#pragma mark - Cash view
// --------------------------------------------
- (void)createTransactionWithCashView:(CashView *)cashView
{
    // No receiver
    if (!self.receiver) {
        [cashView moveViewToCenterAndExecute:^(POPAnimation *anim, BOOL completed) {
            [GeneralUtils showAlertWithTitle:NSLocalizedString(@"no_receiver_title", nil) andMessage:NSLocalizedString(@"no_receiver_message", nil)];
        }];
         
     // No cash, no card
     } else if (![self userExpectedBalanceIsPositive] && [User currentUser].paymentMethod == kPaymentMethodNone) {
         [cashView moveViewToCenterAndExecute:^(POPAnimation *anim, BOOL completed) {
             // if yes, send back to payment controller
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_card_title", nil)
                                         message:NSLocalizedString(@"no_card_message", nil)
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"later_", nil)
                               otherButtonTitles:NSLocalizedString(@"add_button", nil), nil] show];
         }];
     
     // Receiver = current
     } else if (self.receiver == [User currentUser]) {
         [self addNewCashSubview];
         [cashView removeFromSuperview];

     // Create transaction
     } else {
         
         // Apple pay
         if (![self userExpectedBalanceIsPositive] && [User currentUser].paymentMethod == kPaymentMethodApplePay) {
             // todo BT
             // ask user & get token
             // get token
         }
         
         [self addNewCashSubview];
         
         self.ongoingTransactionsCount ++;
         [ApiManager createPaymentTransactionWithReceiver:self.receiver
                                                  message:cashView.message
                                                  success:^{
                                                      [ApiManager fetchCurrentUserAndExecuteSuccess:^{
                                                          self.ongoingTransactionsCount --;
                                                      } failure:^(NSError *error) {
                                                          self.ongoingTransactionsCount --;
                                                      }];
                                                      [cashView removeFromSuperview];
                                                  } failure:^(NSError *error) {
                                                      self.ongoingTransactionsCount --;
                                                      [cashView moveViewToCenterAndExecute:nil];
                                                      // todo BT
                                                      // indicate cause of error ?
                                                  }];
     }
}

- (void)adaptUIToCashViewState:(BOOL)isMoving {
    self.balanceButton.hidden = isMoving;
    self.titleLabel.hidden = isMoving;
    self.swipeTutoLabel.hidden = isMoving;
    self.tutoArrow.hidden = isMoving;
}

- (BOOL)userExpectedBalanceIsPositive {
    return [User currentUser].balance + self.ongoingTransactionsCount > 0;
}

- (void)addNewCashSubview {
    CGFloat width = self.view.frame.size.width * 0.85;
    CGFloat height = self.view.frame.size.height * 0.80;
    CGRect frame = CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) / 2, width, height);
    CashView *cashView = [[[NSBundle mainBundle] loadNibNamed:@"CashView" owner:self options:nil] objectAtIndex:0];
    cashView.delegate = self;
    cashView.frame = frame;
    [self.view insertSubview:cashView atIndex:0];
}

// --------------------------------------------
#pragma mark - Recipients delegate
// --------------------------------------------
- (void)setSelectedUser:(User *)user {
    self.receiver = user;
    if (user) {
        self.selectedUserLabel.text = user.caseUsername;
        self.selectedUserLabel.textColor = [ColorUtils mainGreen];
    } else {
        self.selectedUserLabel.text = NSLocalizedString(@"recipient_title", nil);
        self.selectedUserLabel.textColor = [UIColor lightGrayColor];
    }
}

// --------------------------------------------
#pragma mark - Alert View delegate
// --------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:NSLocalizedString(@"no_card_title", nil)]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"add_button", nil)]) {
            [self navigateToCardController];
        }
    }
}

// --------------------------------------------
#pragma mark - Misc
// --------------------------------------------

// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    self.internetReachableFoo = [Reachability reachabilityForInternetConnection];
    // Internet is reachable
    self.internetReachableFoo.reachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OneLog(LOCALLOGENABLED,@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    self.internetReachableFoo.unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OneLog(LOCALLOGENABLED,@"Someone broke the internet :(");
        });
    };
    [self.internetReachableFoo startNotifier];
}

// Set status bar color to white
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
