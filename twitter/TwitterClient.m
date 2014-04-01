//
//  TwitterClient.m
//  twitter
//
//  Created by Nhan Nguyen on 3/31/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <NSDictionary+BDBOAuth1Manager.h>
#import "TwitterClient.h"

#pragma mark - Public Constants
NSString * const TwitterClientCallbackNotification = @"com.codepath.twitter.notification.oauth.callback";
NSString * const TwitterClientCallbackURLKey = @"com.codepath.twitter.notification.oauth.urlkey";

#pragma mark - Private Constants
static NSString * const TwitterAPIKey = @"hEiUptRBKDy2pSRN7HeQld4rp";
static NSString * const TwitterAPISecret = @"W3jy4VHSHtJfHFWolWCVJwhm6pPlGqx1WsKqDnSVKxjaDovK53";
static NSString * const CallbackURLScheme = @"codepathtwitter";
static NSString * const CallbackURLHost = @"request_token";
static NSString * const AccessTokenKey = @"com.codepath.twitter.access_token";

@interface TwitterClient ()
@property (nonatomic, strong) id applicationLaunchNotificationObserver;
@end

@implementation TwitterClient

#pragma mark - Public class methods

+ (TwitterClient *)instance {
    static dispatch_once_t once;
    static TwitterClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/"]
                                              consumerKey:TwitterAPIKey
                                           consumerSecret:TwitterAPISecret];
    });
    
    return instance;
}

#pragma mark - Public methods

- (void)loginWithSuccess:(void (^)())success failure:(void (^)(NSError* error))failure;
{
    [self removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token"
                             method:@"POST"
                        callbackURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", CallbackURLScheme, CallbackURLHost]]
                              scope:nil
                            success:^(BDBOAuthToken *requestToken) {
                                [self requestAccessTokenWithRequestToken:requestToken success:success failure:failure];
                            }
                            failure:^(NSError *error) {
                                // TODO: remove logging
                                NSLog(@"Error during request token: %@", error.localizedDescription);
                                failure(error);
                            }];
}

- (void)currentUserWithSuccess:(void (^)(User* currentUser))success failure:(void (^)(NSError *error))failure
{
    [self GET:@"1.1/account/verify_credentials.json"
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id response){
          User* currentUser = [[User alloc] initWithDictionary:response];
          success(currentUser);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          // TODO: remove logging
          NSLog(@"current user failure: %@", error);
          failure(error);
      }];
}

#pragma mark - Private methods

- (void) requestAccessTokenWithRequestToken:(BDBOAuthToken*)requestToken
                                    success:(void (^)())success
                                    failure:(void (^)(NSError* error))failure
{
    self.applicationLaunchNotificationObserver = [[NSNotificationCenter defaultCenter]
                                                  addObserverForName:TwitterClientCallbackNotification
                                                  object:nil
                                                  queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self handleApplicationCallbackWithNotification:notification success:success failure:failure];
                                                  }];
    
    NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
}

- (void) handleApplicationCallbackWithNotification:(NSNotification*)notification
                                           success:(void (^)())success
                                           failure:(void (^)(NSError* error))failure
{
    NSURL *url = [[notification userInfo] valueForKey:TwitterClientCallbackURLKey];
    if ([url.scheme isEqualToString:CallbackURLScheme] && [url.host isEqualToString:CallbackURLHost])
    {
        NSDictionary *parameters = [NSDictionary dictionaryFromQueryString:url.query];
        if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]) {
            [self fetchAccessTokenWithPath:@"/oauth/access_token"
                                    method:@"POST"
                              requestToken:[BDBOAuthToken tokenWithQueryString:url.query]
                                   success:^(BDBOAuthToken *accessToken) {
                                       [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchNotificationObserver];
                                       self.applicationLaunchNotificationObserver = nil;
                                       [self saveAccessToken:accessToken];
                                       success();
                                   }
                                   failure:^(NSError* error) {
                                       NSLog(@"Error during access token: %@", error.localizedDescription);
                                       // TODO: remove logging
                                       [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchNotificationObserver];
                                       self.applicationLaunchNotificationObserver = nil;
                                       failure(error);
                                   }];
        }
    }
}

- (BDBOAuthToken*) accessToken
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:AccessTokenKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)saveAccessToken:(BDBOAuthToken *)accessToken
{
    [self.requestSerializer saveAccessToken:accessToken];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    [userDefaults setObject:data forKey:AccessTokenKey];
    [userDefaults synchronize];
}

- (void)removeAccessToken
{
    [self.requestSerializer removeAccessToken];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:AccessTokenKey];
    [userDefaults synchronize];
}
@end
