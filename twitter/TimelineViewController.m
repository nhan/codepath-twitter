//
//  HomeViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <MBProgressHUD.h>
#import "HamburgerMenuController.h"
#import "TimelineViewController.h"
#import "TweetDetailViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"

@interface TimelineViewController ()
@property (weak, nonatomic) IBOutlet UIView *tableOutlet;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) TweetTableViewController* tableViewController;
@property (copy, nonatomic) void (^dataLoadingBlockWithSuccessFailure)(void (^success)(NSArray *), void (^failure)(NSError *));
@end

@implementation TimelineViewController

- (id) initWithDataLoadingBlockWithSuccessFailure:(void (^)(void (^success)(NSArray *), void (^failure)(NSError *))) block;
{
    self = [super init];
    if (self) {
        self.tableViewController = [[TweetTableViewController alloc] init];
        self.tableViewController.delegate = self;
        self.tweets = [[NSMutableArray alloc] init];
        self.dataLoadingBlockWithSuccessFailure = block;
        [self refetchTweetsAndShowProgressHUD];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(newTweet)];

    [self.tableOutlet addSubview:self.tableViewController.view];
    
    // need dummy UITableViewController to attach UIRefreshControl
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableViewController.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refetchTweetsViaRefreshControl) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableViewController.tableView reloadData];
}

- (void) networkError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to Twitter.  Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

- (void) toggleMenu
{
    HamburgerMenuController* menuController = self.navigationController.hamburgerMenuController;
    NSLog(@"Hamburger Menu %@", menuController);
    if (menuController.isMenuRevealed) {
        [menuController hideMenuWithDuration:menuController.maxAnimationDuration];
    } else {
        [menuController revealMenuWithDuration:menuController.maxAnimationDuration];
    }
}

- (void) setTweets:(NSArray *)tweets
{
    _tweets = [tweets mutableCopy];
}

- (void) refetchTweetsViaRefreshControl
{
    self.dataLoadingBlockWithSuccessFailure(^(NSArray *tweets) {
        self.tweets = [tweets mutableCopy];
        [self.tableViewController.tableView reloadData];
        [self.refreshControl endRefreshing];
    }, ^(NSError *error) {
        [self.refreshControl endRefreshing];
        [self networkError:error];
    });
}

- (void) refetchTweetsAndShowProgressHUD
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.dataLoadingBlockWithSuccessFailure(^(NSArray *tweets) {
        self.tweets = [tweets mutableCopy];
        [self.tableViewController.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }, ^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self networkError:error];
    });
}

- (void) newTweet
{
    ComposeTweetViewController *composeViewController = [[ComposeTweetViewController alloc] initWithTweetText:@"" replyToTweetId:nil];
    composeViewController.delegate = self;
    UINavigationController *wrapperNavController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:wrapperNavController animated:YES completion: nil];
}

#pragma mark - ComposeTweetDelegate
- (void) didTweet:(Tweet *)tweet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didCancelComposeTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
