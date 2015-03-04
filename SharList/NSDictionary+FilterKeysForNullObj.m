//
//  NSDictionary+FilterKeysForNullObj.m
//  SharList
//
//  Created by Jean-Louis Danielo on 04/03/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "NSDictionary+FilterKeysForNullObj.h"

@implementation NSDictionary (FilterKeysForNullObj)

- (NSMutableArray*) filterKeysForNullObj
{
    NSMutableArray *aMutableArray = [NSMutableArray new];
    
    for (id key in self) {
        if (![[self objectForKey:key] isEqual:[NSNull null]]) {
            [aMutableArray addObject:key];
        }
    }
    return aMutableArray;
}

@end
