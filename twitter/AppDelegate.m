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
#import "HomeViewController.h"
#import "HamburgerMenuController.h"
#import "SignInViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) HamburgerMenuController* menuController;
@property (nonatomic, strong) UIViewController* homeViewController;
@property (nonatomic, strong) UIViewController* signInViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // TODO: ADD SIGNOUT BUTTON IN MENU
    self.homeViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
    self.signInViewController = [[SignInViewController alloc] init];
    self.menuController = [[HamburgerMenuController alloc] init];
    self.menuController.delegate = self;
    
    User* currentUser = [User currentUser];
    if (currentUser) {
        self.window.rootViewController = self.menuController;
    } else {
        self.window.rootViewController = self.signInViewController;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserverForName:CurrentUserSetNotification
                                    object:nil
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *notification) {
                                    self.window.rootViewController = self.homeViewController;
                                }];
    [notificationCenter addObserverForName:CurrentUserRemovedNotification
                                    object:nil
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *notification) {
                                    self.window.rootViewController = self.signInViewController;
                                }];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSInteger)numberOfItemsInMenu:(HamburgerMenuController *)hamburgerMenuController
{
    return 1;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index hamburgerMenuController:(HamburgerMenuController *)hamburgerMenuController
{
    return self.homeViewController;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSNotification *notification = [NSNotification notificationWithName:TwitterClientCallbackNotification
                                                                 object:nil
                                                               userInfo:[NSDictionary dictionaryWithObject:url forKey:TwitterClientCallbackURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    return YES;
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
