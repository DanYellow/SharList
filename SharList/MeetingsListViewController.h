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

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>



//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ShareListMediaTableViewCell.h"

#import "DetailsMeetingViewController.h"

//Models
#import "UserTaste.h"
#import "Discovery.h"

// Categories
#import "NSArray+Reverse.h"
#import "NSDate+CupertinoYankee.h"

// Views
#import "ConnectView.h"
#import "SHDUserDiscovered.h"

#import "SHDUserDiscoveredDatas.h"

@interface MeetingsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate, UpdateMeetingsListDelegate, CLLocationManagerDelegate, FBSDKSharingDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
        
    UIActivityIndicatorView *loadingIndicator;
        
    NSDictionary *currentUserTaste;
}

@property (assign, nonatomic, getter=isFilterEnabled) BOOL FilterEnabled;
@property (retain, nonatomic) NSMutableData *responseData;
@property (retain, atomic) NSMutableDictionary *discoveries;
@property (strong, nonatomic) NSArray *listOfDistinctsDay;
@property (strong, nonatomic) NSMutableArray *visibleCells;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) NSTimer *timerRefreshBtn;
@property (nonatomic, assign, getter=isTableViewAdded) BOOL tableViewAdded;
@property (nonatomic, assign, getter=isTableViewEndScrolling) BOOL tableViewEndScrolling;
@property (nonatomic, retain) UILabel *tableFooter;
@property (nonatomic, assign) CGPoint tableViewLastPosition; //last

//@property (strong, nonatomic) UISplitViewController *splitViewController;


- (void) fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void) navigationItemRightButtonEnablingManagement;
- (void) noInternetAlert;
- (void) fetchNewDiscovery;
- (void) reloadTableview;
- (void) manageDisplayTabFacebookContent;

+ (UIImage *) imageForCellWithName:(NSString*)imageName forDarkBG:(BOOL)isDarkBG thingsInCommon:(CGFloat)thingsInCommonCount;
+ (UIImage *) imageFromFacebookFriendInitialForId:(NSString*)fbId forDarkBG:(BOOL)isDarkBG;


@end
