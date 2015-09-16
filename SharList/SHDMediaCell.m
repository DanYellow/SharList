//
//  SHDMediaCell.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/09/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "SHDMediaCell.h"

@interface SHDMediaCell()

@property(nonatomic) CGRect bgImgFrame;

- (void) getLastNextReleaseSerieEpisodeForCell:(SHDMediaCell*)aCell;

@end

@implementation SHDMediaCell

//

@synthesize media = _media;
@synthesize favorite = _favorite;



- (void)awakeFromNib {
    // Initialization code
}


//- (id)initWithFrame:(CGRect)frame
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier andFrame:(CGRect)aFrame
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.textLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
        self.textLabel.layer.shadowOpacity = .75f;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        
        self.bgImgFrame = aFrame;
        
        self.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.35];
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.indentationLevel = 1;
        
        // It create weird behaviour if is here
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bgColorView = [UIView new];
        [bgColorView setBackgroundColor:[UIColor colorWithWhite:1 alpha:.09]];
        [self setSelectedBackgroundView:bgColorView];
    }
    
    
    return self;
}

- (void) setMedia:(NSDictionary*)m
{
    _media = m;
    
    [self getImageCellForData:_media aCell:self];
    
    if ([self.media[@"type"] isEqualToString:@"serie"]) {
        [self getLastNextReleaseSerieEpisodeForCell:self];
    } else {
        self.detailTextLabel.text = @"";
    }
}

- (id) media
{
    return _media;
}


- (void) getImageCellForData:(NSDictionary*)media aCell:(UITableViewCell*)cell
{
    CGRect cellFrame = self.bgImgFrame;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = cellFrame;
    [gradientLayer setStartPoint:CGPointMake(-0.05, 0.5)];
    [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
    gradientLayer.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]];
    
    UIImageView *imgBackground = [[UIImageView alloc] initWithFrame:cellFrame];
    imgBackground.contentMode = UIViewContentModeScaleAspectFill;
    imgBackground.clipsToBounds = YES;
    
    cell.backgroundView = imgBackground;
    
    __block NSString *imgDistURL; // URL of the image from imdb database api
    
    NSString *apiLink;
    
//    __block NSString *imgName;
    if ([media[@"type"] isEqualToString:@"movie"]) {
        apiLink = kJLTMDbMovie;
    } else {
        apiLink = kJLTMDbFind;
    }
    
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
    
    //    [UIView animateWithDuration:0.25 animations:^{
    //        imgBackground.alpha = .1;
    //    }];
    
    [[JLTMDbClient sharedAPIInstance] GET:apiLink withParameters:@{@"id": media[@"imdbID"], @"language": userLanguage, @"external_source": @"imdb_id"} andResponseBlock:^(id responseObject, NSError *error) {
        
        NSString *imgName;
        if(!error){
            if ([media[@"type"] isEqualToString:@"serie"] &&
                [[responseObject valueForKeyPath:@"tv_results.poster_path"] count] != 0) {
                imgName = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
            } else {
                if (responseObject[@"poster_path"] == nil) {
                    return;
                }
                
                if([responseObject[@"poster_path"] length] != 0) {
                    imgName = responseObject[@"poster_path"];
                }
            }
            
            NSString *imgSize = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) ? @"w396" : @"w780";
            imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/%@%@", imgSize, imgName];
            
            [imgBackground setImageWithURL:
             [NSURL URLWithString:imgDistURL]
                          placeholderImage:[UIImage imageNamed:@"TrianglesBG"]];
            [imgBackground.layer insertSublayer:gradientLayer atIndex:0];
        }
    }];
}

- (void) getLastNextReleaseSerieEpisodeForCell:(SHDMediaCell*)aCell
{
    NSDictionary *queryParams =  @{@"id": [aCell.media objectForKey:@"imdbID"], @"external_source": @"imdb_id"};
    [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbFind withParameters:queryParams andResponseBlock:^(id responseObject, NSError *error) {
        if(!error){
            if ([[responseObject valueForKeyPath: @"tv_results"] count] == 0) {
                aCell.detailTextLabel.text = @"";
                return;
            }
            NSDictionary *tvQueryParams = @{@"id": [responseObject valueForKeyPath: @"tv_results.id"][0]};
            [[JLTMDbClient sharedAPIInstance] setAPIKey:@"f09cf27014943c8114e504bf5fbd352b"];
            [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTV withParameters:tvQueryParams andResponseBlock:^(id responseObject, NSError *error) {
                if(!error){
                    // Get the date of the next episode
                    NSDictionary *tvSeasonQueryParams = @{@"id": [responseObject valueForKeyPath:@"id"],
                                                          @"season_number": [responseObject valueForKeyPath:@"number_of_seasons"]};
                    
                    NSString *lastAirEpisode = (NSString*)[responseObject valueForKeyPath:@"last_air_date"];
                    NSDateFormatter *dateFormatter = [NSDateFormatter new];
                    dateFormatter.dateFormat = @"yyyy-MM-dd";
                    NSDate *lastAirEpisodeDate = [dateFormatter dateFromString:lastAirEpisode];
                    
                    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTVSeasons withParameters:tvSeasonQueryParams andResponseBlock:^(id responseObject, NSError *error) {
                        NSDateFormatter *dateFormatter = [NSDateFormatter new];
                        dateFormatter.dateFormat = @"yyyy-MM-dd";
                        
                        NSDate *closestDate = nil;
                        int episodeNumber = 0;
                        
                        for (NSDictionary* episode in responseObject[@"episodes"]) {
                            if ([episode objectForKey:@"air_date"] != (id)[NSNull null]) {
                                NSString *dateString = (NSString *)[episode objectForKey:@"air_date"];
                                
                                NSDate *episodeDate = [dateFormatter dateFromString:dateString];
                                episodeNumber++;
                                if([episodeDate timeIntervalSinceNow] < -100000) {
                                    continue;
                                }
                                
                                // If the the date is today so we break the loop
                                if ([[NSCalendar currentCalendar] isDateInToday:episodeDate] || !closestDate) {
                                    closestDate = episodeDate;
                                    break;
                                }
                                
                                if([episodeDate timeIntervalSinceNow] < [closestDate timeIntervalSinceNow] || !closestDate) {
                                    closestDate = episodeDate;
                                }
                            }
                        }
                        
                        NSDate *dateForEpisode = (closestDate != nil) ? closestDate : lastAirEpisodeDate;
                        [self displayLastNextReleaseSerieEpisodeForCell:aCell
                                                                   date:dateForEpisode
                                                    andSeasonForEpisode:[NSString stringWithFormat:@"S%02iE%02i", [tvSeasonQueryParams[@"season_number"] intValue], episodeNumber]];
                    }];
                }
            }];
            
        }
    }];
}

- (void) displayLastNextReleaseSerieEpisodeForCell:(SHDMediaCell*)aCell date:(NSDate*)aDate andSeasonForEpisode:(NSString*)aEpisodeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSString *lastAirEpisodeDateString = [dateFormatter stringFromDate:aDate];
    
    aCell.detailTextLabel.text = ([aDate timeIntervalSinceNow] > 0) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil), lastAirEpisodeDateString] : @"";
    // If an episode of this serie is release today we notify the user
    aCell.detailTextLabel.text = ([[NSCalendar currentCalendar] isDateInToday:aDate]) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil), NSLocalizedString(@"release today", @"aujourd'hui !")] : aCell.detailTextLabel.text;
    // If an episode of this serie is release tomorrow we notify the user
    aCell.detailTextLabel.text = ([[NSCalendar currentCalendar] isDateInTomorrow:aDate]) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil),  NSLocalizedString(@"release tomorrow", @"demain !")] : aCell.detailTextLabel.text;
    
    if ([aDate timeIntervalSinceNow] > 0 || [[NSCalendar currentCalendar] isDateInToday:aDate] || [[NSCalendar currentCalendar] isDateInTomorrow:aDate]) {
        aCell.detailTextLabel.text = [aCell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" • %@", aEpisodeString]];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
