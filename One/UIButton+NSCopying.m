//
//  UIButton+NSCopying.m
//  One
//
//  Created by Baptiste Truchot on 12/3/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "UIButton+NSCopying.h"

@implementation UIButton (NSCopying)

- (id)copy {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self];
    UIButton *buttonCopy = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    buttonCopy.layer.cornerRadius = self.layer.cornerRadius;
    return buttonCopy;
}

@end
