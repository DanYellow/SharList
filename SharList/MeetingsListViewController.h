//
//  MeetingsListViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 24/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

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

@interface MeetingsListViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate, UpdateMeetingsListDelegate, CLLocationManagerDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
    
    NSArray *distinctDays;
    NSMutableArray *daysList;
    
    UIActivityIndicatorView *loadingIndicator;
}

@property (assign, nonatomic, getter=isFilterEnabled) BOOL FilterEnabled;
@property (retain, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void) fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
/*
 *  headingAvailable
 *
 *  Discussion:
 *      Returns YES if the device supports the heading service, otherwise NO.
 */
- (void) navigationItemRigthButtonEnablingManagement;


@end
