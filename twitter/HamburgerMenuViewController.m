//
//  MenuViewController.m
//  twitter
//
//  Created by Nhan Nguyen on 4/7/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "HamburgerMenuViewController.h"
#import "HomeViewController.h"

// how much the active view gets shifted over to reveal the menu view
static CGFloat const DefaultRevealOffsetFactor = .75f;
static CGFloat const MinTranslationToTriggerChange = 20.0f;
static CGFloat const MaxAnimationDuration = 0.5;

@interface HamburgerMenuViewController ()
@property (nonatomic, strong) UIViewController* activeViewController;
@end

@implementation HamburgerMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.activeViewController = [[HomeViewController alloc] init];
        self.menuRevealOffsetFactor = DefaultRevealOffsetFactor;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:self.activeViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panAction:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint gestureStartingLocation;
    static CGPoint activeViewStartingCenter;

    UIView *activeView = self.activeViewController.view;
    CGPoint location =  [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        gestureStartingLocation = location;
        activeViewStartingCenter = activeView.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Offset the activeView's center by the translation since the gesture started.
        // Do not move left of the parent view's (i.e. our) center.
        CGFloat deltaX = location.x - gestureStartingLocation.x;
        if (activeViewStartingCenter.x + deltaX > self.view.center.x) {
            activeView.center = CGPointMake(activeViewStartingCenter.x + deltaX, activeView.center.y);
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // If the ending velocity is in the same direction as the translation and the
        // translation was sufficiently large we change the position of the active view
        // to either reveal or hide the menu.  If either of these conditions is not met we
        // move the view back to the position it was in at the start of the gesture

        CGPoint endingCenter = activeViewStartingCenter;
        CGFloat deltaX = location.x - gestureStartingLocation.x;
        CGPoint velocity = [recognizer velocityInView:self.view];
        BOOL sameDirection = (velocity.x < 0 && deltaX < 0) || (velocity.x > 0 && deltaX > 0);
        
        if (sameDirection && ABS(deltaX) > MinTranslationToTriggerChange) {
            if (velocity.x > 0) {
                CGFloat snapCenterX = (1 + 2 * self.menuRevealOffsetFactor) * self.view.center.x;
                endingCenter = CGPointMake(snapCenterX, activeView.center.y);
            } else {
                endingCenter = CGPointMake(self.view.center.x, activeView.center.y);
            }
        }
        
        // duration = distance / speed; capped by the MaxRevealDuration
        CGFloat duration = MIN(self.view.frame.size.width / ABS(velocity.x), MaxAnimationDuration);
        [UIView animateWithDuration:duration animations:^{
            activeView.center = endingCenter;
        }];
    }
}

@end
