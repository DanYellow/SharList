//
//  ShareListMediaTableViewCell.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "ShareListMediaTableViewCell.h"

@implementation ShareListMediaTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35];
    self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.textLabel.textColor = [UIColor blackColor];
//    self.textLabel.frame = CGRectMake(-40.0, -40.0, self.textLabel.frame.size.width, 15);
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    
//    self.detailTextLabel.text = [self.model objectForKey:@"type"];
//    NSLog(@"type : %@", [self.model objectForKey:@"type"]);
    self.detailTextLabel.numberOfLines = 0;
    
    return self;
}

- (void) setModel:(id)s
{
    self.model = s;
    
    // do some more stuff
}

- (id) model {
    return self.model;
}

@end
