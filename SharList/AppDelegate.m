//
//  AppDelegate.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>

@interface AppDelegate ()

@property (nonatomic, retain) UITabBarController *tabBarController;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // APNS + Parse part
    [Parse setApplicationId:@"9dyEc6hGOZDs4dadLx5JkeC0iH8RXkThDFX1oUOb"
                  clientKey:@"McposK2Wpv2TEZcGPECYiRA9bOsJFAXIEDtisKSd"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (![[currentInstallation objectForKey:@"channels"] containsObject:@"appInfos"]) {
        [PFPush subscribeToChannelInBackground:@"appInfos"];
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    [application setMinimumBackgroundFetchInterval:BGFETCHDELAY];

    
    ViewController *viewController = [ViewController new];
    viewController.title = [NSString sentenceCapitalizedString:NSLocalizedString(@"my list", nil)];
    viewController.tabBarItem.image = [UIImage imageNamed:@"liste-tab-icon"];
    
    MeetingsListViewController *meetingsListViewController = [MeetingsListViewController new];
    meetingsListViewController.title = [NSString sentenceCapitalizedString:NSLocalizedString(@"meetings", nil)];
    meetingsListViewController.tabBarItem.image = [UIImage imageNamed:@"list-tab-icon2"];
    
    SettingsViewController *settingsViewController = [SettingsViewController new];
    settingsViewController.title = [NSString sentenceCapitalizedString:NSLocalizedString(@"settings", nil)];
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"settings-tab-icon"];
    
    self.tabBarController = [UITabBarController new];
    
    
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f];
    [UITabBar appearance].tintColor = [UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:1.0f];
    
    
    UINavigationController *navControllerSettings = [[UINavigationController alloc]
                                             initWithRootViewController:settingsViewController];
    navControllerSettings.navigationBar.translucent = NO; // Or else we don't have the same background as in the psd
    navControllerSettings.navigationBar.barStyle = UIBarStyleBlack;
    
    navControllerMeetingsList = [[UINavigationController alloc]
                                                     initWithRootViewController:meetingsListViewController];
    navControllerMeetingsList.navigationBar.translucent = NO; // Or else we don't have the same background as in the psd
    navControllerMeetingsList.navigationBar.barStyle = UIBarStyleBlack;
    
    
    // Contains first view of the app
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:viewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
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
    [navControllerMeetingsList.navigationBar.layer addSublayer:bottomBorder3];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:1.0f]];
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"Helvetica-Light" size:19] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:1.0f] forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    
    NSArray* controllers = @[navControllerMeetingsList, navController, navControllerSettings];
    
    self.tabBarController.viewControllers = controllers;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController]; //connectViewController
    [self.window setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    [self.window makeKeyAndVisible];
    
    // Ask for remote notification
    [self registerForRemoteNotification];
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void  (^)(UIBackgroundFetchResult))completionHandler
{
    // If user is not connected to facebook, no bg task for him
    // and said to iOS's algorithm to "push" back manage
    
    if (![FBSDKAccessToken currentAccessToken]) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    MeetingsListViewController *meetingsListViewController = [MeetingsListViewController new];
    [meetingsListViewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
}

- (void)registerForRemoteNotification {
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif


#pragma mark - Parse + APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
//    [PFPush subscribeToChannelInBackground:@"foo"];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState != UIApplicationStateActive) {
        [PFPush handlePush:userInfo];
//        PFInstallation *currentInstallation = [PFInstallation currentInstallation];

        
        NSMutableSet *favsUserUpdatedMSet = [[NSMutableSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"]];
        [favsUserUpdatedMSet addObject:userInfo[@"userfbid"]];
        [[NSUserDefaults standardUserDefaults] setObject:[favsUserUpdatedMSet allObjects] forKey:@"favsIDUpdatedList"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didReceiveRemoteNotification"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationFavorite" object:nil userInfo:userInfo];
    } else {
//        NSLog(@"didReceiveRemoteNotification active");
    }
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"locatificationName"] isEqualToString:@"discoverNew"]) {
        // User doesn't discover thing for a longtime
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
        self.tabBarController.selectedIndex = 0;
        
        MeetingsListViewController *meetingsListViewController = [MeetingsListViewController new];
        [meetingsListViewController fetchUsersDatas];
    } else if ([[[notification userInfo] objectForKey:@"locatificationName"] isEqualToString:@"updateList"]) {
        // User doesn't change his list for a longtime
        self.tabBarController.selectedIndex = 1;
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // Notify all listener that application have been put in background
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didEnterBackground" object:nil userInfo:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Notify all listener that application have been put in foreground
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterForeground" object:nil userInfo:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"didReceiveRemoteNotification"]) {
        MeetingsListViewController *meetingsListViewController = [MeetingsListViewController new];
        [meetingsListViewController reloadTableview];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"didReceiveRemoteNotification"];
    }
    
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [navControllerMeetingsList tabBarItem].badgeValue = [NSString stringWithFormat: @"%ld", (long)[[UIApplication sharedApplication] applicationIconBadgeNumber]];
    }
    

    if ([FBSDKAccessToken currentAccessToken] && [AFNetworkReachabilityManager sharedManager].isReachable) {
//        FBSDKGraphRequest* friendsRequest = [FBSDKGraphRequest requestForMyFriends];
//        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                      NSDictionary* result,
//                                                      NSError *error) {
//            if (!error) {
//                NSArray* friends;
//                
//                if ([[result objectForKey:@"data"] isEqual:[NSNull null]]) {
//                    friends = @[];
//                } else {
//                    friends = [result objectForKey:@"data"];
//                }
//                
//                [[NSUserDefaults standardUserDefaults] setObject:friends forKey:@"facebookFriendsList"];
//            } else {
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] isEqual:[NSNull null]] || [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] == nil) {
//                    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"facebookFriendsList"];
//                }
//            }
//        }];
    } else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] isEqual:[NSNull null]] || [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"facebookFriendsList"];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    application.applicationIconBadgeNumber = 0;
    [currentInstallation saveEventually];
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
//    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

//
//- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension
//{
//    CGFloat ratio = 0;
//    ratio = ((aNumber * 100)/aDimension);
//    ratio = ((ratio*aDimension)/100);
//    
//    if ([UIScreen mainScreen].scale > 2.1) {
//        
//        ratio = ratio/3; // Because we are in retina HD
//        
//    } else {
//        ratio = ratio/2; // Because we are in retina
//    }
//    
//    return roundf(ratio);
//}

@end
