//
//  SettingsVieWControllerViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "DetailsMediaViewController.h"

#import "ViewController.h"

#import "AboutViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UINavigationControllerDelegate, FBLoginViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (strong, nonatomic) UITableViewController *settingsTVController;
@property (strong, nonatomic) NSArray *settingsItemsList;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
