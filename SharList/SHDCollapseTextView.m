//
//  SHDCollapseTextView.m
//  SharList
//
//  Created by Jean-Louis Danielo on 22/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "SHDCollapseTextView.h"

@implementation SHDCollapseTextView

- (id) initWithFrame:(CGRect)aFrame text:(NSString*)aText andFont:(UIFont*)aFont
{
    self = [super initWithFrame:aFrame];
    if ( !self ) return nil;
    
    self.text = aText;
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = NO;
    self.editable = NO;
    self.selectable = YES;
    self.opaque = YES;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.contentInset = UIEdgeInsetsMake(-10, -5, -90, 0);
    
    self.isExpanded = NO;
    
    self.font = aFont;
    if (self.contentSize.height > self.frame.size.height) {
        int fontIncrement = 1;
        while (self.contentSize.height > self.frame.size.height) {
            self.font = aFont;
            fontIncrement++;
        }
    }
    
    CGFloat origHeight = CGRectGetHeight(self.frame);
    [self sizeToFit];
    self.expandedHeight = CGRectGetHeight(self.frame) - origHeight + 100;
    self.height = CGRectGetHeight(self.frame) + 40;
    
    CGSize size = [self sizeThatFits:CGSizeMake(aFrame.size.width, aFrame.size.height)];
    CGFloat newHeight = (size.height < CGRectGetHeight(aFrame)) ? size.height : CGRectGetHeight(aFrame);
    
    aFrame = CGRectMake(CGRectGetMinX(aFrame), CGRectGetMinY(aFrame), CGRectGetWidth(aFrame), newHeight);
    
    
    self.frame = aFrame;

    return self;
}

@end
