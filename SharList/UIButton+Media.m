//
//  UIButton+Media.m
//  SharList
//
//  Created by Jean-Louis Danielo on 19/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "UIButton+Media.h"
#import <objc/runtime.h>

@implementation UIButton (Media)

static void *MediaIDPropertyKey = &MediaIDPropertyKey;


- (NSDictionary *)media {
    return objc_getAssociatedObject(self, MediaIDPropertyKey);
}

- (void)setMedia:(NSDictionary *)aMedia {
    objc_setAssociatedObject(self, MediaIDPropertyKey, aMedia, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
