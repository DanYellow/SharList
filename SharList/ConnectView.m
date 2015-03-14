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

@implementation ConnectView

@synthesize viewController = _viewController;

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
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
        
        FBLoginView *fbLoginButton = [FBLoginView new];
        fbLoginButton.delegate = self;
        fbLoginButton.frame = CGRectMake((self.center.x - (fbLoginButton.frame.size.width / 2)), screenHeight - 150, 218, 46);
        fbLoginButton.tag = 1;
        fbLoginButton.readPermissions = @[@"user_friends"];
        [self addSubview:fbLoginButton];
        
    }
    return self;
}



#pragma mark - facebook
// User is logged
- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    self.hidden = YES;
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me?fields=friends.fields(first_name,last_name)" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends;

        if ([[result objectForKey:@"data"] isEqual:[NSNull null]]) {
            friends = @[];
        } else {
            friends = [result objectForKey:@"data"];
        }

        [[NSUserDefaults standardUserDefaults] setObject:friends forKey:@"facebookFriendsList"];
    }];
}

// User quits the app
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.hidden = NO;
    [self.viewController.tabBarController setSelectedIndex:0];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUserfbID"];
}


- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // 364885553677637
    NSNumberFormatter *fbIDFormatter = [[NSNumberFormatter alloc] init];
    [fbIDFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *fbIDNumber = [fbIDFormatter numberFromString:user.objectID];
//    NSLog(@"user : %@", user);
    [[NSUserDefaults standardUserDefaults] setObject:fbIDNumber forKey:@"currentUserfbID"];
}

// Manage error for connection
- (void) loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = nil;
        alertMessage = NSLocalizedString(@"errorConnect", nil);// @"Please try again later.";
                                                               //        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
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
