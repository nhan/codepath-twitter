//
//  TweetCell.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <NSDate+DateTools.h>
#import "TweetCell.h"

@interface TweetCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetIndicatorTopOfCellSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetIndicatorHeight;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@end

@implementation TweetCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)replyButtonAction:(id)sender {
    [self.delegate replyAction:self.tweet];
}
- (IBAction)retweetButtonAction:(id)sender {
    [self.delegate retweetAction:self.tweet];
    [self refreshView];
}

- (IBAction)favoriteButtonAction:(id)sender {
    [self.delegate favoriteAction:self.tweet];
    [self refreshView];
}

- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    [self refreshView];
}


- (void) refreshView
{
    Tweet* tweet = self.tweet;
    if (tweet.retweetedByUser)
    {
        self.retweetLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweetedByUser.name];
        self.retweetIndicatorTopOfCellSpacing.constant = 5.0f;
        self.retweetIndicatorHeight.constant = 16.0f;
    } else {
        self.retweetIndicatorTopOfCellSpacing.constant = 0.0f;
        self.retweetIndicatorHeight.constant = 0.0f;
    }
    
    [self.profileImageView setImageWithURL:tweet.user.profileImageURL];
    self.nameLabel.text = tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.createdAtLabel.text = tweet.createdAt.shortTimeAgoSinceNow;
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

- (CGFloat) estimateHeight:(Tweet *)tweet
{
    CGFloat ret = 0.0f;
    ret += 5; // top padding
    
    if (tweet.retweetedByUser) { // retweet indicator
        ret += 21;
    }
    
    ret += 15; // name line
    ret += 5; // padding
    
    // tweet text label
    CGSize maximumTextLabelSize = CGSizeMake(self.tweetTextLabel.frame.size.width, MAXFLOAT);
    CGRect nameRect = [tweet.text boundingRectWithSize:maximumTextLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.tweetTextLabel.font} context:nil];
    ret += nameRect.size.height;
    
    ret += 8; // padding
    ret += 16; // button row
    ret += 5; // bottom padding;
    
    return ret;
}
@end
