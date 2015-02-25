//
//  ConnectView.m
//  SharList
//
//  Created by Jean-Louis Danielo on 25/02/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "ConnectView.h"

@implementation ConnectView

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
        if (!FBSession.activeSession.isOpen || ![userPreferences objectForKey:@"currentUserfbID"]) {
            [self.layer insertSublayer:bgLayer atIndex:1];
        }
        
        
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
        appnameView.tag = 2;
        appnameView.backgroundColor = [UIColor clearColor];
        appnameView.opaque = YES;
        appnameView.hidden = NO;
        [self addSubview:appnameView];
        
        UILabel *appnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        appnameLabel.text = @"Shound";
        appnameLabel.font = [UIFont fontWithName:@"Helvetica" size:50.0];
        appnameLabel.textColor = [UIColor whiteColor];
        appnameLabel.textAlignment = NSTextAlignmentLeft;
        [appnameView addSubview:appnameLabel];
        
        UILabel *appMottoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 51, screenWidth, 15)];
        appMottoLabel.text = [NSLocalizedString(@"Introduce the world what you love", nil) uppercaseString];
        appMottoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
        appMottoLabel.textColor = [UIColor whiteColor];
        appMottoLabel.textAlignment = NSTextAlignmentLeft;
        [appnameView addSubview:appMottoLabel];
        
        FBLoginView *fbLoginButton = [FBLoginView new];
        fbLoginButton.delegate = self;
        fbLoginButton.frame = CGRectMake((self.center.x - (fbLoginButton.frame.size.width / 2)), screenHeight - 150, 218, 46);
        fbLoginButton.tag = 1;
        [self addSubview:fbLoginButton];
    }
    return self;
}

#pragma mark - faceook
// User is logged
- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUserfbID"];
    self.hidden = YES;
}

// User quits the app
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    UITabBarController *tabBarController = [UITabBarController new];
    [tabBarController setSelectedIndex:0];
    self.hidden = NO;
}

- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"user : %@", user);
    NSNumberFormatter *fbIDFormatter = [[NSNumberFormatter alloc] init];
    [fbIDFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *fbIDNumber = [fbIDFormatter numberFromString:user.objectID];
    
    [[NSUserDefaults standardUserDefaults] setObject:fbIDNumber forKey:@"currentUserfbID"];
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


@end
