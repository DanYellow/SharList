//
//  NSDate+CupertinoYankee.m
//  SharList
//
//  Created by Jean-Louis Danielo on 17/06/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "NSDate+CupertinoYankee.h"

@implementation NSDate (CupertinoYankee)

- (NSDate *)beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:self];
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [NSDateComponents new];
    components.day = 1;
    
    NSDate *date = [calendar dateByAddingComponents:components
                                             toDate:self.beginningOfDay
                                            options:0];
    
    date = [date dateByAddingTimeInterval:-1];
    
    return date;
}

@end
