//
//  Tweet.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
// TODO: not sure about this dependency
#import "User.h"

@interface Tweet : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) User* retweetedByUser;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, assign) BOOL retweeted;

- (instancetype) initWithDictionary:(NSDictionary*)dict;
@end
