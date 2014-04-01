//
//  User.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "User.h"

#pragma mark - public constants
NSString * const CurrentUserSetNotification = @"com.codepath.twitter.notification.current_user.set";
NSString * const CurrentUserRemovedNotification = @"com.codepath.twitter.notification.current_user.removed";

#pragma mark - private constants
static NSString * const CurrentUserKey = @"com.codepath.twitter.current_user";

@implementation User
static User* _currentUser = nil;

- (instancetype) initWithDictionary:(NSDictionary*) dict
{
    self = [super init];
    if (self) {
        self.id = [dict[@"id"] integerValue];
        self.name = dict[@"name"];
        self.screenName = dict[@"screen_name"];
        self.profileImageURL = [NSURL URLWithString:dict[@"profile_image_url"]];
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.id forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.screenName forKey:@"screenName"];
    [encoder encodeObject:self.profileImageURL forKey:@"profileImageURL"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.id = [decoder decodeIntegerForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.screenName = [decoder decodeObjectForKey:@"screenName"];
        self.profileImageURL = [decoder decodeObjectForKey:@"profileImageURL"];
    }
    return self;
}

#pragma mark - Class methods
+ (User *)currentUser
{
    // try to load from user defaults if in-memory value is nil
    if (!_currentUser) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [userDefaults objectForKey:CurrentUserKey];
        if (data) {
            User* currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            _currentUser = currentUser;
        }
    }
    return _currentUser;
}

+ (void) setCurrentUser:(User *)user
{
    if (!_currentUser && user) { // save to user defaults as well as in-memory value
        _currentUser = user;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:user];
        [userDefaults setObject:data forKey:CurrentUserKey];
        [userDefaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:CurrentUserSetNotification object:user];
    } else { // setting to nil is the same as removing
        [self removeCurrentUser];
    }
}

+ (void) removeCurrentUser
{
    _currentUser = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CurrentUserKey];
    [userDefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentUserRemovedNotification object:nil];
}
@end
