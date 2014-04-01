//
//  ComposeTweetViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "ComposeTweetViewController.h"
#import "TwitterClient.h"


NSString * const NewTweetPostedNotification = @"com.codepath.twitter.new_tweet";
NSString * const NewTweetPostedNotificationKey = @"com.codepath.twitter.new_tweet.key";

@interface ComposeTweetViewController ()
@property (strong, nonatomic) NSString* initialText;
@property (strong, nonatomic) NSNumber* replyToTweetId;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property (strong, nonatomic) UIBarButtonItem *charLimitButton;
@end

@implementation ComposeTweetViewController

- (id)initWithTweetText:(NSString *)tweetText replyToTweetId:(NSNumber*)replyToTweetId
{
    self = [super init];
    if (self) {
        self.initialText = tweetText;
        self.replyToTweetId = replyToTweetId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *cancelButton= [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(cancelTweet)];
    NSString *charLimit = [NSString stringWithFormat:@"%d", (140 - self.initialText.length)];
    self.charLimitButton = [[UIBarButtonItem alloc] initWithTitle:charLimit style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *tweetButton= [[UIBarButtonItem alloc] initWithTitle:@"Tweet"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(confirmTweet)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItems = @[tweetButton, self.charLimitButton];
    
    User* currentUser = [User currentUser];
    [self.profileImage setImageWithURL:currentUser.profileImageURL];
    self.userNameLabel.text = currentUser.name;
    self.userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];

    self.tweetTextView.text = self.initialText;
    self.tweetTextView.delegate = self;
    [self.tweetTextView becomeFirstResponder];
}

// TODO: this needs to be debounced
- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger numCharacters = 140 - self.tweetTextView.text.length;
    NSString *charLimit = [NSString stringWithFormat:@"%d", numCharacters];
    self.charLimitButton.title = charLimit;
    
    CGFloat redColor = 1.0f - (MAX(0,numCharacters))/140.0f;
    CGFloat blueColor = (MAX(0,numCharacters))/140.0f;
    CGFloat greenColor = (122.0f/225.0f)*(MAX(0,numCharacters))/140.0f;
    
    self.charLimitButton.tintColor = [UIColor colorWithRed:redColor green:greenColor blue:blueColor alpha:1];
}

- (void) confirmTweet
{

    NSString* text = self.tweetTextView.text;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TwitterClient instance] postTweetWithText:text replyToTweetId:self.replyToTweetId success:^(Tweet *tweet) {
        NSDictionary* dict = @{NewTweetPostedNotificationKey: tweet};
        [[NSNotificationCenter defaultCenter] postNotificationName:NewTweetPostedNotification object:self userInfo:dict];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.delegate didTweet:tweet];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to Twitter.  Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }];
    // call api
    // notify with tweet gotten back

}

- (void) cancelTweet
{
    [self.delegate didCancelComposeTweet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
