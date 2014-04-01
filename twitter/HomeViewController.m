//
//  HomeViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <MBProgressHUD.h>
#import "HomeViewController.h"
#import "TweetDetailViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"

@interface HomeViewController ()
// TODO: might want to cache this somewhere else
@property (strong, nonatomic) NSMutableArray* tweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TweetCell* referenceTweetCell;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Home";
        self.tweets = [[NSMutableArray alloc] init];
        [self refetchTweetsAndShowProgressHUD];
        [[NSNotificationCenter defaultCenter] addObserverForName:NewTweetPostedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            Tweet* tweet = notification.userInfo[NewTweetPostedNotificationKey];
            [self.tweets insertObject:tweet atIndex:0];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(signOut)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(newTweet)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *tweetCellNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    self.referenceTweetCell = [tweetCellNib instantiateWithOwner:self options:nil][0];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetCell"];
    
    // need dummy tableview controller to attach UIRefreshControl
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refetchTweetsViaRefreshControl) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) networkError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to Twitter.  Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

- (void) signOut
{
    [User removeCurrentUser];
}

- (void) setTweets:(NSArray *)tweets
{
    _tweets = [tweets mutableCopy];
}

- (void) refetchTweetsViaRefreshControl
{
    [[TwitterClient instance] homeTimelineWithSuccess:^(NSArray *tweets) {
        self.tweets = [tweets mutableCopy];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [self networkError:error];
    }];
}

- (void) refetchTweetsAndShowProgressHUD
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[TwitterClient instance] homeTimelineWithSuccess:^(NSArray *tweets) {
        self.tweets = [tweets mutableCopy];
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self networkError:error];
    }];
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

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    [cell setTweet:tweet];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];
    TweetDetailViewController *detailVC = [[TweetDetailViewController alloc] initWithTweet:tweet];
    [self.navigationController pushViewController:detailVC animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet* tweet = self.tweets[indexPath.row];
    return [self.referenceTweetCell estimateHeight:tweet];
}

@end
