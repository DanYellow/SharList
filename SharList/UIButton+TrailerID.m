//
//  UIButton+TrailerID.m
//  SharList
//
//  Created by Jean-Louis Danielo on 26/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "UIButton+TrailerID.h"
#import <objc/runtime.h>

@implementation UIButton (TrailerID)

static void *TrailerIDPropertyKey = &TrailerIDPropertyKey;


- (NSString *)trailerID {
    return objc_getAssociatedObject(self, TrailerIDPropertyKey);
}

- (void)setTrailerID:(NSString *)aYoutubeID {
    objc_setAssociatedObject(self, TrailerIDPropertyKey, aYoutubeID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
