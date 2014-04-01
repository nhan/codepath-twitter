//
//  User.h
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CurrentUserSetNotification;
extern NSString * const CurrentUserRemovedNotification;

@interface User : NSObject<NSCoding>
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSURL *profileImageURL;
- (instancetype)initWithDictionary:(NSDictionary*) dict;
+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;
+ (void)removeCurrentUser;
@end
