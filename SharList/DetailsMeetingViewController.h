//
//  DetailsMeetingViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 26/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>

#import "ShareListMediaTableViewCell.h"
#import "DetailsMediaViewController.h"


@interface DetailsMeetingViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
}


@property (nonatomic, strong) id meetingDatas;


@end