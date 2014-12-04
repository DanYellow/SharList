//
//  ShikeBadgedCell.h
//  SharList
//
//  Created by Jean-Louis Danielo on 04/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "TDBadgedCell.h"

@interface ShikeBadgedCell : TDBadgedCell

@property (retain, nonatomic) id model;
@property (nonatomic) NSString *name;


- (void) setModel:(id) s;
- (id) model;

@end
