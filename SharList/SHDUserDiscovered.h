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

typedef NS_ENUM(NSUInteger, Tag) {
    SHDDiscoverTimeLabelTag = 1,
    SHDDiscoverMediaThumbsTag = 2,
    SHDDiscoverProfileImgTag = 42
};

@property (strong, atomic) Discovery *userDiscovered;
@property (strong, atomic) Discovery *currentUser;

@property (strong, atomic) NSDictionary *currentUserLikes;
@property (strong, atomic) NSDictionary *discoveredUserLikes;

@property (strong, atomic) UIImageView *discoveryTypeIcon;
@property (strong, atomic) UILabel *discoveryTimeLabel;

//@property (strong, atomic) UILabel *label;

- (id) initWithDatas:(Discovery*)userDiscovered;
//- (void) setDatas:(Discovery *) userDiscovered;
- (void) setStatistics:(CGFloat)percent;

//- (void) setMediaThumbs:(NSDictionary*)userDiscoveredMedias;
- (void) setMediaThumbs:(NSMutableArray*) mediasArray;
//- (UIView*) setMediaThumbs:(NSDictionary*)userDiscoveredMedias;

- (UIView*) mediaThumbsContainer;
- (void) setProfileImage:(NSString*)fbId;
- (void) setDiscoveryTime:(NSDate*)discoveryTime;
- (void) setUserDiscoveredName:(NSString*)fbid;
- (void) newDiscoverManager:(BOOL)isSeen;
- (void) favoriteDiscoverManager:(BOOL)isFavorite;

@end
