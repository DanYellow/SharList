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
    
    return self;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    CGRect textLabelFrame = self.textLabel.frame;
//    textLabelFrame.size.width = ([[UIScreen mainScreen] bounds].size.width - 50);
//    self.textLabel.frame = textLabelFrame;
//}

- (void) layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@"self.imageView.frame : %@", NSStringFromCGRect(self.imageView.frame));
//    self.imageView.frame = CGRectMake( 10, self.imageView.frame.origin.y, 22, 22 ); // your positioning here
    
//    self sty
//    CGRect textLabelFrame = self.textLabel.frame;
//    textLabelFrame.origin.x = 22;
//    self.textLabel.frame = textLabelFrame;
    

//
//    UIImageView *meetingFavoriteSelectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height / 2) - 11, 22, 22)];
//    if (_favorite) {
//        CGRect textLabelFrame = self.textLabel.frame;
//        textLabelFrame.origin.x = 22;
//        self.textLabel.frame = textLabelFrame;
//        self.imageView.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
////        [self.contentView insertSubview:meetingFavoriteSelectedImgView belowSubview:self.textLabel];
//    } else {
//        self.imageView.image = nil;
////        [meetingFavoriteSelectedImgView removeFromSuperview];
//    }
}

- (void) setModel:(id)s
{
    _model = s;
}

- (id) model {
    return _model;
}


- (void) setFavorite:(BOOL)aFavorite {
    _favorite = aFavorite;
}
- (BOOL) favorite {
    return _favorite;
}

@end
