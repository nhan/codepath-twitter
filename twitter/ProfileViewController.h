//
//  ProfileViewController.h
//  twitter
//
//  Created by Nhan Nguyen on 4/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ComposeTweetViewController.h"
#import "TweetTableViewController.h"


@interface ProfileViewController : UIViewController<TweetTableViewDelegate, ComposeTweetDelegate>
@property (strong, nonatomic) NSMutableArray* tweets;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) BOOL shouldShowMenuButton;

- (id)initWithUser:(User *)user;
@end
