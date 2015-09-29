//
//  TweetTableViewCell.m
//  One
//
//  Created by Baptiste Truchot on 9/18/15.
//  Copyright © 2015 Mindie. All rights reserved.
//

#import "ApiManager.h"
#import "User.h"

#import "TweetTableViewCell.h"

#import "ConstantUtils.h"

@interface TweetTableViewCell()

@property (strong, nonatomic) NSString *originalString;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation TweetTableViewCell

// --------------------------------------------
#pragma mark - Life cycle
// --------------------------------------------

- (void)initWithTweet:(NSString *)tweet
{
    self.originalString = tweet;
    self.textView.text = tweet;
    self.textView.delegate = self;
    [self resizeCell];
}

// --------------------------------------------
#pragma mark - Textfield delegate
// --------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = self.originalString;
    } else {
        [User currentUser].tweetWording = textView.text;
        [ApiManager saveCurrentUserAndExecuteSuccess:nil failure:nil];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.textView resignFirstResponder];
        return NO;
    }
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (newText.length > kMaxTweetLength) {
        return NO;
    } else {
        [self resizeCell];
    }
    return YES;
}

- (void)resizeCell {
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)];
    [self.delegate adjustHeightOfTweetCell:size.height + 14];
}

@end
