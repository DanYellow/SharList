//
//  SHDCollapseTextView.h
//  SharList
//
//  Created by Jean-Louis Danielo on 22/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHDCollapseTextView : UITextView

@property (nonatomic, assign) CGFloat expandedHeight;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL isExpanded;


- (id) initWithFrame:(CGRect)aFrame text:(NSString*)aText andFont:(UIFont*)aFont;

@end
