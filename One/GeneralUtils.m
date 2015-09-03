//
//  GeneralUtils.m
//  One
//
//  Created by Baptiste Truchot on 9/3/15.
//  Copyright (c) 2015 Mindie. All rights reserved.
//

#import "GeneralUtils.h"

@implementation GeneralUtils

// Show an alert message
+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title ? title : @""
                                message:message ? message : @""
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
