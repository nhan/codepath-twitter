//
//  TweetCell.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "ComposeTweetViewController.h"


@protocol TweetCellDelegate <NSObject>
- (void) retweetAction:(Tweet*)tweet;
- (void) replyAction:(Tweet*)tweet;
- (void) favoriteAction:(Tweet*)tweet;
- (void) profileAction:(User*)user;
@end

@interface TweetCell : UITableViewCell
@property (strong, nonatomic) Tweet* tweet;
@property id<TweetCellDelegate> delegate;
- (CGFloat) estimateHeight:(Tweet *)tweetText;
@end
