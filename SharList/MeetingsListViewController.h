//
//  MeetingsListViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 24/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>


//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ShareListMediaTableViewCell.h"

//Models
#import "UserTaste.h"

#import "DetailsMeetingViewController.h"

@interface MeetingsListViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate, SWTableViewCellDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
    
    NSArray *distinctDays;
    NSMutableArray *daysList;
}

@end
