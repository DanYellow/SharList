//
//  ShikeTutsScrollView.m
//  SharList
//
//  Created by Jean-Louis Danielo on 06/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "ShikeTutsScrollView.h"

@implementation ShikeTutsScrollView

@synthesize pageControl = _pageControl;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
//        CGFloat screenHeight = screenRect.size.height;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.hidden = NO;
        
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        // View is always centered in the view
        self.frame = CGRectMake(((screenWidth - frame.size.width) / 2), frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
        for (int i = 0; i < colors.count; i++) {
            CGRect frame;
            frame.origin.x = self.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = self.frame.size;
            
            UIView *subview = [[UIView alloc] initWithFrame:frame];
            subview.backgroundColor = [colors objectAtIndex:i];
            [self.scrollView addSubview:subview];
        }
        
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width * colors.count, self.frame.size.height);
    }
    
    return self;
}

- (void) setPageControl:(UIPageControl *)pageControl
{
    _pageControl = pageControl;
    
    pageControl.numberOfPages = self.scrollView.subviews.count;
    [self addSubview:pageControl];
}

- (UIPageControl *) pageControl
{
    return _pageControl;
}

#pragma mark - Delegate methods

// called when scroll view grinds to a halt
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width; //
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    
    int page = (int)lround(fractionalPage);
    self.pageControl.currentPage = page;
}

@end
