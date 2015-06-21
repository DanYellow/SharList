//
//  StoreButton
//  SharList
//
//  Created by Jean-Louis Danielo on 21/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "StoreButton.h"

@interface StoreButton ()

- (void) setColorForBtn:(NSDictionary*)colorDict;
- (void) setStoreName:(StoreName) sn;

@end

@implementation StoreButton



@synthesize storeName = _storeName;
@synthesize storeLink = _storeLink;
@synthesize borderColor = _borderColor;
@synthesize highlightBorderColor = _highlightBorderColor;

- (id) initWithType:(StoreName) storeName
{
    self = [super init];
    if ( !self ) return nil;
    
    UIColor *amazonBColor = [UIColor colorWithRed:1 green:(124.0f/255.0f) blue:(2.0f/255.0f) alpha:1.0f];
    UIColor *amazonBColorHighlight = [UIColor colorWithRed:1 green:(124.0f/255.0f) blue:(2.0f/255.0f) alpha:1.0f];
    
    UIColor *fnacBColor = [UIColor colorWithRed:1 green:(124.0f/255.0f) blue:(2.0f/255.0f) alpha:1.0f];
    UIColor *fnacBColorHighlight = [UIColor colorWithRed:1 green:(124.0f/255.0f) blue:(2.0f/255.0f) alpha:1.0f];
    
    UIColor *itunesBColor = [UIColor colorWithRed:(166.0f/255.0f) green:(166.0f/255.0f) blue:(166.0f/255.0f) alpha:1.0f];
    UIColor *itunesBColorHighlight = [UIColor colorWithRed:(133.0f/255.0f) green:(133.0f/255.0f) blue:(133.0f/255.0f) alpha:1.0f];
    
    NSDictionary *btnsColor = @{
                                @"itunes": @[itunesBColor, itunesBColorHighlight],
                                @"amazon": @[amazonBColor, amazonBColorHighlight],
                                @"fnac": @[fnacBColor, fnacBColorHighlight]
                              };
 
    
    
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.borderWidth = 2.0f;
    
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]] forState:UIControlStateHighlighted];
    
    self.storeName = storeName;
    
    switch (storeName) {
        case Amazon:
            [self setColorForBtn:btnsColor[@"amazon"]];
            break;
        case Itunes:
            [self setColorForBtn:btnsColor[@"itunes"]];
            break;
        case Fnac:
            [self setColorForBtn:btnsColor[@"fnac"]];
            break;
        default:
            break;
    }
    
    
    /* Events */
    [self addTarget:self action:@selector(highlightBorder) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchUpInside];
   

    
    return self;
}

- (void) setColorForBtn:(NSArray*)colors
{
    self.borderColor = (UIColor*)colors[0];
    self.highlightBorderColor = (UIColor*)colors[1];
    
    [self setTitleColor:(UIColor*)colors[0] forState:UIControlStateNormal];
    [self setTitleColor:(UIColor*)colors[1] forState:UIControlStateHighlighted];
    self.layer.borderColor = (__bridge CGColorRef)((UIColor*)[colors[0] CGColor]);
}

- (void) setStoreName:(StoreName) storeName
{
    _storeName = storeName;
}

- (StoreName) storeName
{
    return _storeName;
}

- (void) setShopLink:(NSString *)storeLink
{
    _storeLink = storeLink;
}

- (NSString*) shopLink
{
    return _storeLink;
}

- (void) setBorderColor:(UIColor *) borderColor
{
    _borderColor = borderColor;
}

- (UIColor*) borderColor
{
    return _borderColor;
}

- (void) setHighlightBorderColor:(UIColor *) highlightBorderColor
{
    _highlightBorderColor = highlightBorderColor;
}

- (UIColor*) highlightBorderColor
{
    return _highlightBorderColor;
}

/* Events */

- (void) highlightBorder
{
    self.layer.borderColor = [self.highlightBorderColor CGColor];
}

- (void)unhighlightBorder
{
    self.layer.borderColor = [self.borderColor CGColor];
}

@end
