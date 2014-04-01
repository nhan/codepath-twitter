//
//  Tweet.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (instancetype) initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.tweetId = [dict[@"id"] longLongValue];
        // pull user and text from the retweet if it's a retweet
        NSDictionary* retweet = dict[@"retweeted_status"];
        if (retweet) {
            self.retweetedByUser = [[User alloc] initWithDictionary:dict[@"user"]];
            self.user = [[User alloc] initWithDictionary:retweet[@"user"]];
            self.text = retweet[@"text"];
        } else {
            self.user = [[User alloc] initWithDictionary:dict[@"user"]];
            self.text = dict[@"text"];
        }
        
        self.createdAt = [[Tweet dateFormatter] dateFromString:dict[@"created_at"]];
        self.retweetCount = [dict[@"retweet_count"] integerValue];
        self.favoriteCount = [dict[@"favorite_count"] integerValue];
        self.favorited = [dict[@"favorited"] boolValue];
        self.retweeted = [dict[@"retweeted"] boolValue];
        if ([dict[@"current_user_retweet"] isKindOfClass:[NSDictionary class]]) {
            self.myRetweetId = [(dict[@"current_user_retweet"][@"id"]) longLongValue];
        }
    }
    return self;
}

# pragma mark - private methods
+ (NSDateFormatter *)dateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter;

    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    });
    
    return dateFormatter;
}

@end
