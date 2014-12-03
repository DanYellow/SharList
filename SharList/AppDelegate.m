//
//  AppDelegate.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, retain) UITabBarController *tabBarController;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
//    [self requestForLocationTracking];

    
    ViewController *viewController = [ViewController new];
    viewController.title = [self sentenceCapitalizedString:NSLocalizedString(@"my list", nil)];
    
    MeetingsListViewController *meetingsListViewController = [MeetingsListViewController new];
    meetingsListViewController.title = [self sentenceCapitalizedString:NSLocalizedString(@"meetings", nil)];
    
    SettingsViewController *settingsViewController = [SettingsViewController new];
    settingsViewController.title = [self sentenceCapitalizedString:NSLocalizedString(@"settings", nil)];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:(18.0/255.0f) green:(33.0f/255.0f) blue:(49.0f/255.0f) alpha:.95f];
    [UITabBar appearance].tintColor = [UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:.95f];
    
    
    UINavigationController *navControllerSettings = [[UINavigationController alloc]
                                             initWithRootViewController:settingsViewController];
    navControllerSettings.navigationBar.translucent = NO; // Or else we don't have the same background as in the psd
    navControllerSettings.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UINavigationController *navControllerMeetingList = [[UINavigationController alloc]
                                                     initWithRootViewController:meetingsListViewController];
    navControllerMeetingList.navigationBar.translucent = NO; // Or else we don't have the same background as in the psd
    navControllerMeetingList.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // Contains first view of the app
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:viewController];
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navController.navigationBar.translucent = NO; // Or else we don't have the same background as in the psd
    
    CGRect bottomBorderFrame = CGRectMake(0.0f, navController.navigationBar.frame.size.height, navController.navigationBar.frame.size.width, 1.0f);
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.name = @"bottomBorderLayer";
    bottomBorder.frame = bottomBorderFrame;
    [navController.navigationBar.layer addSublayer:bottomBorder];
    
    CALayer *bottomBorder2 = [CALayer layer];
    bottomBorder2.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder2.borderWidth = 1;
    bottomBorder2.name = @"bottomBorderLayer";
    bottomBorder2.frame = bottomBorderFrame;
    [navControllerSettings.navigationBar.layer addSublayer:bottomBorder2];
    
    CALayer *bottomBorder3 = [CALayer layer];
    bottomBorder3.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder3.borderWidth = 1;
    bottomBorder3.name = @"bottomBorderLayer";
    bottomBorder3.frame = bottomBorderFrame;
    [navControllerMeetingList.navigationBar.layer addSublayer:bottomBorder3];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:1.0f]];
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"Helvetica-Light" size:19] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:1.0f] forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    
    NSArray* controllers = @[navController, navControllerMeetingList, navControllerSettings];
    
    self.tabBarController.viewControllers = controllers;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController];
    [self.window setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    [self.window makeKeyAndVisible];
    
    [application setMinimumBackgroundFetchInterval:300]; //(3600/4)
    
    // Ask for remote notification
    [self registerForRemoteNotification];
    // Reset the badge notification number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    UIAlertView * alert;
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    return YES;
}

- (NSString *) sentenceCapitalizedString:(NSString*)string {
    if (![string length]) {
        return [NSString string];
    }
    NSString *uppercase = [[string substringToIndex:1] uppercaseString];
    NSString *lowercase = [[string substringFromIndex:1] lowercaseString];
    return [uppercase stringByAppendingString:lowercase];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void  (^)(UIBackgroundFetchResult))completionHandler
{
    // If user is not connected to facebook, no bg task for him
    // and said to iOS's algorithm to "push" back manage
    if (!FBSession.activeSession.isOpen) {
//        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    MeetingsListViewController *meetingsListViewController = [MeetingsListViewController new];
    NSDate *fetchStart = [NSDate date];
    [meetingsListViewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
        
        NSDate *fetchEnd = [NSDate date];
        NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
        NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
    }];
}

- (void)registerForRemoteNotification {
    UIUserNotificationType types = UIUserNotificationTypeBadge;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}


- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension
{
    CGFloat ratio = 0;
    ratio = ((aNumber * 100)/aDimension);
    ratio = ((ratio*aDimension)/100);
    
    if ([UIScreen mainScreen].scale > 2.1) {
        
        ratio = ratio/3; // Because we are in retina HD
        
    } else {
        ratio = ratio/2; // Because we are in retina
    }
    
    return roundf(ratio);
}

@end
