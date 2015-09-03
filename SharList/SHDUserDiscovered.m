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
@property (strong, atomic) UILabel *percentStringLabel;
@property (strong, atomic) UILabel *percentStringDescLabel;
@property (strong, atomic) UILabel *facebookFriendNameLabel;
@property (strong, atomic) UILabel *discoverNewLabel;
@property (strong, atomic) UIImageView *favoriteIconIV;

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
    
    CGFloat percentWidthContent = (600.0/640.0);
    CGFloat posX = (screenWidth - (screenWidth * percentWidthContent)) / 2;

    self.frame = CGRectMake(0, 0,
                            screenWidth * percentWidthContent, (screenWidth * percentWidthContent) / 1.612903226);
    self.initFrame = self.frame;
    self.frame = CGRectMake(posX, 0,
                            screenWidth * percentWidthContent, (screenWidth * percentWidthContent) / 1.612903226);
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    CGFloat thumbsMediasViewPercent = (158.0/372.0);
    
    UIScrollView *thumbsMediasContainerView = [[UIScrollView alloc] initWithFrame:
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
        thumbMedia.backgroundColor = [UIColor clearColor];
        thumbMedia.tag = 100 + idx;
        
        thumbMedia.layer.cornerRadius = 5.0f;
        thumbMedia.layer.masksToBounds = YES;
        thumbMedia.contentMode = UIViewContentModeScaleAspectFill;
        
        [thumbsMediasContainerView addSubview:thumbMedia];
    }
    
    UIView *thumbsMediasContainerLastView = [thumbsMediasContainerView.subviews lastObject];
    thumbsMediasContainerView.contentSize = CGSizeMake(CGRectGetMaxX(thumbsMediasContainerLastView.frame), CGRectGetHeight(thumbsMediasContainerLastView.frame));
    

    UIImageView *userDiscoveredFbProfileImg = [[UIImageView alloc] initWithFrame:self.initFrame];
    userDiscoveredFbProfileImg.contentMode = UIViewContentModeScaleAspectFill;
    userDiscoveredFbProfileImg.clipsToBounds = YES;
    userDiscoveredFbProfileImg.tag = SHDDiscoverProfileImgTag;
    [self insertSubview:userDiscoveredFbProfileImg atIndex:0];

    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = userDiscoveredFbProfileImg.bounds;
    overlayLayer.name = @"overlayLayerImgProfile";
    overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.70].CGColor;
    [userDiscoveredFbProfileImg.layer insertSublayer:overlayLayer atIndex:0];
    
    self.discoveryTypeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 40, 40)];
    self.discoveryTypeIcon.tintColor = [UIColor whiteColor];
    self.discoveryTypeIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:self.discoveryTypeIcon];
    
    
    UIView *infosView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.discoveryTypeIcon.frame) + 5, 8, 0, 0)];
    infosView.backgroundColor = [UIColor clearColor];
    [self addSubview:infosView];
    

    
    self.discoveryTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.discoveryTimeLabel.textColor = [UIColor whiteColor];
    self.discoveryTimeLabel.text = @"new";
    [self.discoveryTimeLabel sizeToFit];
    self.discoveryTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    
    self.discoveryTimeLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.discoveryTimeLabel.frame), CGRectGetHeight(self.discoveryTimeLabel.frame));
    [infosView addSubview:self.discoveryTimeLabel];
    
    
    
    self.facebookFriendNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.facebookFriendNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
    self.facebookFriendNameLabel.textColor = [UIColor whiteColor];
    self.facebookFriendNameLabel.text = @"Install Gentoo";
    self.facebookFriendNameLabel.hidden = YES;
    [self.facebookFriendNameLabel sizeToFit];
    self.facebookFriendNameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.facebookFriendNameLabel.frame) - 3, CGRectGetWidth(self.facebookFriendNameLabel.frame), CGRectGetHeight(self.facebookFriendNameLabel.frame));
    [infosView addSubview:self.facebookFriendNameLabel];
    
    UIView *infosViewLastView = [infosView.subviews lastObject];
    infosView.frame = CGRectMake(CGRectGetMinX(infosView.frame) + 5, 8, CGRectGetMaxX(infosViewLastView.frame), CGRectGetMaxY(infosViewLastView.frame));
    infosView.center = CGPointMake(infosView.center.x, self.discoveryTypeIcon.center.y);
    
    [self displayExtraInfos];
    
    return self;
}

- (void) setDiscoveryTime:(NSDate*)discoveryTime
{
    NSDateFormatter *discoveryDateFormatter = [NSDateFormatter new];
    discoveryDateFormatter.timeStyle = kCFDateFormatterShortStyle;
    
    self.discoveryTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [discoveryDateFormatter stringFromDate:discoveryTime]];
    [self.discoveryTimeLabel sizeToFit];
}

- (void) setUserDiscoveredName:(NSString*)fbid
{
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:fbid]) {
        
        NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", fbid]];
        self.facebookFriendNameLabel.text = [[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
        self.facebookFriendNameLabel.hidden = NO;
    } else {
        self.facebookFriendNameLabel.hidden = YES;
    }
}

- (void) displayExtraInfos
{
    CGFloat percentStringLabelPercentY = (130.0/372.0); //143
    self.percentStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.initFrame) * percentStringLabelPercentY, 300, 120)];
    self.percentStringLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
    self.percentStringLabel.textColor = [UIColor whiteColor];
    self.percentStringLabel.text = @"42 %";
    [self.percentStringLabel sizeToFit];
    self.percentStringLabel.hidden = YES;
    self.percentStringLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.percentStringLabel];
    
    self.percentStringDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.percentStringDescLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    self.percentStringDescLabel.textColor = [UIColor whiteColor];
    self.percentStringDescLabel.text = @"de la liste à découvrir";
    [self.percentStringDescLabel sizeToFit];
    self.percentStringDescLabel.backgroundColor = [UIColor clearColor];
    self.percentStringDescLabel.frame = CGRectMake(CGRectGetMaxX(self.initFrame) - CGRectGetWidth(self.percentStringDescLabel.frame) - 10,
                                              CGRectGetMaxY(self.percentStringLabel.frame) - 0,
                                              CGRectGetWidth(self.percentStringDescLabel.frame),
                                              CGRectGetHeight(self.percentStringDescLabel.frame));
    [self addSubview:self.percentStringDescLabel];
    
    self.percentStringLabel.frame = CGRectMake(CGRectGetMinX(self.percentStringDescLabel.frame),
                                          CGRectGetMinY(self.percentStringLabel.frame),
                                          CGRectGetWidth(self.percentStringLabel.frame),
                                          CGRectGetHeight(self.percentStringLabel.frame));
    
    self.discoverNewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.percentStringLabel.frame), 40, 40)];
    self.discoverNewLabel.backgroundColor = [UIColor clearColor];
    self.discoverNewLabel.layer.cornerRadius = 2.0f;
    self.discoverNewLabel.clipsToBounds = YES;
    self.discoverNewLabel.text = NSLocalizedString(@"new discovery", nil);
    self.discoverNewLabel.textAlignment = NSTextAlignmentCenter;
    self.discoverNewLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    [self.discoverNewLabel sizeToFit];
    self.discoverNewLabel.hidden = YES;
    self.discoverNewLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.discoverNewLabel];
    
    self.favoriteIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"]];
    self.favoriteIconIV.frame = CGRectMake(CGRectGetMaxX(self.initFrame) - 30,
                                           CGRectGetMinY(self.discoveryTypeIcon.frame),
                                           17, 17);
    self.favoriteIconIV.hidden = YES;
    [self addSubview:self.favoriteIconIV];
}

- (void) setStatistics:(CGFloat)percent
{
    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *percentString = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:percent]];

    self.percentStringLabel.text = percentString;
    self.percentStringLabel.hidden = NO;
    [self.percentStringLabel sizeToFit];
}

- (void) newDiscoverManager:(BOOL)isSeen {
    self.discoverNewLabel.hidden = isSeen;
}

- (void) favoriteDiscoverManager:(BOOL)isFavorite {
    self.favoriteIconIV.hidden = !isFavorite;
}

// Set thumbs posters at bottom of view
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
    NSString *imgSize = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) ? @"w92" : @"w154";
    
    UIView *thumbsMediasContainerView = (UIView*)[self viewWithTag:SHDDiscoverMediaThumbsTag];
    
    dispatch_group_t finishLoadThumbs = dispatch_group_create();
    
    for (int idx = 0; idx < mediasArray.count; idx++) {
        UIImageView *thumbMedia = (UIImageView*) [thumbsMediasContainerView viewWithTag:100+idx];
        
        if (idx >= 4) {
            break;
        }
        
        thumbMedia.hidden = NO;
        thumbMedia.opaque = YES;
        
        NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
        
        NSString *mediaImdbID = [mediasArray objectAtIndex:idx];
        
        dispatch_group_enter(finishLoadThumbs);
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbFind
                               withParameters:@{@"id": mediaImdbID, @"language": userLanguage, @"external_source": @"imdb_id"}
                             andResponseBlock:^(id responseObject, NSError *error) {
            if(!error){
                if ([responseObject[@"movie_results"] count] > 0) {
                    imgName = [responseObject valueForKeyPath:@"movie_results.poster_path"][0];
                } else if ([responseObject[@"tv_results"] count] > 0) {
                    imgName = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
                } else {
                    return;
                }

                // Kind of promise
                dispatch_group_leave(finishLoadThumbs);
                
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
    
    dispatch_group_notify(finishLoadThumbs, dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            thumbsMediasContainerView.alpha = 1;
        }];

    });
}

- (UIView*) mediaThumbsContainer {
    return [self viewWithTag:SHDDiscoverMediaThumbsTag];
}

- (void) setProfileImage:(NSString*)fbId
{
    UIImageView *userDiscoveredFbProfileImg = (UIImageView*)[self viewWithTag:SHDDiscoverProfileImgTag];
    
    NSString *fbMetUserString = fbId;
    NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", fbMetUserString,(int)self.initFrame.size.width, (int)self.initFrame.size.height];

    [userDiscoveredFbProfileImg setImageWithURL:
     [NSURL URLWithString:metUserFBImgURL]
                               placeholderImage:[UIImage imageNamed:@"TrianglesBG"]]; //10204498235807141
}

@end
