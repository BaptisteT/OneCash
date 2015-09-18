//
//  TweetTableViewCell.h
//  One
//
//  Created by Baptiste Truchot on 9/18/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TweetTVCProtocol;

@interface TweetTableViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) id<TweetTVCProtocol> delegate;

- (void)initWithTweet:(NSString *)tweet;

@end

@protocol TweetTVCProtocol

- (void)adjustHeightOfTweetCell:(NSInteger)height;

@end
