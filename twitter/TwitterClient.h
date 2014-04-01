//
//  TwitterClient.h
//  twitter
//
//  Created by Nhan Nguyen on 3/31/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager
extern NSString * const TwitterClientCallbackNotification;
extern NSString * const TwitterClientCallbackURLKey;

+ (TwitterClient *)instance;
- (void)loginWithSuccess:(void (^)())success failure:(void (^)(NSError* error))failure;
- (void)currentUserWithSuccess:(void (^)(User* currentUser))success failure:(void (^)(NSError *error))failure;
- (void)homeTimelineWithSuccess:(void (^)(NSArray* tweets))success failure:(void (^)(NSError *error))failure;
@end
