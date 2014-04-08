//
//  HomeViewController.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTweetViewController.h"
#import "TweetTableViewController.h"
#import "TweetCell.h"

@interface TimelineViewController : UIViewController<TweetTableViewDelegate, ComposeTweetDelegate>
@property (strong, nonatomic) NSMutableArray* tweets;
- (id) initWithDataLoadingBlockWithSuccessFailure:(void (^)(void (^success)(NSArray *), void (^failure)(NSError *))) block;
- (void) refetchTweetsAndShowProgressHUD;
@end
