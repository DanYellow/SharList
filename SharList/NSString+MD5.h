//
//  NSString+MD5.h
//  SharList
//
//  Created by Jean-Louis Danielo on 22/02/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)


+ (NSString *) md5:(NSString *)input;

@end
