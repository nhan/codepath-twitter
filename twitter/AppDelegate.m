//
//  AppDelegate.m
//  twitter
//
//  Created by Nhan Nguyen on 3/31/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"
#import "TwitterClient.h"
#import "TimelineViewController.h"
#import "ProfileViewController.h"
#import "HamburgerMenuController.h"
#import "SignInViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) HamburgerMenuController* menuController;
@property (nonatomic, strong) NSArray* viewControllersInMenu;
@property (nonatomic, strong) UIViewController* homeViewController;
@property (nonatomic, strong) UIViewController* mentionsViewController;
@property (nonatomic, strong) ProfileViewController* myProfileViewController;
@property (nonatomic, strong) UIViewController* signInViewController;
@property (nonatomic, strong) UITableViewCell* signOutButton;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    self.signInViewController = [[SignInViewController alloc] init];
    UIViewController *profileVCWithNav =  [[UINavigationController alloc] initWithRootViewController:self.myProfileViewController];
    self.viewControllersInMenu = @[self.homeViewController, self.mentionsViewController, profileVCWithNav];
    self.menuController = [[HamburgerMenuController alloc] init];
    self.menuController.delegate = self;
    
    self.signOutButton = [[UITableViewCell alloc] init];
    self.signOutButton.textLabel.text = @"Sign Out";
    
    User* currentUser = [User currentUser];
    if (currentUser) {
        self.window.rootViewController = self.menuController;
    } else {
        self.window.rootViewController = self.signInViewController;
    }
    
    [self registerUserNotifications];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIViewController *)homeViewController
{
    if (!_homeViewController) {
        TimelineViewController*  homeViewController = [[TimelineViewController alloc] initWithDataLoadingBlockWithSuccessFailure:^(void (^success)(NSArray *), void (^failure)(NSError *)) {
            [[TwitterClient instance] homeTimelineWithSuccess:success failure:failure];
        }];
        homeViewController.title = @"Home";
        [[NSNotificationCenter defaultCenter] addObserverForName:NewTweetPostedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            Tweet* tweet = notification.userInfo[NewTweetPostedNotificationKey];
            [homeViewController.tweets insertObject:tweet atIndex:0];
        }];
        _homeViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    }
    
    return _homeViewController;
}

- (UIViewController *)mentionsViewController
{
    if (!_mentionsViewController) {
        TimelineViewController*  mentionsViewController = [[TimelineViewController alloc] initWithDataLoadingBlockWithSuccessFailure:^(void (^success)(NSArray *), void (^failure)(NSError *)) {
            [[TwitterClient instance] mentionsTimelineWithSuccess:success failure:failure];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:NewTweetPostedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            // refetch tweets from server here because it's hard to tell on the client side whether the tweet mentions us or not
            [mentionsViewController refetchTweetsAndShowProgressHUD];
        }];
        mentionsViewController.title = @"Mentions";
        _mentionsViewController = [[UINavigationController alloc] initWithRootViewController:mentionsViewController];
    }
    
    return _mentionsViewController;
}

- (UIViewController *)myProfileViewController
{
    if (!_myProfileViewController) {
        ProfileViewController *myProfileViewController = [[ProfileViewController alloc] initWithUser:[User currentUser]];
        myProfileViewController.title = @"My Profile";
        myProfileViewController.shouldShowMenuButton = YES;
        _myProfileViewController = myProfileViewController;
    }
    
    return _myProfileViewController;
}

- (void) registerUserNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserverForName:CurrentUserSetNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        self.myProfileViewController.user = [User currentUser];
        self.window.rootViewController = self.menuController;
    }];
    [notificationCenter addObserverForName:CurrentUserRemovedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        self.window.rootViewController = self.signInViewController;
    }];
}

- (void) signOut
{
    [User removeCurrentUser];
}

- (NSInteger)numberOfItemsInMenu:(HamburgerMenuController *)hamburgerMenuController
{
    return self.viewControllersInMenu.count + 1;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index hamburgerMenuController:(HamburgerMenuController *)hamburgerMenuController
{
    if (index < self.viewControllersInMenu.count) {
        return self.viewControllersInMenu[index];
    }
    
    return nil;
}

- (UITableViewCell *)cellForMenuItemAtIndex:(NSInteger)index hamburgerMenuController:(HamburgerMenuController *)hamburgerMenuController
{
    if (index == self.viewControllersInMenu.count) {
        return self.signOutButton;
    }
    return nil;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSNotification *notification = [NSNotification notificationWithName:TwitterClientCallbackNotification
                                                                 object:nil
                                                               userInfo:[NSDictionary dictionaryWithObject:url forKey:TwitterClientCallbackURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    return YES;
}

- (void)didSelectItemAtIndex:(NSInteger)index hamburgerMenuController:(HamburgerMenuController *)hamburgerMenuController
{
    UIViewController *selectedController = [self viewControllerAtIndex:index hamburgerMenuController:hamburgerMenuController];
    if ([selectedController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *) selectedController;
        [navController popToRootViewControllerAnimated:YES];
    } else if (index == self.viewControllersInMenu.count) {
        [hamburgerMenuController hideMenuWithDuration:hamburgerMenuController.maxAnimationDuration];
        [self signOut];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
