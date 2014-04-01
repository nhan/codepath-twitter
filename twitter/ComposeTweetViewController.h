//
//  ComposeTweetViewController.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

extern NSString * const NewTweetPostedNotification;
extern NSString * const NewTweetPostedNotificationKey;

@protocol ComposeTweetDelegate <NSObject>
- (void)didTweet:(Tweet*) tweet;
- (void)didCancelComposeTweet;
@end

@interface ComposeTweetViewController : UIViewController<UITextViewDelegate>
- (id)initWithTweetText:(NSString *)tweetText replyToTweetId:(NSNumber*)replyToTweetId;
@property (weak, nonatomic) id<ComposeTweetDelegate> delegate;
@end
