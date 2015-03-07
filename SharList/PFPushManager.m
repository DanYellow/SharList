//
//  PFPushManager.m
//  SharList
//
//  Created by Jean-Louis Danielo on 07/03/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "PFPushManager.h"

@implementation PFPushManager

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initForType:(TypePush)aType {
    if (self = [super init]) {
        switch (aType) {
            case UpdateList: {
                // The current user said to every subscribers of his channel
                // (aka every user who had added his list among favorites)
                // he update his list
                NSString *currentUserPFChannelName = @"sh_channel_";
                currentUserPFChannelName = [currentUserPFChannelName stringByAppendingString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"] stringValue]];
                
                
                NSTimeInterval interval = 60*60*24*7; // 1 week
                NSDictionary *data = @{
                                       @"alert" : @{
                                               @"loc-key" : @"push remote notif update list"
                                               },
                                       @"badge" : @"Increment",
                                       @"content-available": @0,
                                       @"userfbid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"], //Put user fbid
                                       @"sounds" : @""};
                self.push = [PFPush new];
                [self.push setChannels:@[ currentUserPFChannelName ]];
                [self.push expireAfterTimeInterval:interval];
                [self.push setData:data];
            }
                
                break;
                
            default:
                break;
        }
    }
    return self;
}

// This methods should be use when the user has modify his list and want to notify everybody
- (void) notifyUpdateList
{

//    [self.push sendPushInBackground];

    [NSObject cancelPreviousPerformRequestsWithTarget:self.push];
    [self.push performSelector:@selector(sendPushInBackground) withObject:nil afterDelay:15.0];
    
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        //code to be executed on the main queue after delay
//        [self MoveSomethingFrom:from To:to];
//    });
}

- (void) setPFPush:(PFPush*)aPush {
    _push = aPush;
}

- (id) push {
    return _push;
}


@end
