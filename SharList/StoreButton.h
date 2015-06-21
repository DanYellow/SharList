//
//  StoreButton.h
//  SharList
//
//  Created by Jean-Louis Danielo on 21/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImage+ColorImage.m"


@interface StoreButton : UIButton

typedef NS_ENUM(NSUInteger, StoreName) {
    Amazon = 0,
    Itunes = 1,
    Fnac = 2
};

@property (nonatomic, assign) StoreName storeName;
@property (nonatomic, retain) NSString *storeLink;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *highlightBorderColor;


- (id) initWithType:(StoreName) storeName;


- (StoreName) storeName;

- (void) setStoreLink:(NSString *) storeLink;
- (NSString*) storeLink;

- (void) setBorderColor:(UIColor *) borderColor;
- (UIColor*) borderColor;

- (void) setHighlightBorderColor:(UIColor *) highlightBorderColor;
- (UIColor*) highlightBorderColor;

@end
