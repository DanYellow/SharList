//
//  AppDelegate.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "ViewController.h"
#import "SettingsViewController.h"
#import "MeetingsListViewController.h"

#import "DetailsMeetingViewController.h"
#import "DetailsMediaViewController.h"


//Vendors
#import "NSString+SentenceCapitalizedString.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *navControllerMeetingsList;
}

@property (strong, nonatomic) UIWindow *window;


@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic) NSTimer* locationUpdateTimer;

//- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension;

@end

