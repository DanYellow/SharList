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

@interface DetailsMediaViewController : UIViewController <UITextViewDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}


- (UIMotionEffectGroup*) UIMotionEffectGroupwithValue:(int)aInt;


@end
