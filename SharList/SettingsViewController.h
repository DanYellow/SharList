//
//  SettingsVieWControllerViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "AFNetworking.h"

#import "AboutViewController.h"

#import "NSString+MD5.h"
#import "UIImage+ColorImage.h"

#import "ConnectView.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

enum SettingsMenuItem : NSUInteger {
    EnabledAnonymous = 0,
    EnableGeoloc = 1,
    FBLogOut = 2,
    UnlinkBS = 3
};

@interface SettingsViewController : UIViewController <UITableViewDelegate, FBSDKLoginButtonDelegate, UITableViewDataSource,
UISearchControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, FBSDKSharingDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
}

@property (strong, nonatomic) UITableViewController *settingsTVController;
@property (strong, nonatomic) NSMutableArray *settingsItemsList;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
