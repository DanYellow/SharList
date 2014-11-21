//
//  ShareListMediaTableViewCell.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWTableViewCell.h"

@interface ShareListMediaTableViewCell : SWTableViewCell


@property (retain, nonatomic) id model;


- (void) setModel:(id) s;
- (id) model;

@end
