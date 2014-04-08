//
//  TweetTableViewController.h
//  twitter
//
//  Created by Nhan Nguyen on 4/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTweetViewController.h"
#import "TweetCell.h"

@protocol TweetTableViewDelegate <NSObject>
- (UINavigationController*) navigationController;
- (NSArray*) tweets;
@end

@interface TweetTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ComposeTweetDelegate, TweetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<TweetTableViewDelegate> delegate;
@end
