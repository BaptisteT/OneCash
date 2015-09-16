//
//  IPUtils.h
//  One
//
//  Created by Baptiste Truchot on 9/16/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface IPUtils : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (NSDictionary *)getIPAddresses;

@end
