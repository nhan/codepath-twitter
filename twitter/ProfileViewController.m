//
//  ProfileViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <MBProgressHUD.h>
#import "TwitterClient.h"
#import "ProfileViewController.h"
#import "HamburgerMenuController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIView *tableOutlet;
@property (strong, nonatomic) TweetTableViewController* tableViewController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@end

@implementation ProfileViewController

- (id)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        self.tableViewController = [[TweetTableViewController alloc] init];
        self.tableViewController.delegate = self;
        self.tweets = [[NSMutableArray alloc] init];
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(newTweet)];
    [self.tableOutlet addSubview:self.tableViewController.view];
    [self refreshView];
}

- (void) setShouldShowMenuButton:(BOOL)shouldShowMenuButton
{
    _shouldShowMenuButton = shouldShowMenuButton;
    if (shouldShowMenuButton) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableViewController.tableView reloadData];
}

- (void)setUser:(User *)user
{
    _user = user;
    [self refreshView];
    [self refetchTweets];
}

- (void) refreshView
{
    [self.profileImage setImageWithURL:self.user.profileImageURL];
    [self.backgroundImage setImageWithURL:self.user.bannerImageURL];
    self.nameLabel.text = self.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    self.tweetCountLabel.text = [NSString stringWithFormat:@"%d", self.user.tweetCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%d", self.user.followingCount];
    self.followerCountLabel.text = [NSString stringWithFormat:@"%d", self.user.followerCount];
    [self.tableViewController.tableView reloadData];
}

- (void) refetchTweets
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[TwitterClient instance] userTimeLine:self.user success:^(NSArray *tweets) {
        self.tweets = [tweets mutableCopy];
        [self.tableViewController.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self networkError:error];
        
    }];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.tweets insertObject:tweet atIndex:0];
}

- (void) didCancelComposeTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
