//
//  SHDMediaDatas.h
//  SharList
//
//  Created by Jean-Louis Danielo on 21/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JLTMDbClient.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "Discovery.h"
#import "KeepListElement.h"

#import "NSDictionary+FilterKeysForNullObj.h"


@protocol SHDMediaDatasDelegate <NSObject>

@required
- (void) datasAreReady;
@end

@interface SHDMediaDatas : NSObject

@property (strong, atomic) NSMutableDictionary *mediaDatas;
@property (strong, atomic) NSString *imdbId;
@property (strong, atomic) NSString *type; // movie or serie

@property (weak, atomic) NSDate *nextEpisodeDate;
@property (strong, atomic) NSString *nextEpisodeRef; // S01E04 e.g.

@property (nonatomic, assign) BOOL isInCurrentUserList; // Indicate if the current media is among user list
@property (nonatomic, assign) BOOL isUserList;
@property (nonatomic, assign) BOOL isAmongKeepList;

- (instancetype) initWithMedia:(NSDictionary *)media;

@property (nonatomic, weak) id<SHDMediaDatasDelegate> delegate;


@end
