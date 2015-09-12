//
//  UITableViewCell+Model.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/09/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "UITableViewCell+Model.h"
#import <objc/runtime.h>

@implementation UITableViewCell (Model)

static void *ModelPropertyKey = &ModelPropertyKey;

- (id)model {
    return objc_getAssociatedObject(self, ModelPropertyKey);
}

- (void)setModel:(id)aModel {
    objc_setAssociatedObject(self, ModelPropertyKey, aModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
