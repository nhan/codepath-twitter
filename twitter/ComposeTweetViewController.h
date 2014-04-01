//
//  ComposeTweetViewController.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeTweetDelegate <NSObject>
- (void)didTweet:(Tweet*) tweet;
- (void)didCancelComposeTweet;
@end

@interface ComposeTweetViewController : UIViewController
- (id)initWithTweetText:(NSString *)tweetText;
@property (weak, nonatomic) id<ComposeTweetDelegate> delegate;
@end
