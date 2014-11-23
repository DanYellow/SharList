//
//  DetailsMediaViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"

//Vendors
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "CCARadialGradientLayer.h"

//Custom views
#import "ShopButton.h"

//Models
#import "UserTaste.h"

@protocol DetailsMediaViewControllerDelegate;

@interface DetailsMediaViewController : UIViewController <UITextViewDelegate, UICollisionBehaviorDelegate, NSURLConnectionDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravity;
    UICollisionBehavior *collision;
    
    // This NSArray is usefull for re-init the pos of UIButton when they disappears
    // with UIKit gravity
    NSMutableArray *buyButtonsInitPositions;
    NSMutableDictionary *userTasteDict;
    
    UIActivityIndicatorView *indicator;
}

- (UIMotionEffectGroup*) UIMotionEffectGroupwithValue:(int)aInt;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

- (void) addMediaToUserList:(UIButton*)sender;
- (void) removeMediaToUserList:(UIButton*)sender;
- (void) displayBuyScreen;
- (void) hideBuyScreen;
- (void) openStore:(UIButton*)sender;

- (void) addPhysics;

@property (nonatomic, assign, getter=isPhysicsAdded) BOOL PhysicsAdded;
@property (nonatomic, strong) id mediaDatas;
@property (retain, nonatomic) NSMutableData *responseData;
@property (nonatomic, assign) id<DetailsMediaViewControllerDelegate> delegate;

@end


@protocol DetailsMediaViewControllerDelegate <NSObject>

@required

- (void) userListHaveBeenUpdate:(NSMutableDictionary *)dict;

@end