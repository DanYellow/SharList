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

//Custom views
#import "ShopButton.h"

//Models
#import "UserTaste.h"

#import "UILabel+HeightToFit.h"

@protocol UpdateUserTasteListDelegate;

@interface DetailsMediaViewController : UIViewController <UITextViewDelegate, UICollisionBehaviorDelegate, NSURLConnectionDelegate>
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
}

@property (nonatomic, assign, getter=isPhysicsAdded) BOOL PhysicsAdded;
@property (nonatomic, assign, getter=isAdded) BOOL Added;
@property (nonatomic, strong) id mediaDatas;
@property (retain, nonatomic) NSMutableData *responseData;
@property (nonatomic, assign) id<UpdateUserTasteListDelegate> delegate;



- (UIMotionEffectGroup*) UIMotionEffectGroupwithValue:(int)aInt;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

- (void) addMediaToUserList;
- (void) removeMediaToUserList;
- (void) displayBuyScreen;
- (void) hideBuyScreen;
- (void) openStore:(UIButton*)sender;

- (void) addPhysics;
//- (void) updateServerDatasForFbID:(NSNumber*)userfbID;
- (void) saveMediaUpdateForAdding:(BOOL)isAdding;
- (void) updateServerDatasForFbIDTimer:(NSNumber*)isAdding;


@end


@protocol UpdateUserTasteListDelegate <NSObject>

@required

- (void) userListHaveBeenUpdate:(NSMutableDictionary *)dict;

@end