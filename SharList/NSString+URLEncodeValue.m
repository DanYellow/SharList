//
//  NSString+URLEncodeValue.m
//  SharList
//
//  Created by Jean-Louis Danielo on 15/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "NSString+URLEncodeValue.h"

@implementation NSString (URLEncodeValue)

+ (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
    return result;
}


@end
