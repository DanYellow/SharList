//
//  AppDelegate.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>


#import "ViewController.h"
#import "SettingsViewController.h"
#import "MeetingsListViewController.h"

//Vendors
#import "LocationTracker.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property LocationTracker *locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;

- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension;

@end

