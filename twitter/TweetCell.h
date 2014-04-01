//
//  TweetCell.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TweetCell : UITableViewCell
@property (strong, nonatomic) Tweet* tweet;

- (CGFloat) estimateHeight:(Tweet *)tweetText;
@end
