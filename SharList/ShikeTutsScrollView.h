//
//  ShikeTutsScrollView.h
//  SharList
//
//  Created by Jean-Louis Danielo on 06/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShikeTutsScrollView : UIView <UIScrollViewDelegate>

// page control of this uiscrollview subclass
@property (retain, nonatomic) UIPageControl *pageControl;
@property (retain, nonatomic) UIScrollView *scrollView;

@end
