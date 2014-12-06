//
//  ViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import <FacebookSDK/FacebookSDK.h>


//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "ShikeTutsScrollView.h"


#import "ShareListMediaTableViewCell.h"
#import "DetailsMediaViewController.h"

#import "UserTaste.h"

@interface ViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UISearchResultsUpdating, UINavigationControllerDelegate, UISearchBarDelegate, NSURLConnectionDelegate, SWTableViewCellDelegate, UpdateUserTasteListDelegate>
{    
    CGFloat screenWidth;
    CGFloat screenHeight;
   
    // Datas from API
    NSArray *APIdatas;
//    NSMutableArray *filteredDatas;
    NSMutableDictionary *filteredTableDatas;
    NSArray *categoryList;
    NSMutableDictionary *userTasteDict;
    NSUserDefaults *userPreferences;
    
    NSMutableDictionary *fooDict;
    
    BOOL USERALREADYMADEARESEARCH;
    
    UIActivityIndicatorView *loadingIndicator;
}

//@property (nonatomic, weak) id<DetailsMediaViewControllerProtocol> delegate;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;
@property (strong, nonatomic) UserTaste *userTaste;
@property (retain, nonatomic) NSMutableData *responseData;
@property (nonatomic, assign, getter=isFirstFBLoginDone) BOOL FirstFBLoginDone;


- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

// Manage user
- (void) userConnectionForFbID:(NSNumber*)userfbID;
- (void) userLoggedOutOffb:(id)uselessObj;
- (void) userLoggedOutOffb:(id)uselessObj completion:(void (^)(BOOL success))completionBlock;

- (NSString*) updateTasteForServer;
- (void) getServerDatasForFbID:(NSNumber*)userfbID isUpdate:(BOOL)isUpdate;
- (void) userListHaveBeenUpdate:(NSDictionary *)dict;







@end

