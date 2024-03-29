//
//  PaymentUtils.h
//  One
//
//  Created by Baptiste Truchot on 10/31/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPCard;

@interface PaymentUtils : NSObject

+ (BOOL)applePayEnabled;

+ (NSDictionary *)encodeSTPCardToNSDictionnary:(STPCard *)card;

@end
