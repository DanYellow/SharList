//
//  SHDMediaCell.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/09/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWTableViewCell.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import <JLTMDbClient.h>

@interface SHDMediaCell : SWTableViewCell

@property (retain, nonatomic) NSDictionary *media;
//@property (nonatomic) NSString *name;

@property (nonatomic, assign) BOOL favorite;


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier andFrame:(CGRect)aFrame;

- (void) setMedia:(NSDictionary*) m;
- (NSDictionary*) media;

- (void) setFavorite:(BOOL)aFavorite;
- (BOOL) favorite;

@end
