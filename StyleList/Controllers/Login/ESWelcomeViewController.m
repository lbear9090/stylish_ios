//
//  ESWelcomeViewController.m


#import "AFNetworking.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "ProgressHUD.h"
#import "ESPageViewController.h"

#import "ESWelcomeViewController.h"
#import "ESLoginViewController.h"
#import "ESSignUpViewController.h"

@implementation ESWelcomeViewController
@synthesize loginButton,signupButton, pageController,arrPageImages,arrPageTitles;
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([PFUser currentUser]) {
        [[PFUser currentUser] fetchInBackground];
        // Present Netzwierk UI
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    }
    
    
    arrPageTitles = @[NSLocalizedString(@"To start off, complete the registration and login, then tag the styles and items that interest you.",nil),NSLocalizedString(@"Next, follow friends and others, which, matched with your already selected styles, will shape the content that will be pushed to your home screen.",nil),NSLocalizedString(@"Tagged items in a picture will highlight when pressed. You can tag your own items too. Simply draw around the items in your photo and tag them for sale, hire or just to inspire.",nil),NSLocalizedString(@"When you buy or sell items, you pay/receive money via paypal and link directly with the StyleList member to recieve/post your goods.",nil)];
    arrPageImages =@[@"flat_iphone_profile.png",@"flat_iphone_follower.png", @"flat_iphone.png", @"flat_iphone_chat.png"];
    
    // Create page view controller
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    ESPageViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    // Change the size of page view controller
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 80);
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    for (UIView *subview in self.pageController.view.subviews) {
        if ([subview isKindOfClass:[UIPageControl class]]) {
            UIPageControl *pageControl = (UIPageControl *)subview;
            pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.9 alpha:0.6];
            pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
            pageControl.backgroundColor = [UIColor clearColor];
        }
    }
    
    self.title = @"Welcome";
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.view.backgroundColor = COLOR_THEME_LOGIN;//[UIColor colorWithRed:0.3412 green:0.6902 blue:0.9294 alpha:1];
    id barButtonAppearance = [UIBarButtonItem appearance];
    NSDictionary *barButtonTextAttributes = @{
                                              UITextAttributeFont: [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15.0f],
                                              UITextAttributeTextShadowColor: [UIColor blackColor],
                                              UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]
                                              };
    
    [barButtonAppearance setTitleTextAttributes:barButtonTextAttributes
                                       forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:21]}];
    self.loginButton = [[UIButton alloc]init];
    [self.view addSubview:self.loginButton];
    
    self.signupButton = [[UIButton alloc]init];
    [self.view addSubview:self.signupButton];
    [self.signupButton setTitle:NSLocalizedString(@"Sign up", nil) forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:18];
    self.signupButton.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:18];
    self.loginButton.titleLabel.textColor = [UIColor whiteColor];
    self.signupButton.titleLabel.textColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin:) name:@"welcomeShowLogin" object:nil];
    [self.loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchDown];
    [self.signupButton addTarget:self action:@selector(actionRegister:) forControlEvents:UIControlEventTouchDown];
    
    self.loginButton.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 70, [UIScreen mainScreen].bounds.size.width/2 -30, 50);
    self.loginButton.layer.cornerRadius = 5;
    self.signupButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 10, [UIScreen mainScreen].bounds.size.height - 70, [UIScreen mainScreen].bounds.size.width/2 -30, 50);
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.backgroundColor = COLOR_GOLD;//[UIColor colorWithRed:3.0f/255.0f green:201.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    self.signupButton.titleLabel.textColor = [UIColor whiteColor];
    self.loginButton.backgroundColor = [UIColor colorWithRed:189.0f/255.0f green:195.0f/255.0f blue:199.0f/255.0f alpha:1.0f];
    self.loginButton.titleLabel.textColor = [UIColor whiteColor];
    
}
- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - User actions
- (IBAction)actionRegister:(id)sender
{
    ESSignUpViewController *registerView = [[ESSignUpViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:registerView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentModalViewController:navigation animated:YES];
    });
    
}

- (IBAction)actionLogin:(id)sender
{
    ESLoginViewController *loginView = [[ESLoginViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentModalViewController:navigation animated:YES];
    });
}
-(void)showLogin:(NSNotification *)notif {
    NSDictionary *dict = notif.userInfo;
    NSString *email = dict[@"email"];

    ESLoginViewController *loginView = [[ESLoginViewController alloc] init];
    loginView.presetMail = email;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentModalViewController:navigation animated:YES];
    });
}
#pragma mark - PageViewController data source and delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((ESPageViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((ESPageViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.arrPageTitles count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (ESPageViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (([self.arrPageTitles count] == 0) || (index >= [self.arrPageTitles count])) {
        return nil;
    }
    ESPageViewController *pageContentViewController = [[ESPageViewController alloc] initWithNibName:@"ESPageViewController" bundle:nil];
    pageContentViewController.imgFile = self.arrPageImages[index];
    pageContentViewController.txtTitle = self.arrPageTitles[index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.arrPageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
@end
