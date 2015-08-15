//
//  SHDUserDiscovered.m
//  SharList
//
//  Created by Jean-Louis Danielo on 14/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "SHDUserDiscovered.h"

@interface SHDUserDiscovered()

@property (nonatomic) CGRect initFrame;

@end

@implementation SHDUserDiscovered


- (id) initWithDatas:(Discovery*)userDiscovered
{
    self = [super init];
    if ( !self ) return nil;
    
    const CGRect screenRect = [[UIScreen mainScreen] bounds];
    const CGFloat screenWidth = screenRect.size.width;
    //    const CGFloat screenHeight  = screenRect.size.height;
    
    self.currentUser = [Discovery MR_findFirstByAttribute:@"fbId"
                                                withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    self.userDiscovered = userDiscovered;
    
    self.currentUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.currentUser likes]] mutableCopy];
    self.discoveredUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
    
    CGFloat percentWidthContent = (300.0/screenWidth);
    
    self.frame = CGRectMake(0, 0, screenWidth * percentWidthContent, (screenWidth * percentWidthContent) / 1.612903226);
    self.initFrame = self.frame;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGFloat thumbsMediasViewPercent = (158.0/372.0);
    
    UIView *thumbsMediasContainerView = [[UIView alloc] initWithFrame:
                                CGRectMake(0,
                                           0,
                                           CGRectGetWidth(self.initFrame),
                                           thumbsMediasViewPercent * CGRectGetHeight(self.initFrame))];
    thumbsMediasContainerView.backgroundColor = [UIColor colorWithRed:(223.0/255.0) green:(239.0/255.0) blue:(245.0/255.0) alpha:0.95];
    thumbsMediasContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.initFrame) - CGRectGetHeight(thumbsMediasContainerView.frame), CGRectGetWidth(thumbsMediasContainerView.frame), CGRectGetHeight(thumbsMediasContainerView.frame));
    thumbsMediasContainerView.tag = SHDDiscoverMediaThumbsTag;
//
    [self addSubview:thumbsMediasContainerView];
    
    
    CGFloat thumbMediaPercent = (143.0/600.0);
    CGFloat thumbMediaWidth = thumbMediaPercent * CGRectGetWidth(self.frame);
    
    CGFloat thumbMediaMarginWidth = (7.0/600.0)  * CGRectGetWidth(self.frame);
    CGFloat thumbMediaMarginWidth2 = (5.0/600.0)  * CGRectGetWidth(self.frame);
    
    for (int idx = 0; idx < 4; idx++) {
        if (idx >= 4) {
            break;
        }
        
        UIImageView *thumbMedia = [[UIImageView alloc] initWithFrame:CGRectMake(thumbMediaMarginWidth + (idx * thumbMediaWidth) + (idx * thumbMediaMarginWidth2), thumbMediaMarginWidth, thumbMediaWidth, thumbMediaWidth)];
        thumbMedia.backgroundColor = [UIColor blackColor];
        thumbMedia.tag = 100 + idx;
        
        thumbMedia.layer.cornerRadius = 5.0f;
        thumbMedia.layer.masksToBounds = YES;
        thumbMedia.contentMode = UIViewContentModeScaleAspectFill;
        
        [thumbsMediasContainerView addSubview:thumbMedia];
    }
    

    UIImageView *userDiscoveredFbProfileImg = [[UIImageView alloc] initWithFrame:self.initFrame];
    userDiscoveredFbProfileImg.contentMode = UIViewContentModeScaleAspectFill;
    userDiscoveredFbProfileImg.clipsToBounds = YES;
    userDiscoveredFbProfileImg.tag = SHDDiscoverProfileImgTag;
    [self insertSubview:userDiscoveredFbProfileImg atIndex:0];

    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = userDiscoveredFbProfileImg.frame;
    overlayLayer.name = @"overlayLayerImgMedia";
    overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75].CGColor;
    [userDiscoveredFbProfileImg.layer insertSublayer:overlayLayer atIndex:0];
    
    self.discoveryTypeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 40, 40)];
    self.discoveryTypeIcon.tintColor = [UIColor whiteColor];
    self.discoveryTypeIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:self.discoveryTypeIcon];
    
    
    UIView *infosView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.discoveryTypeIcon.frame) + 5, 8, 0, 0)];
    infosView.backgroundColor = [UIColor clearColor];
    [self addSubview:infosView];
    
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[self.userDiscovered fbId]]) {
        NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [self.userDiscovered fbId]]];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        nameLabel.text = [[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
        nameLabel.textColor = [UIColor whiteColor];
        [nameLabel sizeToFit];
        [infosView addSubview:nameLabel];
    }
  

    
    UIView *infosViewLastView = [infosView.subviews lastObject];
    
    
    self.discoveryTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    self.discoveryTimeLabel.textColor = [UIColor whiteColor];
    self.discoveryTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    
    self.discoveryTimeLabel.frame = CGRectMake(0, CGRectGetMaxY(infosViewLastView.frame), CGRectGetWidth(self.discoveryTimeLabel.frame), CGRectGetHeight(self.discoveryTimeLabel.frame));
    [infosView addSubview:self.discoveryTimeLabel];
    
    return self;
}

- (void) setDiscoveryTime:(NSDate*)discoveryTime
{
    NSDateFormatter *discoveryDateFormatter = [NSDateFormatter new];
    discoveryDateFormatter.timeStyle = kCFDateFormatterShortStyle;
    
    self.discoveryTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [discoveryDateFormatter stringFromDate:discoveryTime]];
    [self.discoveryTimeLabel sizeToFit];
}

- (void) displayExtraInfos
{
    CGFloat percentStringLabelPercentY = (130.0/372.0); //143
    UILabel *percentStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.initFrame) * percentStringLabelPercentY, 300, 120)];
    percentStringLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
    percentStringLabel.textColor = [UIColor whiteColor];
    percentStringLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:percentStringLabel];
}

- (void) setStatistics:(CGFloat)percent
{
    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *percentString = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:percent]];
    
    CGFloat percentStringLabelPercentY = (130.0/372.0); //143
    
    UILabel *percentStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) * percentStringLabelPercentY, 300, 120)];
    percentStringLabel.text = percentString;
    percentStringLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
    percentStringLabel.textColor = [UIColor whiteColor];
    percentStringLabel.backgroundColor = [UIColor clearColor];
    [percentStringLabel sizeToFit];
    [self addSubview:percentStringLabel];
    
    UILabel *percentStringDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
    percentStringDescLabel.text = percentString;
    percentStringDescLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    percentStringDescLabel.textColor = [UIColor whiteColor];
    percentStringDescLabel.text = @"de la liste à découvrir";
    [percentStringDescLabel sizeToFit];
    percentStringDescLabel.backgroundColor = [UIColor clearColor];
    percentStringDescLabel.frame = CGRectMake(CGRectGetMaxX(self.frame) - CGRectGetWidth(percentStringDescLabel.frame) - 10,
                                              CGRectGetMaxY(percentStringLabel.frame) - 0,
                                              CGRectGetWidth(percentStringDescLabel.frame),
                                              CGRectGetHeight(percentStringDescLabel.frame));
    [self addSubview:percentStringDescLabel];
    
    percentStringLabel.frame = CGRectMake(CGRectGetMinX(percentStringDescLabel.frame),
                                          CGRectGetMinY(percentStringLabel.frame),
                                          CGRectGetWidth(percentStringLabel.frame),
                                          CGRectGetHeight(percentStringLabel.frame));
    
    
    if (!self.userDiscovered.isSeen) {
        UILabel *newDiscoverLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(percentStringLabel.frame), 40, 40)];
        newDiscoverLabel.backgroundColor = [UIColor clearColor];
        newDiscoverLabel.layer.cornerRadius = 2.0f;
        newDiscoverLabel.clipsToBounds = YES;
        newDiscoverLabel.text = NSLocalizedString(@"new discovery", nil);
        newDiscoverLabel.textAlignment = NSTextAlignmentCenter;
        newDiscoverLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        [newDiscoverLabel sizeToFit];
        newDiscoverLabel.textColor = [UIColor whiteColor];
        [self addSubview:newDiscoverLabel];
    }
}

- (void) setMediaThumbs:(NSMutableArray*) mediasArray
{
//    return;
//    CGFloat thumbMediaPercent = (143.0/600.0);
//    CGFloat thumbMediaWidth = thumbMediaPercent * CGRectGetWidth(self.frame);
//    
//    CGFloat thumbMediaMarginWidth = (7.0/600.0)  * CGRectGetWidth(self.frame);
//    CGFloat thumbMediaMarginWidth2 = (5.0/600.0)  * CGRectGetWidth(self.frame);
    
    __block NSString *imgName;
    __block NSString *imgDistURL;
    NSString *imgSize = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) ? @"w92" : @"w185";
    
    UIView *thumbsMediasContainerView = (UIView*)[self viewWithTag:SHDDiscoverMediaThumbsTag];
    
    for (int idx = 0; idx < mediasArray.count; idx++) {
        UIImageView *thumbMedia = (UIImageView*) [thumbsMediasContainerView viewWithTag:100+idx];
        
        if (idx >= 4) {
            break;
        }
        
        thumbMedia.hidden = NO;
        
        NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
        
        NSString *mediaImdbID = [mediasArray objectAtIndex:idx];
        
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbFind withParameters:@{@"id": mediaImdbID, @"language": userLanguage, @"external_source": @"imdb_id"} andResponseBlock:^(id responseObject, NSError *error) {
            if(!error){
                if ([responseObject[@"movie_results"] count] > 0) {
                    imgName = [responseObject valueForKeyPath:@"movie_results.poster_path"][0];
                } else if ([responseObject[@"tv_results"] count] > 0) {
                    imgName = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
                } else {
                    return;
                }

                
                imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/%@%@", imgSize, imgName];
                [thumbMedia setImageWithURL:
                 [NSURL URLWithString:imgDistURL]
                           placeholderImage:[UIImage imageNamed:@"TrianglesBG"]];
            }
        }];
    }
    
    for (NSUInteger i = mediasArray.count; i < 4; i++) {
        UIImageView *thumbMedia = (UIImageView*) [thumbsMediasContainerView viewWithTag:100+i];
        thumbMedia.hidden = YES;
    }
}

- (UIView*) mediaThumbsContainer {
    return [self viewWithTag:SHDDiscoverMediaThumbsTag];
}

- (void) setProfileImage:(NSString*)fbId
{
    UIImageView *userDiscoveredFbProfileImg = (UIImageView*)[self viewWithTag:SHDDiscoverProfileImgTag];
    
    [userDiscoveredFbProfileImg setImageWithURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", fbId, (int)self.initFrame.size.width, (int)self.initFrame.size.height]]
                               placeholderImage:[UIImage imageNamed:@"TrianglesBG"]]; //10204498235807141
}

@end
