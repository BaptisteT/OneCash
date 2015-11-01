//
//  Reaction.m
//  One
//
//  Created by Baptiste Truchot on 10/25/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "Reaction.h"
#import "Transaction.h"
#import "User.h"

@implementation Reaction

@dynamic transactionId;
@dynamic reactionType;
@dynamic imageFile;
@dynamic readStatus;

@synthesize reactionImage;

+ (void)load {
    [self registerSubclass];
}

+ (NSString * __nonnull)parseClassName
{
    return NSStringFromClass([self class]);
}

+ (Reaction *)createReactionWithTransaction:(Transaction *)transaction
                                  imageFile:(PFFile *)imageFile
{
    Reaction *reaction = [Reaction object];
    reaction.transactionId = transaction.objectId;
    reaction.reactedId = transaction.sender.objectId;
    reaction.reactionType = kReactionImage;
    reaction.imageFile = imageFile;
    reaction.readStatus = false;
    PFACL *groupACL = [PFACL ACL];
    [groupACL setReadAccess:YES forUser:transaction.sender];
    [groupACL setReadAccess:YES forUser:[User currentUser]];
    [groupACL setWriteAccess:YES forUser:transaction.sender];
    reaction.ACL = groupACL;
    return reaction;
}


@end
