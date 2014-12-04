//
//  ShikeBadgedCell.m
//  SharList
//
//  Created by Jean-Louis Danielo on 04/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "ShikeBadgedCell.h"

@implementation ShikeBadgedCell

@synthesize model = _model;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35];
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    self.textLabel.textColor = [UIColor blackColor];
    //    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.numberOfLines = 0;
    
    return self;
}


- (void) setModel:(id)s
{
    _model = s;
    
    // do some more stuff
}

- (id) model {
    return _model;
}

@end
