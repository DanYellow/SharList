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
    SHDDiscoverProfileImgTag = 3
};

@property (strong, atomic) Discovery *userDiscovered;
@property (strong, atomic) Discovery *currentUser;

@property (strong, atomic) NSDictionary *currentUserLikes;
@property (strong, atomic) NSDictionary *discoveredUserLikes;

//@property (strong, atomic) UILabel *label;

- (id) initWithDatas:(Discovery*)userDiscovered;
//- (void) setDatas:(Discovery *) userDiscovered;
- (void) setStatistics:(CGFloat)percent;

//- (void) setMediaThumbs:(NSDictionary*)userDiscoveredMedias;
- (void) mediaThumbs:(NSMutableArray*) mediasArray;
//- (UIView*) setMediaThumbs:(NSDictionary*)userDiscoveredMedias;

//- (void) setLabel:(UIColor *) borderColor;
- (UILabel*) label;
- (UIView*) mediaThumbs;
- (UIView*) mediaThumbsContainer;
- (UIImageView*) profileImage;

@end
