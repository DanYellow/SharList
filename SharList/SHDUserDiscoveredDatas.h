//
//  SHDUserDiscoveredDatas.h
//  SharList
//
//  Created by Jean-Louis Danielo on 15/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Discovery.h"

#import "NSDictionary+FilterKeysForNullObj.h"

@interface SHDUserDiscoveredDatas : NSObject

- (instancetype) initWithDiscoveredUser:(Discovery *) userDiscovered;

@property (strong, atomic) Discovery *userDiscovered;
@property (strong, atomic) Discovery *currentUser;

@property (strong, atomic) NSDictionary *currentUserLikes;
@property (strong, atomic) NSDictionary *discoveredUserLikes;

@property (nonatomic, assign) BOOL isSameUser;

- (CGFloat) percentToDiscover;
- (NSMutableArray*) mediasIds;
- (NSString*) fbid;

@end
