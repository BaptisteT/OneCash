
//
//  SendCashViewController.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//
#import "Reachability.h"
#import <ApplePayStubs/ApplePayStubs.h>
#import <Stripe.h>
#import <QuartzCore/QuartzCore.h>

#import "ApiManager.h"
#import "DatastoreManager.h"
#import "Transaction.h"
#import "User.h"

#import "CardViewController.h"
#import "SendCashViewController.h"
#import "CashView.h"

#import "ColorUtils.h"
#import "ConstantUtils.h"
#import "DesignUtils.h"
#import "GeneralUtils.h"
#import "KeyboardUtils.h"
#import "NotifUtils.h"
#import "OneLogger.h"
#import "TrackingUtils.h"

#define LOCALLOGENABLED YES && GLOBALLOGENABLED

@interface SendCashViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *balanceButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceBadge;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) IBOutlet UIImageView *spinImageView;
@property (strong, nonatomic) Reachability *internetReachableFoo;
@property (strong, nonatomic) IBOutlet UILabel *pickRecipientAlertLabel;
@property (strong, nonatomic) NSMutableArray *presentedCashViews;
@property (strong, nonatomic) NSTimer *associationTimer;
@property (strong, nonatomic) Transaction *transactionToSend;
@property (strong, nonatomic) Transaction *applePaySendingTransaction;
@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSInteger ongoingTransactionsCount;
@property (nonatomic) NSInteger currentCount;


@end

@implementation SendCashViewController

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init
    self.ongoingTransactionsCount = 0;
    [self setBadgeValue:0];
    
    // Wording
    self.titleLabel.text = NSLocalizedString(@"send_controller_title", nil);
    [self setSelectedUser:nil];

    // UI
    self.view.layer.cornerRadius = 5.f;
    self.arrowImageView.layer.zPosition = -9999;
    self.view.backgroundColor = [UIColor whiteColor];
    self.balanceBadge.backgroundColor = [ColorUtils red];
    self.balanceBadge.layer.cornerRadius = self.balanceBadge.frame.size.height / 2;
    self.balanceBadge.clipsToBounds = YES;
    self.balanceButton.layer.cornerRadius = self.balanceButton.frame.size.height / 2;
    self.balanceButton.clipsToBounds = YES;
    self.balanceButton.layer.borderWidth = 0.5f;
    self.balanceButton.layer.borderColor = [ColorUtils lightBlack].CGColor;
    self.balanceButton.layer.zPosition = -9999;
    [[User currentUser] setAvatarInButton:self.balanceButton];
    self.balanceBadge.layer.borderWidth = 2.f;
    self.balanceBadge.layer.borderColor = [UIColor whiteColor].CGColor;
    self.balanceBadge.layer.zPosition = -999;
    self.titleLabel.layer.cornerRadius = self.titleLabel.frame.size.height / 2;
    self.titleLabel.clipsToBounds = YES;
    self.titleLabel.hidden = YES;
    self.titleLabel.layer.borderColor = [ColorUtils darkGreen].CGColor;
    self.titleLabel.layer.borderWidth = 1.f;
    self.pickRecipientAlertLabel.layer.opacity = 0;
    self.spinImageView.hidden = YES;
    
    //shadow to fix
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
    self.titleLabel.layer.shadowRadius = 5;
    self.titleLabel.layer.shadowOpacity = 0.2;

    // Animation
    self.currentCount = 0;
    [self doArrowAnimation];
//    [self sendingAnimation];

    // Cash views
    self.presentedCashViews = [NSMutableArray new];
    for (int i=0;i<1;i++) [self addNewCashSubview];
    
    // Load server data
    [self loadLatestTransactions];
    
    // Internet connection
    [self testInternetConnection];
    
    // Register for notif
    [NotifUtils registerForRemoteNotif];
    
    // Callback
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willBecomeActiveCallback)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadLatestTransactions)
                                                 name:@"new_transaction"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigateToBalance)
                                                 name:@"new_transaction_clicked"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Keyboard Observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (self.navigateDirectlyToBalance) {
        self.navigateDirectlyToBalance = NO;
        [self performSelector:@selector(navigateToBalance) withObject:nil afterDelay:0.1];
    }
    [self updateCashViewsReceipientInfos];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"Recipient From Send"]) {
        ((RecipientViewController *) [segue destinationViewController]).delegate = self;
    } else if ([segueName isEqualToString:@"Card From Send"]) {
        ((CardViewController *) [segue destinationViewController]).redirectionViewController = self;
    } else if ([segueName isEqualToString:@"Balance From Send"]) {
        [self setBadgeValue:0];
        ((BalanceViewController *) [segue destinationViewController]).delegate = self;
    }
}

- (void)willBecomeActiveCallback {
    // load new transactions
    [self loadLatestTransactions];
    // Avoid no cashview issue
    [self resetCashSubiewsStack];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// --------------------------------------------
#pragma mark - Actions
// --------------------------------------------

- (IBAction)balanceButtonClicked:(id)sender {
    [TrackingUtils trackEvent:EVENT_BALANCE_CLICKED properties:nil];
    [self navigateToBalance];
}

- (void)recipientButtonClicked {
    [TrackingUtils trackEvent:EVENT_RECIPIENT_CLICKED properties:nil];
    [self performSegueWithIdentifier:@"Recipient From Send" sender:nil];
    // Remove selected user
    [self setSelectedUser:nil];
}

- (void)navigateToCardController {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"Card From Send" sender:nil];
}

- (void)navigateToBalance {
    [self performSegueWithIdentifier:@"Balance From Send" sender:nil];
}

- (void)removeRecipientButtonClicked {
    [self setSelectedUser:nil];
    [self updateCashViewsReceipientInfos];
}

- (void)logoutUser {
    [User logOut];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)showPickRecipientAlert {
    [self.pickRecipientAlertLabel.layer removeAllAnimations];
    [UIView animateWithDuration:0.5 animations:^{
        self.pickRecipientAlertLabel.layer.opacity = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.pickRecipientAlertLabel.layer.opacity = 0;
        } completion:^(BOOL finished) {
        }];
    }];
}

// --------------------------------------------
#pragma mark - Load Transactions
// --------------------------------------------
- (void)loadLatestTransactions {
    [ApiManager getTransactionsAroundDate:[DatastoreManager getLatestTransactionsRetrievalDate]
                                  isStart:YES
                                  success:^(NSArray *transactions) {
                                      // send notif to balance controller for refresh
                                      [[NSNotificationCenter defaultCenter] postNotificationName: @"refresh_transactions_table"
                                                                                          object:nil
                                                                                        userInfo:nil];
                                      [self setBadgeValueToNewTransactionsCount];
                                  }
                                  failure:nil];
}

- (void)setBadgeValueToNewTransactionsCount
{
    [DatastoreManager getNumberOfTransactionsSinceDate:[DatastoreManager getLastBalanceOpening]
                                               success:^(NSInteger count) {
                                                   [self setBadgeValue:count];
                                               } failure:nil];
}

// --------------------------------------------
#pragma mark - Sending
// --------------------------------------------

- (void)generateTokenAndSendTransaction {
    if (self.transactionToSend) {
        if (![self userExpectedBalanceIsPositive] && [User currentUser].paymentMethod == kPaymentMethodApplePay) {
            if (!self.applePaySendingTransaction) {
                [self beginApplePay:self.transactionToSend];
                 self.transactionToSend = nil;
            } else {
                [self startAssociationTimer];
            }
        } else {
            [self createPaymentWithTransaction:self.transactionToSend token:nil];
             self.transactionToSend = nil;
        }
    }
}

- (void)createPaymentWithTransaction:(Transaction *)transaction
                               token:(NSString *)token
{
    [ApiManager createPaymentTransactionWithTransaction:transaction
                                          applePaytoken:token
                                                success:^{
                                                    self.ongoingTransactionsCount -= transaction.transactionAmount;
                                                    // send notif to balance controller for refresh
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_transactions_table"
                                                                                                        object:nil
                                                                                                      userInfo:nil];
                                                    if (self.ongoingTransactionsCount == 0) {
                                                        self.titleLabel.text = NSLocalizedString(@"sent_label", nil);
                                                    }
                                                } failure:^(NSError *error) {
                                                    if ([error.description containsString:@"card_error"]) {
                                                        // todo BT
                                                        // go to check card ?
                                                    }
                                                    [ApiManager fetchCurrentUserAndExecuteSuccess:nil failure:nil];
                                                    self.ongoingTransactionsCount -= transaction.transactionAmount;
                                                    [self failedAnimation:transaction.transactionAmount];
                                                }];
}


// --------------------------------------------
#pragma mark - Apple pay
// --------------------------------------------

- (void)beginApplePay:(Transaction *)transaction {
    if (self.applePaySendingTransaction) {
        return;
    }
    self.applePaySucceeded = NO;
    self.applePaySendingTransaction = transaction;
    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:kApplePayMerchantId];

    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
        NSInteger valueToWithdraw = self.ongoingTransactionsCount - [User currentUser].balance;
        NSDecimalNumber *amount = (NSDecimalNumber *)[NSDecimalNumber numberWithInteger:valueToWithdraw];
        paymentRequest.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:[NSString stringWithFormat:NSLocalizedString(@"apple_pay_item", nil),transaction.receiver.caseUsername] amount:amount]];
#if DEBUG
        STPTestPaymentAuthorizationViewController *auth = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
#else
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
#endif
        auth.delegate = self;
        [self presentViewController:auth animated:YES completion:nil];
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    self.applePaySucceeded = YES;
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 completion(PKPaymentAuthorizationStatusSuccess);
                                                 [self createPaymentWithTransaction:self.applePaySendingTransaction
                                                                              token:token.tokenId];
                                                 self.applePaySendingTransaction = nil;
                                             }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    if (!self.applePaySucceeded) {
        [TrackingUtils trackEvent:EVENT_CREATE_PAYMENT_FAIL properties:@{@"amount": [NSNumber numberWithInteger:self.applePaySendingTransaction.transactionAmount], @"message": [NSNumber numberWithBool:(self.applePaySendingTransaction.message !=nil)], @"method": @"Apple Pay", @"error":@"apple_pay_auth_fail"}];
        self.ongoingTransactionsCount -= self.applePaySendingTransaction.transactionAmount;
        self.applePaySendingTransaction = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


// --------------------------------------------
#pragma mark - Cash view
// --------------------------------------------
- (void)createTransactionWithCashView:(CashView *)cashView
{
    [TrackingUtils trackEvent:EVENT_CASH_SWIPED properties:nil];
    
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
         [self removeCashSubview:cashView];

     // Create transaction
     } else {
         [self removeCashSubview:cashView];
         
         if (self.transactionToSend) {
             [self.associationTimer invalidate];
             BOOL sameReceiver = [self.transactionToSend.receiver.objectId isEqualToString:self.receiver.objectId];
             BOOL noMessageConflict = !([self.transactionToSend containsMessage] && cashView.messageTextField.text.length > 0);
             BOOL belowLimit = self.transactionToSend.transactionAmount <= kAssociationTransactionsLimit;
             
             // If we can't merge, send the first one
             if (!sameReceiver || !noMessageConflict || !belowLimit) {
                 [self generateTokenAndSendTransaction];
             } else {
                 self.ongoingTransactionsCount ++;
                 // update transaction
                 self.transactionToSend.transactionAmount ++;
                 if (cashView.messageTextField.text.length > 0) {
                     self.transactionToSend.message = cashView.messageTextField.text;
                 }
                 // Sending timer
                 [self startAssociationTimer];
             }
         } else {
             self.ongoingTransactionsCount ++;
             self.transactionToSend = [Transaction transactionWithReceiver:self.receiver
                                                         transactionAmount:1
                                                                      type:kTransactionPayment
                                                                   message:cashView.messageTextField.text];
             [self startAssociationTimer];
         }
     }
}

- (void)updateCashViewsReceipientInfos {
    for (CashView *cashView in self.presentedCashViews)
        [cashView updateRecipient];
}

- (void)adaptUIToCashViewState:(BOOL)isMoving {
    self.balanceBadge.hidden = [self.balanceBadge.text isEqualToString:@"0"];
}

- (BOOL)userExpectedBalanceIsPositive {
    return [User currentUser].balance - self.ongoingTransactionsCount > 0;
}

- (void)addNewCashSubview {
    CGFloat width = self.view.frame.size.width * 0.85;
    CGFloat height = self.view.frame.size.height * 0.90;
    CGRect frame = CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) * 2, width, height);
    CashView *cashView = [[[NSBundle mainBundle] loadNibNamed:@"CashView" owner:self options:nil] objectAtIndex:0];
    [cashView initWithFrame:frame andDelegate:self];
    cashView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    [self.view insertSubview:cashView atIndex:0];
    [self.presentedCashViews addObject:cashView];
    CGRect newFrame = cashView.frame;
    newFrame.origin.y += height;
    cashView.frame = newFrame;
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect newFrame2 = cashView.frame;
        newFrame2.origin.y -= height;
        cashView.frame = newFrame2;
        cashView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)removeCashSubview:(CashView *)view {
    [self.presentedCashViews removeObject:view];
    [view removeFromSuperview];
}

- (void)resetCashSubiewsStack {
    if (self.presentedCashViews.count >= 2) {
        NSArray *views =[self.presentedCashViews subarrayWithRange:NSMakeRange(1, self.presentedCashViews.count-1)];
        for(CashView *cashView in views) {
            if ([cashView isAtInitialPosition]) {
                cashView.userInteractionEnabled = NO;
                [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    CGRect newFrame2 = cashView.frame;
                    newFrame2.origin.y = self.view.frame.size.height;
                    cashView.frame = newFrame2;
                } completion:^(BOOL finished) {
                    [self removeCashSubview:cashView];
                }];
            }
        }
    } else if (self.presentedCashViews.count < 1) {
        [self addNewCashSubview];
    }
}

-(void)doArrowAnimation {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = self.arrowImageView.frame;
        frame.origin.y -= 50;
        self.arrowImageView.frame = frame;
        self.arrowImageView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        CGRect frame = self.arrowImageView.frame;
        frame.origin.y += 50;
        self.arrowImageView.frame = frame;
        self.arrowImageView.layer.opacity = 0.1;
        [self doArrowAnimation];
    }];
}

-(void)startSendingAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:^(BOOL finished) {
        }];
    }];
}

-(void)sendingAnimation {
    [self.spinImageView.layer removeAllAnimations];
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.spinImageView setTransform:CGAffineTransformRotate(self.spinImageView.transform, M_PI_2)];
    } completion:^(BOOL finished) {
        if (finished && !CGAffineTransformEqualToTransform(self.spinImageView.transform, CGAffineTransformIdentity)) {
            [self sendingAnimation];
        }
    }];
}



// --------------------------------------------
#pragma mark - Recipients delegate
// --------------------------------------------
- (void)setSelectedUser:(User *)user {
    self.receiver = user;
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
    return UIStatusBarStyleDefault;
}

// ----------------------------------------------------------
#pragma mark Keyboard
// ----------------------------------------------------------
// Move up create comment view on keyboard will show
- (void)keyboardWillShow:(NSNotification *)notification {
    CashView *editingView;
    for (CashView *cashView in self.presentedCashViews) {
        if (cashView.isEditingMessage) {
            editingView = cashView;
            break;
        }
    }
    if (editingView) {
        [KeyboardUtils pushUpTopView:editingView whenKeyboardWillShowNotification:notification];
    }
}

// Move down create comment view on keyboard will hide
- (void)keyboardWillHide:(NSNotification *)notification {
    CashView *editingView;
    for (CashView *cashView in self.presentedCashViews) {
        if (cashView.isEditingMessage) {
            editingView = cashView;
            break;
        }
    }
    if (editingView) {
        [KeyboardUtils moveView:editingView toCenter:editingView.initialCenter withKeyboardNotif:notification];
        editingView.isEditingMessage = NO;
    }
}

// --------------------------------------------
#pragma mark - Helpers
// --------------------------------------------

- (void)setOngoingTransactionsCount:(NSInteger)ongoingTransactionsCount {
    _ongoingTransactionsCount = ongoingTransactionsCount;
    [self setTitleLabelWording];
}

- (void)setTitleLabelWording {
    if (_ongoingTransactionsCount > 0) {
        if (_ongoingTransactionsCount > self.currentCount) {
            [self startSendingAnimation];
        }
        self.currentCount = _ongoingTransactionsCount;
        self.arrowImageView.hidden = YES;
        self.titleLabel.layer.borderColor = [ColorUtils veryDarkGreen].CGColor;
        self.titleLabel.backgroundColor = [ColorUtils darkGreen];
        self.titleLabel.font = [UIFont systemFontOfSize:30];
        self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"sending_label", nil),_ongoingTransactionsCount];
        self.titleLabel.hidden = NO;
        self.spinImageView.hidden = NO;
        [self sendingAnimation];
    } else {
        self.currentCount = 0;
        self.spinImageView.hidden = YES;
        [self.spinImageView.layer removeAllAnimations];
        self.titleLabel.layer.borderColor = [ColorUtils darkGreen].CGColor;
        self.titleLabel.backgroundColor = [ColorUtils mainGreen];
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        self.titleLabel.text = NSLocalizedString(@"sent_label", nil);
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(resetUI)
                                       userInfo:nil
                                        repeats:NO];
        
    }
}

-(void)resetUI {
    if (_ongoingTransactionsCount == 0) {
    self.titleLabel.hidden = YES;
    self.arrowImageView.hidden = NO;
    }
}

- (void)failedAnimation:(NSInteger)failedCount {
    self.titleLabel.alpha = 0;
    self.titleLabel.textColor = [ColorUtils red];
    self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"failed_label", nil),failedCount];
    [UIView animateWithDuration:1 animations:^{
        self.titleLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.titleLabel.alpha = 0;
            self.titleLabel.textColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            [self setTitleLabelWording];
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
                self.titleLabel.alpha = 1;
            } completion:nil];
        }];
    }];
}

- (void)startAssociationTimer {
    self.associationTimer = [NSTimer scheduledTimerWithTimeInterval:kAssociationTimerDuration
                                                             target:self
                                                           selector:@selector(generateTokenAndSendTransaction)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)setBadgeValue:(NSInteger)count {
    self.balanceBadge.text = [NSString stringWithFormat:@"%lu",(long)count];
    self.balanceBadge.hidden = (count == 0);
}

@end
