//
//  AppDelegate.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<SWRevealViewControllerDelegate>

@property (nonatomic, retain) UITabBarController *tabBarController;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MagicalRecord setupAutoMigratingCoreDataStack];

    self.tabBarController = [[UITabBarController alloc] init];
    
    ViewController *viewController = [[ViewController alloc] init];
    viewController.title = @"Ma liste";
    
    SettingsViewControllerViewController *settingsViewController = [[SettingsViewControllerViewController alloc] init];
    settingsViewController.title = @"Paramètres";
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    [navigationController setViewControllers:@[viewController]];
    
//     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    UIColor *firstColor = [UIColor colorWithRed:203.0f/255.0f green:217.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:217.0f/255.0f green:231.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
//    [frontNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefaultPrompt];
     navigationController.navigationBar.shadowImage = [UIImage new];
    
    NSArray *colors = [NSArray arrayWithObjects:firstColor, secondColor, nil];
    // or NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xf16149).CGColor, (id)UIColorFromRGB(0xf14959).CGColor, nil];
    
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [navigationController.navigationBar setTranslucent:NO]; // Remember, the default value is YES.
    
    
    self.tabBarController.viewControllers = @[navigationController, settingsViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

@end
