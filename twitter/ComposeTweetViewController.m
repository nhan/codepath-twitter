//
//  ComposeTweetViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ComposeTweetViewController.h"

@interface ComposeTweetViewController ()
@property (strong, nonatomic) NSString* initialText;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@end

@implementation ComposeTweetViewController

- (id)initWithTweetText:(NSString *)tweetText {
    self = [super init];
    if (self) {
        self.initialText = tweetText;
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
    UIBarButtonItem *searchButton= [[UIBarButtonItem alloc] initWithTitle:@"Tweet"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(confirmTweet)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = searchButton;
    
    User* currentUser = [User currentUser];
    [self.profileImage setImageWithURL:currentUser.profileImageURL];
    self.userNameLabel.text = currentUser.name;
    self.userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];

    self.tweetTextView.text = self.initialText;
    [self.tweetTextView becomeFirstResponder];
}

- (void) confirmTweet
{
    // call api
    // notify with tweet gotten back
    [self.delegate didTweet:nil];
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
