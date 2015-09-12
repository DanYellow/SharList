//
//  NSDictionary+FilterKeysForNullObj.h
//  SharList
//
//  Created by Jean-Louis Danielo on 04/03/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Underscore.h"
#define _ Underscore

@interface NSDictionary (FilterKeysForNullObj)

- (NSMutableArray*) filterKeysForNullObj;

@end
