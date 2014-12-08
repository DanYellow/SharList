//
//  UILabel+HeightToFit.m
//  SharList
//
//  Created by Jean-Louis Danielo on 08/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "UILabel+HeightToFit.h"

@implementation UILabel (HeightToFit)

- (void) heightToFit
{
    CGSize maxSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    CGSize textSize = [self.text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:self.lineBreakMode];
    
    CGRect labelRect = self.frame;
    labelRect.size.height = textSize.height;
    [self setFrame:labelRect];
}

@end
