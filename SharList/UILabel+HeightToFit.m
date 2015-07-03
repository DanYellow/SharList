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
    
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
    NSStringDrawingUsesLineFragmentOrigin;
    
    NSDictionary *attr = @{NSFontAttributeName: self.font};
    CGRect labelBounds = [self.text boundingRectWithSize:maxSize
                                              options:options
                                           attributes:attr
                                              context:nil];
    
    CGRect labelRect = self.frame;
    labelRect.size.height = CGRectGetHeight(labelBounds);
    [self setFrame:labelRect];
}

@end
