//
//  ViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>


//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import <JLTMDbClient.h>

#import "ShareListMediaTableViewCell.h"
#import "SHDMediaCell.h"
#import "DetailsMediaViewController.h"
#import "KeepListViewControler.h"


#import "Discovery.h"

#import "NSDictionary+FilterKeysForNullObj.h"
#import "NSString+URLEncodeValue.m"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UISearchResultsUpdating, UINavigationControllerDelegate, UISearchBarDelegate, NSURLConnectionDelegate, SWTableViewCellDelegate, UpdateUserTasteListDelegate, CLLocationManagerDelegate, UISplitViewControllerDelegate, ProfileHeaderViewDelegate>
{    
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
   
    // Datas from API
    NSArray *APIdatas;
    __block NSMutableDictionary *filteredTableDatas;
    NSArray *categoryList;
    NSMutableDictionary *userTasteDict;

    NSUserDefaults *userPreferences;
    
    UIActivityIndicatorView *loadingIndicator;
}

//@property (nonatomic, weak) id<DetailsMediaViewControllerProtocol> delegate;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;
@property (strong, nonatomic) Discovery *user;
@property (retain, nonatomic) NSMutableData *responseData;
@property (nonatomic, strong) CLLocationManager *locationManager;


- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

// Manage user
- (void) userConnectionForFbID:(NSNumber*)userfbID;
//- (void) userLoggedOutOffb:(id)uselessObj;
- (void) updateUserLocation:(NSNumber*)userfbID;

- (NSString*) updateTasteForServer;
- (void) getServerDatasForFbID:(NSNumber*)userfbID isUpdate:(BOOL)isUpdate;
- (void) userListHaveBeenUpdate:(NSDictionary *)dict;
- (void) fetchDatasFromServerWithQuery:(NSString*)query completion:(void (^)(id result))completion;

- (void) displayCurrentUserfbImgProfile;
- (void) displayCurrentUserStats;

- (void) scrollToSectionWithNumber:(UIButton*)sender;

- (void) getUserLikesForSender:(UIButton*)sender;
- (void) synchronizeUserListWithServer;

@end

