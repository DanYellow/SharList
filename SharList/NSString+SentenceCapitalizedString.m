//
//  NSString+SentenceCapitalizedString.m
//  SharList
//
//  Created by Jean-Louis Danielo on 05/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "NSString+SentenceCapitalizedString.h"

@implementation NSString (SentenceCapitalizedString)

+ (NSString *) sentenceCapitalizedString:(NSString*)string
{
    if (![string length]) {
        return [NSString string];
    }
    NSString *uppercase = [[string substringToIndex:1] uppercaseString];
    NSString *lowercase = [[string substringFromIndex:1] lowercaseString];
    return [uppercase stringByAppendingString:lowercase];
}

@end
