//
//  PFPushManager.h
//  SharList
//
//  Created by Jean-Louis Danielo on 07/03/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>



typedef NS_ENUM(NSInteger, TypePush) {
    UpdateList = 0
};

@interface PFPushManager : NSObject

@property (nonatomic, strong) PFPush *push;

- (id) initForType:(TypePush)aType;

- (void) notifyUpdateList;

- (void) setPFPush:(PFPush*)aPush;
- (PFPush*) push;

@end
