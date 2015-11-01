//
//  Reaction.h
//  One
//
//  Created by Baptiste Truchot on 10/25/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/parse.h>

@class Transaction;

@interface Reaction : PFObject <PFSubclassing>

typedef NS_ENUM(NSInteger,ReactionType) {
    kReactionImage = 0
};

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *reactedId;
@property (nonatomic) ReactionType reactionType;
@property (strong, nonatomic) PFFile *imageFile;
@property (nonatomic) BOOL readStatus;

@property (strong, nonatomic) UIImage *reactionImage;

+ (Reaction *)createReactionWithTransaction:(Transaction *)transaction
                                  imageFile:(PFFile *)imageFile;


@end
