//
//  DetailsMeetingViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 26/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import <Parse/Parse.h>

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "ShareListMediaTableViewCell.h"
#import "DetailsMediaViewController.h"

//#import "MeetingsListViewController.h"

#import "NSString+SentenceCapitalizedString.h"
#import "NSDictionary+FilterKeysForNullObj.h"

@protocol UpdateMeetingsListDelegate;

typedef NS_ENUM (NSInteger, FollowingStatus) {
    Unfollow = 0,
    Follow = 1
};

@interface DetailsMeetingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate, FBSDKSharingDelegate>
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
- (void) displayMetUserfbImgProfileForDatas:(NSDictionary*)datas;
- (void) displayMetUserStats;
- (void) updateCurrentUser;
- (void) scrollToSectionWithNumber:(UIButton*)sender;


@end

@protocol UpdateMeetingsListDelegate <NSObject>

@required

- (void) meetingsListHaveBeenUpdate;

@end