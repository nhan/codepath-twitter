//
//  SignInViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/1/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <MBProgressHUD.h>
#import "SignInViewController.h"
#import "TwitterClient.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender
{
    [[TwitterClient instance]
     loginWithSuccess:^{
         [self fetchAndSaveCurrentUser];
     }
     failure:^(NSError* error) {
         [self errorDuringSignIn:error];
     }];
}

# pragma mark - Private methods
// assumes user has signed in
- (void) fetchAndSaveCurrentUser
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TwitterClient instance] currentUserWithSuccess:^(User *currentUser) {
        [User setCurrentUser:currentUser];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self errorDuringSignIn:error];
    }];
}

- (void) errorDuringSignIn:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign in to Twitter.  Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}
@end
