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


//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "CCARadialGradientLayer.h"
#import <JLTMDbClient.h>

//Custom views
#import "ShopButton.h"

//Models
#import "UserTaste.h"

#import "UILabel+HeightToFit.h"
#import "UIButton+TrailerID.h"


@protocol UpdateUserTasteListDelegate;

@interface DetailsMediaViewController : UIViewController <UITextViewDelegate, UICollisionBehaviorDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate>
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
    
    __block NSString *themovieDBID;
}

@property (nonatomic, assign, getter=isPhysicsAdded) BOOL PhysicsAdded;
@property (nonatomic, assign, getter=isAdded) BOOL Added;
@property (nonatomic, strong) id mediaDatas;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) id<UpdateUserTasteListDelegate> delegate;



- (UIMotionEffectGroup*) UIMotionEffectGroupwithValue:(int)aInt;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

- (void) addMediaToUserList;
- (void) removeMediaToUserList;
- (void) showBuyScreen;
- (void) hideBuyScreen;
- (void) openStore:(UIButton*)sender;

- (void) addPhysics;
- (void) saveMediaUpdateForAdding:(BOOL)isAdding;
- (void) updateServerDatasForFbIDTimer:(NSNumber*)isAdding;
- (void) displayTrailerButtonForId:(NSString*)aTrailerID;
- (void) seeTrailerMedia:(UIButton*)sender;
- (CALayer *) myLayerWithName:(NSString*)myLayerName andParent:(UIView*)aParentView;
- (void) noInternetConnexionAlert;
- (void) showTutorial;
- (void) hideTutorial;
- (void) showPoster;


@end


@protocol UpdateUserTasteListDelegate <NSObject>

@required

- (void) userListHaveBeenUpdate:(NSMutableDictionary *)dict;

@end