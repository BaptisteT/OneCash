//
//  UIImageView+UserId.m
//  One
//
//  Created by Baptiste Truchot on 9/29/15.
//  Copyright © 2015 Mindie. All rights reserved.
//
#import <objc/runtime.h>

#import "UIImageView+UserId.h"

@implementation UIImageView (UserId)

- (NSString*)userId {
    return objc_getAssociatedObject(self, @selector(userId));
}

- (void)setUserId:(NSString *)userId {
    objc_setAssociatedObject(self, @selector(userId), userId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
