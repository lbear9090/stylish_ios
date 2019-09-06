//
//  AppDelegate.m



#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PayPalMobile.h"


#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPHONE6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)


@interface AppDelegate() {
    
}
@property (nonatomic, strong) ESHomeViewController *homeViewController;
@property (nonatomic, strong) ESActivityFeedViewController *activityViewController;
@property (nonatomic, strong) ESWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) ESAccountViewController *accountViewController;
@property (nonatomic, strong) ESConversationViewController *messengerViewController;
@property (nonatomic, strong) UIViewController *mystyleViewController;

@end


@implementation AppDelegate
@synthesize cameraButton;
#pragma mark - UIApplicationDelegate
- (void)crash {
    [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // ****************************************************************************
    // Parse initialization
    /* IF YOU DON'T WANT TO MIGRATE OVER TO BACK4APP, COMMENT OUT THE FOLLOWING PARSE INITIALIZATION AND EXCHANGE IT WITH THE FOLLOWING LINE:
     [Parse setApplicationId:@"APP_ID" clientKey:@"CLIENT_KEY"];
     */
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"JRVwfK7NC0xSWeGOVgEtyP7aJSa1LRXVY6Nejf1T";
        configuration.clientKey = @"8rq09cq9ZlRQD6Pza0ZwvDpPWlO8rUVOEJvY8FHm";
        
        //-- Original Source Key
        //configuration.applicationId = @"SuTEpQpBFjtxJ3Fofagk1Cwr5wCZ7zsWxE2cL95H";
        //configuration.clientKey = @"QMQVhOLwegVFMGWVF12sLRIinZ9QP0fSy0E4nFOH";
        configuration.server = @"https://parseapi.back4app.com";
    }]];
    // ****************************************************************************
    [FIRApp configure];
    // Track app open.
    [FIRDatabase database].persistenceEnabled = NO;
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Initialize Google Mobile Ads SDK
    // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-7420203704910557~9731789794"]; //Put your ID here!
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
#ifdef __IPHONE_8_0
    
    if(IS_OS_8_OR_LATER) {
        //Right, that is the point
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"pushnotifications"]){
            if ([defaults boolForKey:@"pushnotifications"] == NO ) {
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }
        }
    }
#endif
    
    if(IS_OS_8_OR_LATER) {
        //Right, that is the point, no need to do anything here
        
    }
    else {
        //register to receive notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    self.welcomeViewController = [[ESWelcomeViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self handlePush:launchOptions];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [[PFUser currentUser] setObject:language forKey:@"language"];
    [[PFUser currentUser] saveEventually];
    
    [self.window makeKeyAndVisible];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    imageView.image = [UIImage imageNamed:@"BackgroundLeather"];
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbAccessTokenDidChange:) name:FBSDKAccessTokenDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestFacebookUserInfo)
                                                 name:@"CheckFBToken"
                                               object:nil];
    //paypal initialize client id .
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"AdQtNOnu_HzWO7JOrSkq6zNHtoDUKiKFKvURTds7VoxjdL6xz1N9s6VqPxrBzozpJ8FzN7Ui55vGUkGz", PayPalEnvironmentSandbox : @"AXl9471gHK4jap0ey4Qd99b0w90vKU9MTCYGpyhOQGrmf0BlqrzZoyTytmbNT8pZ9rcGGDoSGlZ7VtYK"}];
    //selected user gender and logined user name.
//    [self getCurrentUserGender];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    // Add any custom logic here.
    return handled;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:ESAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    NSString *remoteNotificationPayload = [userInfo objectForKey:kESPushPayloadPayloadTypeKey];
    if ([PFUser currentUser]) {
        if ([remoteNotificationPayload isEqualToString:@"m"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage" object:nil userInfo:nil];
            /*
             NSString *currentBadgeValue = tabBarItem.badgeValue;
             UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:ESChatTabBarItemIndex] tabBarItem];
             
             
             if (currentBadgeValue && currentBadgeValue.length > 0) {
             NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
             NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
             NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
             tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
             } else {
             tabBarItem.badgeValue = @"1";
             }*/
            
        }
        else if ([self.tabBarController viewControllers].count > ESActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:ESActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
    
    [FBSDKAppEvents activateApp];
    if ([PFUser currentUser]) {
        if (![[[PFUser currentUser] objectForKey:@"acceptedTerms"] isEqualToString:@"Yes"]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Terms of Use", nil) message:NSLocalizedString(@"Please accept the terms of use before using this app",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I accept", nil), NSLocalizedString(@"Show terms", nil), nil];
            [alert show];
            alert.tag = 99;
            
        }
    }
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[ESEmptyTabBarItemIndex]];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (![[PFUser currentUser] objectForKey:@"uploadedProfilePicture"]) {
        [ESUtility processProfilePictureData:_data];
    }
    else {
        //nothing to do here, actually
    }
}

//- (BOOL)restoreAuthenticationWithAuthData:(nullable NSDictionary<NSString *, NSString *> *)authData {
//    FBSDKAccessToken *token = [PFFacebookPrivateUtilities facebookAccessTokenFromUserAuthenticationData:authData];
//    if (!token) {
//        return !authData; // Only deauthenticate if authData was nil, otherwise - return failure (`NO`).
//    }
//    
//    FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
//    // Do not reset the current token if we have the same token already set.
//    if ([currentToken.userID isEqualToString:token.userID] &&
//        [currentToken.tokenString isEqualToString:token.tokenString]) {
//        [FBSDKAccessToken setCurrentAccessToken:token];
//    }
//    
//    return YES;
//}

#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}
- (void)presentTabBarController {
    
    self.tabBarController = [[ESTabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.homeViewController = [[ESHomeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[ESActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.accountViewController.user = [PFUser currentUser];
    self.messengerViewController = [[ESConversationViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mystyleViewController = [sb instantiateViewControllerWithIdentifier:@"EditStyleVC"];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *accountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.accountViewController];
    UINavigationController *chatNavigationController = [[UINavigationController alloc] initWithRootViewController:self.messengerViewController];
    UINavigationController *mystyleNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mystyleViewController];
    
    UIImage *image1 = [[UIImage alloc]init];
    image1 = [self imageNamed:@"IconHome" withColor:COLOR_THEME];//[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1]];
    
    UIGraphicsBeginImageContext(self.window.frame.size);
    UIImage *homeImage1 = [UIImage imageNamed:@"IconHome"];
    UIImage *homeImage2 = [UIImage imageNamed:@"IconHomeSelected"];
    UIGraphicsEndImageContext();
    
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:/*NSLocalizedString(@"Home", nil)*/@"" image:[homeImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[homeImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: COLOR_THEME } forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: COLOR_GOLD} forState:UIControlStateSelected];//[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1] } forState:UIControlStateSelected];
    
    UIImage *activityImage1 = [UIImage imageNamed:@"IconActivity"];
    UIImage *activityImage2 = [UIImage imageNamed:@"IconActivitySelected"];
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:/*NSLocalizedString(@"Activity", nil)*/@"" image:[activityImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[activityImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_THEME } forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_GOLD} forState:UIControlStateSelected];//[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1] } forState:UIControlStateSelected];
    
    UIImage *profileImage1 = [UIImage imageNamed:@"IconProfile"];
    UIImage *profileImage2 = [UIImage imageNamed:@"IconProfileSelected"];
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:/*NSLocalizedString(@"Profile", nil)*/@"" image:[profileImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[profileImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [profileTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_THEME } forState:UIControlStateNormal];
    [profileTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_GOLD} forState:UIControlStateSelected];//[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1] } forState:UIControlStateSelected];
    
    UIImage *mystyleImage1 = [UIImage imageNamed:@"IconMystyle"];
    UIImage *mystyleImage2 = [UIImage imageNamed:@"IconMystyleSelected"];
    UITabBarItem *mystyleTabBarItem = [[UITabBarItem alloc] initWithTitle:/*NSLocalizedString(@"My Style", nil)*/@"" image:[mystyleImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[mystyleImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [mystyleTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_THEME } forState:UIControlStateNormal];
    [mystyleTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_GOLD} forState:UIControlStateSelected];
    
    UIImage *chatImage1 = [UIImage imageNamed:@"IconChat"];
    UIImage *chatImage2 = [UIImage imageNamed:@"IconChatSelected"];
    UITabBarItem *chatTabBarItem = [[UITabBarItem alloc] initWithTitle:/*NSLocalizedString(@"Chat", nil)*/@"" image:[chatImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[chatImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [chatTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_THEME } forState:UIControlStateNormal];
    [chatTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: COLOR_GOLD} forState:UIControlStateSelected];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [accountNavigationController setTabBarItem:profileTabBarItem];
    [mystyleNavigationController setTabBarItem:mystyleTabBarItem];
    [chatNavigationController setTabBarItem:chatTabBarItem];
    
    [[UITabBar appearance] setTranslucent:YES];
    
    UIViewController * leftDrawer = [[SideViewController alloc] init];
    
    /*CGRect tabbarFrame = self.tabBarController.tabBar.frame;
    tabbarFrame.size.height += 20;
    self.tabBarController.tabBar.frame = tabbarFrame;*/
    
    [self.tabBarController.tabBar setClipsToBounds:YES];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, accountNavigationController, emptyNavigationController, chatNavigationController, activityFeedNavigationController];
    //self.tabBarController.viewControllers = @[ homeNavigationController, mystyleNavigationController, emptyNavigationController, chatNavigationController, activityFeedNavigationController];
    
    self.container = [MFSideMenuContainerViewController
                      containerWithCenterViewController:self.tabBarController
                      leftMenuViewController:leftDrawer
                      rightMenuViewController:nil];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.container ] animated:NO];
    
}

- (void)logOut {
    // clear cache
    [[ESCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kESUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kESUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kESInstallationUserKey];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [ProgressHUD dismiss];
    self.homeViewController = nil;
    self.activityViewController = nil;
}

#pragma mark - location methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.coordinate = newLocation.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

#pragma mark - manager methods

- (void)refreshESConversationViewController {
    [self.messengerViewController loadChatRooms];
}
- (void)locationManagerStart {
    
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManagerStop {
    
    [self.locationManager stopUpdatingLocation];
}
#pragma mark - ()

// Set up appearance parameters to achieve Netzwierk's custom look and feel
- (void)setupAppearance {
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    [[UINavigationBar appearance] setTintColor:COLOR_NAVTITLE];
    [UINavigationBar appearance].translucent = YES;
    [[UINavigationBar appearance] setBarTintColor:COLOR_NAVBACK];
    
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
    
    UIColor *color = COLOR_THEME;//[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1];
    if (IS_IPHONE6) {
        cameraButton = [[UIImageView alloc]initWithImage:[self imageFromColor:color forSize:CGSizeMake(75, 49) withCornerRadius:0]];
        cameraButton.frame = CGRectMake( 300.0f, 0.0f, 75.0f, 49);
        //cameraButton.frame = CGRectMake( 150.0f, 0.0f, 75.0f, 49); //For middle position
    }
    else {
        cameraButton = [[UIImageView alloc]initWithImage:[self imageFromColor:color forSize:CGSizeMake(64, 49) withCornerRadius:0]];
        cameraButton.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width - 64, 0.0f, 64.0f, 49);
    }
    cameraButton.tag = 1;
    //[[UITabBar appearance] insertSubview:cameraButton atIndex:1];
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    NSDictionary * navBarTitleTextAttributes =
    @{ NSForegroundColorAttributeName : COLOR_NAVTITLE,
       NSShadowAttributeName          : shadow,
       NSFontAttributeName            : [UIFont fontWithName:@"Helvetica Neue" size:18] };
    
    [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleTextAttributes];
    
    /*UIImageView *imgLine = [[UIImageView alloc] initWithImage:[self imageFromColor:COLOR_GOLD forSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1) withCornerRadius:0]];
    imgLine.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1);
    [[UITabBar appearance] insertSubview:imgLine atIndex:1];
    
    UIImageView *imgLine1 = [[UIImageView alloc] initWithImage:[self imageFromColor:COLOR_GOLD forSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1) withCornerRadius:0]];
    imgLine1.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1);
    [[UINavigationBar appearance] insertSubview:imgLine1 atIndex:1];*/
    
    
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"https://parseapi.back4app.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ESAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kESPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kESPhotoClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kESPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[ESHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kESLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kESPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:ESHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            ESPhotoDetailsViewController *detailViewController = [[ESPhotoDetailsViewController alloc] initWithPhoto:object andTextPost:@"NO"];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}
- (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.02, 0.0)
                               green:MAX(g - 0.02, 0.0)
                                blue:MAX(b - 0.02, 0.0)
                               alpha:a];
    return nil;
}

- (void) wouldYouPleaseChangeTheDesign: (UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
    [[PFUser currentUser] setObject:colorAsString forKey:@"profileColor"];
    [[PFUser currentUser] saveEventually];
    
}
- (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    // load the image
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex == 0) {
            PFUser *user= [PFUser currentUser];
            [user setObject:@"Yes" forKey:@"acceptedTerms"];
            [user saveInBackground];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        else [[UIApplication sharedApplication] openURL:[NSURL URLWithString: TERMS_URL]];//Your link here
    }
    
}

# pragma mark - Facebook acess token

- (void)fbAccessTokenDidChange:(NSNotification*)notification
{
    if ([notification.name isEqualToString:FBSDKAccessTokenDidChangeNotification]) {
        
        FBSDKAccessToken* oldToken = [notification.userInfo valueForKey: FBSDKAccessTokenChangeOldKey];
        FBSDKAccessToken* newToken = [notification.userInfo valueForKey: FBSDKAccessTokenChangeNewKey];
        
        NSLog(@"FB access token did change notification\nOLD token:\t%@\nNEW token:\t%@", oldToken.tokenString, newToken.tokenString);
        
        // initial token setup when user is logged in
        if (newToken != nil && oldToken == nil) {
            
            // check the expiration data
            
            // IF token is not expired
            // THEN log user out
            // ELSE sync token with the server
            
            NSDate *nowDate = [NSDate date];
            NSDate *fbExpirationDate = [FBSDKAccessToken currentAccessToken].expirationDate;
            if ([fbExpirationDate compare:nowDate] != NSOrderedDescending) {
                NSLog(@"FB token: expired");
                
                // this means user launched the app after 60+ days of inactivity,
                // in this case FB SDK cannot refresh token automatically, so
                // you have to walk user thought the initial log in with FB flow
                
                // for the sake of simplicity, just logging user out from Facebook here
                [self logoutFacebook];
            }
            else {
                [self syncFacebookAccessTokenWithServer];
            }
        }
        
        // change in token string
        else if (newToken != nil && oldToken != nil
                 && ![oldToken.tokenString isEqualToString:newToken.tokenString]) {
            NSLog(@"FB access token string did change");
            
            [self syncFacebookAccessTokenWithServer];
        }
        
        // moving from "logged in" state to "logged out" state
        // e.g. user canceled FB re-login flow
        else if (newToken == nil && oldToken != nil) {
            NSLog(@"FB access token string did become nil");
        }
        
        // upon token did change event we attempting to get FB profile info via current token (if exists)
        // this gives us an ability to check via OG API that the current token is valid
        [self requestFacebookUserInfo];
    }
}

- (void)logoutFacebook
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[FBSDKLoginManager new] logOut];
    }
}

- (void)syncFacebookAccessTokenWithServer
{
    if (![FBSDKAccessToken currentAccessToken]) {
        // returns if empty token
        return;
    }
    
    // BOOL isAlreadySynced = ...
    // if (!isAlreadySynced) {
    // call an API to sync FB access token with the server
    // }
}

- (void)requestFacebookUserInfo
{
    if (![FBSDKAccessToken currentAccessToken]) {
        // returns if empty token
        return;
    }
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSDictionary* user = (NSDictionary *)result;
        if (!error) {
            // process profile info if needed
        }
        else {
            // First time an error occurs, FB SDK will attemt to recover from it automatically
            // via FBSDKGraphErrorRecoveryProcessor (see documentation)
            
            // you can process an error manually, if you wish, by setting
            // -setGraphErrorRecoveryDisabled to YES
            
            NSInteger statusCode = [(NSString *)error.userInfo[FBSDKGraphRequestErrorHTTPStatusCodeKey] integerValue];
            if (statusCode == 400) {
                // access denied
            }
        }
    }];
}

#pragma get current user gender
- (void)getCurrentUserGender{
    PFUser *currentUser =[PFUser currentUser];
    NSString *loginedUserId = [currentUser valueForKey:@"objectId"];
    PFQuery *query = [PFQuery queryWithClassName:@"SensitiveData"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        if (!error) {
            NSString *strCurrentUserGender = [result objectForKey:@"Gender"];
            ESCache *shared = [ESCache sharedCache];
            shared.selectedUserGender = strCurrentUserGender;
            shared.loginedUserId = loginedUserId;
        } else {
           
        }
    }];
}

@end

