//
//  HomeViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "HomeViewController.h"
#import "TwitterClient.h"
#import <MBProgressHUD.h>

@interface HomeViewController ()
// TODO: might want to cache this somewhere else
@property (strong, nonatomic) NSArray* tweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Home";
        self.tweets = [[NSArray alloc] init];
        [self refetchTweetsWithProgressHUD:YES];
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    cell.textLabel.text = tweet.text;
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (void) refetchTweetsWithProgressHUD:(BOOL) shouldShowHUD
{
    if (shouldShowHUD) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [[TwitterClient instance] homeTimelineWithSuccess:^(NSArray *tweets) {
        self.tweets = tweets;
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self networkError:error];
    }];
}
- (void) signOut
{
    [User removeCurrentUser];
}

- (void) setTweets:(NSArray *)tweets
{
    _tweets = tweets;
}

- (void) newTweet
{
    
}

- (void) networkError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to Twitter.  Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}
@end
