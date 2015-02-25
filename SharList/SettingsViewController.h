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
    EnabledAnonymous = 0,
    EnableGeoloc = 1,
    FBLogOut = 2,
    UnlinkBS = 3
};

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UINavigationControllerDelegate, FBLoginViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
}

@property (strong, nonatomic) UITableViewController *settingsTVController;
@property (strong, nonatomic) NSMutableArray *settingsItemsList;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
