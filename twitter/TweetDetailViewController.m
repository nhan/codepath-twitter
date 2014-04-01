//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <NSDate+DateTools.h>

@interface TweetDetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetIndicatorLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetIndicatorPadding;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) Tweet* tweet;

@end

@implementation TweetDetailViewController

- (id)initWithTweet:(Tweet*)tweet
{
    self = [super init];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithTitle:@"Reply"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(replyButtonAction:)];
    self.navigationItem.rightBarButtonItem = replyButton;
    [self refreshView];
}

- (IBAction)replyButtonAction:(id)sender {
    NSString *initialText = [NSString stringWithFormat:@"@%@ ", self.tweet.user.screenName];
    NSNumber *replyToTweetId = [NSNumber numberWithLongLong:self.tweet.tweetId];
    ComposeTweetViewController *composeViewController = [[ComposeTweetViewController alloc] initWithTweetText:initialText replyToTweetId:replyToTweetId];
    composeViewController.delegate = self;
    UINavigationController *wrapperNavController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:wrapperNavController animated:YES completion: nil];
}

- (IBAction)retweetButtonAction:(id)sender {
    if (!self.tweet.retweeted) {
        [[TwitterClient instance] retweet:self.tweet success:nil failure:nil];
        [self refreshView];
    }
}

- (IBAction)favoriteButtonAction:(id)sender {
    [[TwitterClient instance] toggleFavoriteForTweet:self.tweet success:nil failure:nil];
    [self refreshView];
}

#pragma mark - ComposeTweetDelegate
- (void) didTweet:(Tweet *)tweet
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self refreshView];
}

- (void) didCancelComposeTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods
- (void) refreshView
{
    Tweet* tweet = self.tweet;
    if (tweet.retweetedByUser) {
        self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweetedByUser.name];
        self.retweetIndicatorLabelHeight.constant = 16.0f;
        self.retweetIndicatorPadding.constant = 5.0f;
    } else {
        self.retweetIndicatorLabelHeight.constant = 0.0f;
        self.retweetIndicatorPadding.constant = 0.0f;
    }
    
    [self.profileImageView setImageWithURL:tweet.user.profileImageURL];
    self.userNameLabel.text = tweet.user.name;
    self.userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.createdAtLabel.text = [tweet.createdAt formattedDateWithFormat:@"M/d/yy, HH:mm a"];
    self.tweetTextLabel.text = tweet.text;
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    
    if (tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_default"] forState:UIControlStateNormal];
    }
    
    if (tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_default"] forState:UIControlStateNormal];
    }
}

@end
