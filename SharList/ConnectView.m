//
//  ConnectView.m
//  SharList
//
//  Created by Jean-Louis Danielo on 25/02/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "ConnectView.h"


#pragma mark - tag list references
// Tag list
// 1 : Facebook button for connect
// 2 : appnameLabel (UILabel)
// 3 : appMottoLabel (UILabel)
// 4 :

@implementation ConnectView

@synthesize viewController = _viewController;

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.hidden = NO;
#pragma mark - init view properties
        [self setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
        
        CAGradientLayer *gradientBGView = [CAGradientLayer layer];
        gradientBGView.frame = self.bounds;
        UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
        UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
        gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
        [self.layer insertSublayer:gradientBGView atIndex:0];
        
        CALayer *bgLayer = [CALayer layer];
        bgLayer.frame = self.bounds;
        bgLayer.opacity = .7f;
        bgLayer.name = @"TrianglesBG";
        bgLayer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"TrianglesBG"]].CGColor;
        [self.layer insertSublayer:bgLayer atIndex:1];
        
        
#pragma mark - variables init
        // Variables init
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        screenWidth = screenRect.size.width;
        screenHeight = screenRect.size.height;
        
        userPreferences = [NSUserDefaults standardUserDefaults];
        
        
        // Motto of the app
        UIView *appnameView = [[UIView alloc] initWithFrame:CGRectMake([self computeRatio:44.0 forDimension:screenWidth],
                                                                       [self computeRatio:104.0 forDimension:screenHeight],
                                                                       screenWidth, 61)];
        appnameView.tag = 1;
        appnameView.backgroundColor = [UIColor clearColor];
        appnameView.opaque = YES;
        appnameView.hidden = NO;
        [self addSubview:appnameView];
        
        UILabel *appnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        appnameLabel.text = @"Shound";
        appnameLabel.tag = 2;
        appnameLabel.font = [UIFont fontWithName:@"Helvetica" size:50.0];
        appnameLabel.textColor = [UIColor whiteColor];
        appnameLabel.textAlignment = NSTextAlignmentLeft;
        [appnameView addSubview:appnameLabel];
        
        UILabel *appMottoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 51, screenWidth, 15)];
        appMottoLabel.tag = 3;
        appMottoLabel.text = [NSLocalizedString(@"Introduce the world what you love", nil) uppercaseString];
        appMottoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
        appMottoLabel.textColor = [UIColor whiteColor];
        appMottoLabel.textAlignment = NSTextAlignmentLeft;
        [appnameView addSubview:appMottoLabel];
        
        FBSDKLoginButton *fbLoginButton = [[FBSDKLoginButton alloc] init];
        fbLoginButton.readPermissions = @[@"user_friends"];
        fbLoginButton.delegate = self;
        fbLoginButton.frame = CGRectMake((self.center.x - (fbLoginButton.frame.size.width / 2)), screenHeight - 150, 218, 46);
        fbLoginButton.center = CGPointMake(self.center.x, fbLoginButton.center.y);
        fbLoginButton.tag = 4;
        [self addSubview:fbLoginButton];
    }
    
    return self;
}

- (void) disconnectUser
{
    FBSDKLoginButton *fbLoginButton = (FBSDKLoginButton*)[self viewWithTag:4];
    [fbLoginButton sendActionsForControlEvents: UIControlEventTouchUpInside];
}

#pragma mark - facebook
// User is logged
- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error
{
    self.hidden = YES;
    
    if (error) {
        return;
    }
    
    // Is useful to not display the warning message for newcomers
    [userPreferences setObject:@1 forKey:@"warningDisconnectMessageHaveBeenDisplayV1"];
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user"];
    NSDictionary *parameters = @{@"fbiduser": [FBSDKAccessToken currentAccessToken].userID};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"foo" forHTTPHeaderField:@"X-Shound"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"responseObject: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        if ([FBSDKAccessToken currentAccessToken]) {
            [[NSUserDefaults standardUserDefaults] setObject:[FBSDKAccessToken currentAccessToken].userID forKey:@"currentUserfbID"];
            [self readyToStart];
        }
    } else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] isEqual:[NSNull null]] || [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"facebookFriendsList"];
        }
    }
}

- (void) readyToStart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mainViewIsReady" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userConnectedToFacebook" object:nil userInfo:nil];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUserfbID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUserfbImageData"];
    
    [self.viewController.tabBarController setSelectedIndex:0];
}


#pragma mark - Custom methods

- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension {
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

- (void) setViewController:(UIViewController*)anViewController
{
    _viewController = anViewController;
}

- (id) viewController
{
    return _viewController;
}


@end
