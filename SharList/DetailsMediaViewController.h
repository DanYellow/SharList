//
//  DetailsMediaViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

// DO NOT IMPORT AppDelegate.h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#import <Parse/Parse.h>

//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "CCARadialGradientLayer.h"
#import <JLTMDbClient.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "JDStatusBarNotification.h"

//Custom views
#import "StoreButton.h"
#import "SHDCollapseTextView.h"

//Models
#import "Discovery.h"

// Categories
#import "UILabel+HeightToFit.h"
#import "UIButton+TrailerID.h"
#import "UIImage+ColorImage.h"
#import "NSString+URLEncodeValue.m"

// Controller
#import "SHDMediaDatas.h"
#import "PFPushManager.h"

// Custom view controller
#import "MediaCommentsViewController.h"
#import "DetailsMeetingViewController.h"
#import "SettingsViewController.h"


@protocol UpdateUserTasteListDelegate;
@protocol UpdateUserKeepListDelegate;

extern NSString * const BSCLIENTID;

@interface DetailsMediaViewController : UIViewController <UITextViewDelegate, UICollisionBehaviorDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate, FBSDKSharingDelegate, SHDMediaDatasDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
    
    
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravity;
    UICollisionBehavior *collision;
    
    // This NSArray is usefull for re-init the pos of UIButton when they disappears
    // with UIKit gravity
    NSMutableArray *buyButtonsInitPositions;
    NSMutableDictionary *userTasteDict;
    
    UIActivityIndicatorView *loadingIndicator;
    
    PFPushManager *pfPushManager;
}

typedef NS_ENUM(NSUInteger, DMVTag) {
    DMVInfosMediaTag = 2,
    DMVMediaTitleTag = 4,
    DMVInfoContainerTag = 21,
    DMVExColBtn = 22,
    DMVAmongDiscoveriesLabelTag = 13,
    DMVMediaDescriptionTag = 12
};


@property (nonatomic, assign, getter=isPhysicsAdded) BOOL PhysicsAdded;
@property (nonatomic, assign, getter=isAmongBSAccount) BOOL AmongBSAccount; // Indicates if the media (video or serie) is among BS Account

@property (nonatomic, strong) id mediaDatas;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, strong) NSString *numberLikesString;
@property (nonatomic, assign) id<UpdateUserTasteListDelegate> delegate;
@property (nonatomic, assign) id<UpdateUserKeepListDelegate> keepListDelegate;
@property (nonatomic, assign) NSMutableDictionary *mediaDatasDict;
@property (strong, nonatomic) NSString *userDiscoverId;

- (UIImage *) takeSnapshotOfView:(UIView *)view;

- (void) addMediaToUserList;
- (void) removeMediaToUserList;
- (void) showBuyScreen;
- (void) hideBuyScreen;
- (void) openStore:(UIButton*)sender;

- (void) addPhysics;
- (void) saveMediaUpdateForAdding:(BOOL)isAdding;
- (CALayer *) myLayerWithName:(NSString*)myLayerName andParent:(UIView*)aParentView;
- (void) noInternetConnexionAlert;
- (void) showTutorial;
- (void) hideTutorial;
- (void) showPoster;
- (UIButton*) connectWithBSAccount:(NSString*)BSUserToken;


@end


@protocol UpdateUserTasteListDelegate <NSObject>

@required
- (void) userListHaveBeenUpdate:(NSMutableDictionary *)dict;
@end

@protocol UpdateUserKeepListDelegate <NSObject>

@required
- (void) userKeeplistUpdated;
@end