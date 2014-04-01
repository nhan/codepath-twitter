//
//  TweetDetailViewController.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTweetViewController.h"

@interface TweetDetailViewController : UIViewController<ComposeTweetDelegate>
- (id)initWithTweet:(Tweet*)tweet;
@end
