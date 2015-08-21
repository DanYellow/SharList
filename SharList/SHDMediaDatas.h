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

@protocol SHDMediaDatasDelegate <NSObject>

@required
- (void) datasAreReady;
@end

@interface SHDMediaDatas : NSObject

@property (strong, atomic) NSMutableDictionary *mediaDatas;

- (instancetype) initWithMedia:(NSDictionary *)media;
@property (nonatomic, weak) id<SHDMediaDatasDelegate> delegate;


@end
