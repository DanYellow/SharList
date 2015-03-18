//
//  MeetingsListViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 24/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import <FacebookSDK/FacebookSDK.h>



//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ShareListMediaTableViewCell.h"

#import "DetailsMeetingViewController.h"

//Models
#import "UserTaste.h"

// Categories
#import "NSArray+Reverse.h"

// Views
#import "ConnectView.h"

@interface MeetingsListViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate, UpdateMeetingsListDelegate, CLLocationManagerDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
    
    NSArray *distinctDays;
    NSMutableArray *daysList;
    
    UIActivityIndicatorView *loadingIndicator;
    
    NSUInteger numberOfJSONErrors; //Contains the number of incorrect json user taste retrieve from the server
    
    NSDictionary *currentUserTaste;
}

@property (assign, nonatomic, getter=isFilterEnabled) BOOL FilterEnabled;
@property (retain, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) CLLocationManager *locationManager;


- (void) fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void) navigationItemRightButtonEnablingManagement;
- (void) noInternetAlert;
- (void) fetchUsersDatas;
- (void) reloadTableview;
- (void) manageDisplayOfFacebookFriendsButton;


@end
