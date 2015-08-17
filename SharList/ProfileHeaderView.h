//
//  ProfileHeaderView.h
//  SharList
//
//  Created by Jean-Louis Danielo on 16/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "SHDUserDiscoveredDatas.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


@interface ProfileHeaderView : UIView


@property (strong, atomic) UIImageView *bgImageProfile;

- (id) initWithDatas:(SHDUserDiscoveredDatas*)userDatas;


@end
