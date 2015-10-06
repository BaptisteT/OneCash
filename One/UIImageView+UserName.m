//
//  UIImageView+UserId.m
//  One
//
//  Created by Baptiste Truchot on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import <objc/runtime.h>

#import "UIImageView+UserName.h"

@implementation UIImageView (UserName)

- (NSString*)userName {
    return objc_getAssociatedObject(self, @selector(userName));
}

- (void)setUserName:(NSString *)userName {
    objc_setAssociatedObject(self, @selector(userName), userName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
