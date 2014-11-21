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

#import "CCARadialGradientLayer.h"
#import "ShopButton.h"

@interface DetailsMediaViewController : UIViewController <UITextViewDelegate, UICollisionBehaviorDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravity;
    UICollisionBehavior *collision;
    
    // This NSArray is usefull for re-init the pos of UIButton when they disappears
    // with UIKit gravity
    NSMutableArray *buyButtonsInitPositions;
}

@property (nonatomic, assign, getter=isPhysicsAdded) BOOL PhysicsAdded;


- (UIMotionEffectGroup*) UIMotionEffectGroupwithValue:(int)aInt;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

- (void) addMediaToUserList;
- (void) displayBuyScreen;
- (void) hideBuyScreen;
- (void) openStore:(UIButton*)sender;

- (void) addPhysics;


@end
