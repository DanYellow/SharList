//
//  NSDate+CupertinoYankee.h
//  SharList
//
//  Created by Jean-Louis Danielo on 17/06/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CupertinoYankee)

///-----------------------------------------
/// @name Calculating Beginning / End of Day
///-----------------------------------------

/**
 Returns a new date with first second of the day of the receiver.
 */
- (NSDate *)beginningOfDay;

/**
 Returns a new date with the last second of the day of the receiver.
 */
- (NSDate *)endOfDay;


- (NSDate *) dateWithoutTime;

@end
