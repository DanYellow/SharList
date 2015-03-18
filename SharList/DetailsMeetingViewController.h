//
//  DetailsMeetingViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 26/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "ShareListMediaTableViewCell.h"
#import "DetailsMediaViewController.h"

//#import "MeetingsListViewController.h"

#import "NSString+SentenceCapitalizedString.h"
#import "NSDictionary+FilterKeysForNullObj.h"

@protocol UpdateMeetingsListDelegate;

@interface DetailsMeetingViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
//    UITableViewController *userSelectionTableView;
    
    NSUserDefaults *userPreferences;
    NSDictionary *currentUserTaste;
    UserTaste *userMet;
}


@property (nonatomic, strong) id metUserId;
@property (retain, nonatomic) NSMutableData *responseData;
@property (nonatomic, assign) id<UpdateMeetingsListDelegate> delegate;
@property (assign, nonatomic, getter=isDisplayedFromPush) BOOL isDisplayedFromPush; // Indicate if the view is push from notification

//@property (strong, atomic) UITableView *userSelectionTableView;

- (void) showTutorial;
- (void) addAsFavorite:(UIBarButtonItem*)sender;
- (void) displayMetUserfbImgProfile;
- (void) displayMetUserStats;
- (void) updateCurrentUser;
- (void) scrollToSectionWithNumber:(UIButton*)sender;


@end

@protocol UpdateMeetingsListDelegate <NSObject>

@required

- (void) meetingsListHaveBeenUpdate;

@end