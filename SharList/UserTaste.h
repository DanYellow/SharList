//
//  UserTaste.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserTaste : NSManagedObject

@property (nonatomic, retain) NSNumber *fbid;
@property (nonatomic, retain) NSData *taste;
@property (nonatomic, retain) NSDate *lastMeeting;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, retain) NSNumber *numberOfMeetings;

@end
