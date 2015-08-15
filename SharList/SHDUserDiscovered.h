//
//  SHDUserDiscovered.h
//  SharList
//
//  Created by Jean-Louis Danielo on 14/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Discovery.h"

#import "NSDictionary+FilterKeysForNullObj.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "JLTMDbClient.h"

@interface SHDUserDiscovered : UIView

@property (strong, atomic) Discovery *userDiscovered;
@property (strong, atomic) Discovery *currentUser;

@property (strong, atomic) NSDictionary *currentUserLikes;
@property (strong, atomic) NSDictionary *discoveredUserLikes;

- (id) initWithDatas:(Discovery*)userDiscovered;

@end
