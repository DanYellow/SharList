//
//  ShareListMediaTableViewCell.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "ShareListMediaTableViewCell.h"

@implementation ShareListMediaTableViewCell

@synthesize model = _model;
@synthesize favorite = _favorite;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35];
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    self.textLabel.textColor = [UIColor blackColor];
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.numberOfLines = 0;
    self.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.35];
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
}

- (void) setModel:(id)s
{
    _model = s;
    
//    [self getImageCellForData:_model aCell:self];
}

- (id) model {
    return _model;
}

@end
