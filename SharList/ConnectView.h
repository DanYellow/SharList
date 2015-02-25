//
//  ConnectView.h
//  SharList
//
//  Created by Jean-Louis Danielo on 25/02/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface ConnectView : UIView <FBLoginViewDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
}


- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension;

@end
