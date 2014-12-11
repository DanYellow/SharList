//
//  NSArray+Reverse.m
//  SharList
//
//  Created by Jean-Louis Danielo on 11/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
