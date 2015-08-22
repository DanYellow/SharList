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
    self.isExpanded = NO;
    self.contentInset = UIEdgeInsetsMake(-10, -5, -90, 0);
    
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
    self.expandedHeight = CGRectGetHeight(self.frame) - origHeight;
    self.height = CGRectGetHeight(self.frame) + 40;
    self.frame = aFrame;

    return self;
}

@end
