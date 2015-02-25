//
//  SettingsVieWControllerViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>

#import "AFNetworking.h"

#import "AboutViewController.h"

#import "NSString+MD5.h"

#import "ConnectView.h"


enum SettingsMenuItem : NSUInteger {
    EnableGeoloc = 0,
    FBLogOut = 1,
    UnlinkBS = 2,
    EnabledAnonymous = 3
};

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UINavigationControllerDelegate, FBLoginViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (strong, nonatomic) UITableViewController *settingsTVController;
@property (strong, nonatomic) NSArray *settingsItemsList;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
