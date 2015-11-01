//
//  PaymentUtils.m
//  One
//
//  Created by Baptiste Truchot on 10/31/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import <Stripe.h>

#import "ConstantUtils.h"
#import "PaymentUtils.h"

@implementation PaymentUtils

+ (BOOL)applePayEnabled {
    if ([PKPaymentRequest class]) {
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:kApplePayMerchantId];
        paymentRequest.currencyCode = @"USD";
        return [Stripe canSubmitPaymentRequest:paymentRequest];
    }
    return NO;
}

+ (NSDictionary *)encodeSTPCardToNSDictionnary:(STPCard *)card
{
    if (!card) return nil;
    // only one field used for now
    return [NSDictionary dictionaryWithObjects:@[card.last4] forKeys:@[@"last4"]];
}

@end
