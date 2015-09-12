//
//  ShareListMediaTableViewCell.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWTableViewCell.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import <JLTMDbClient.h>

@interface ShareListMediaTableViewCell : SWTableViewCell


@property (retain, nonatomic) id model;
@property (nonatomic) NSString *name;

@property (nonatomic, assign) BOOL favorite;


- (void) setModel:(id) s;
- (id) model;

- (void) setFavorite:(BOOL)aFavorite;
- (BOOL) favorite;

@end
