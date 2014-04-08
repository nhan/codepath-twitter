//
//  TweetTableViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetTableViewController.h"
#import "TwitterClient.h"
#import "TweetDetailViewController.h"
#import "ProfileViewController.h"


@interface TweetTableViewController ()
@property (strong, nonatomic) TweetCell* referenceTweetCell;
@end

@implementation TweetTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
    UINib *tweetCellNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    self.referenceTweetCell = [tweetCellNib instantiateWithOwner:self options:nil][0];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TweetCellDelegate
- (void)replyAction:(Tweet* )tweet
{
    NSString *initialText = [NSString stringWithFormat:@"@%@ ", tweet.user.screenName];
    NSNumber *replyToTweetId = [NSNumber numberWithLongLong:tweet.tweetId];
    ComposeTweetViewController *composeViewController = [[ComposeTweetViewController alloc] initWithTweetText:initialText replyToTweetId:replyToTweetId];
    composeViewController.delegate = self;
    UINavigationController *wrapperNavController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self.delegate.navigationController presentViewController:wrapperNavController animated:YES completion: nil];
}

- (void)retweetAction:(Tweet*)tweet
{
    if (!tweet.retweeted) {
        [[TwitterClient instance] retweet:tweet success:nil failure:nil];
    } else {
        [[TwitterClient instance] unRetweet:tweet success:nil failure:nil];
    }
}

- (void)favoriteAction:(Tweet*)tweet
{
    [[TwitterClient instance] toggleFavoriteForTweet:tweet success:nil failure:nil];
}

- (void)profileAction:(User *)user
{

    UIViewController* profileVC= [[ProfileViewController alloc] initWithUser:user];
    profileVC.title = user.screenName;
    [self.delegate.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - ComposeTweetDelegate
- (void) didTweet:(Tweet *)tweet
{
    [self.delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) didCancelComposeTweet
{
    [self.delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.delegate.tweets[indexPath.row];
    cell.tweet = tweet;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.delegate.tweets[indexPath.row];
    TweetDetailViewController *detailVC = [[TweetDetailViewController alloc] initWithTweet:tweet];
    [self.delegate.navigationController pushViewController:detailVC animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.delegate.tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet* tweet = self.delegate.tweets[indexPath.row];
    return [self.referenceTweetCell estimateHeight:tweet];
}

@end
