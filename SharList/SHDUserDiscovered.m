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

- (id) init
{
    self = [super init];
    if ( !self ) return nil;
    
    const CGRect screenRect = [[UIScreen mainScreen] bounds];
    const CGFloat screenWidth = screenRect.size.width;
    //    const CGFloat screenHeight  = screenRect.size.height;
    
    self.currentUser = [Discovery MR_findFirstByAttribute:@"fbId"
                                                withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    self.currentUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.currentUser likes]] mutableCopy];
    
    
//    self.discoveredUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
    //
    CGFloat percentWidthContent = (300.0/screenWidth);
    
    self.frame = CGRectMake(0, 0, screenWidth * percentWidthContent, (screenWidth * percentWidthContent) / 1.612903226);
    self.initFrame = self.frame;
    self.backgroundColor = [UIColor colorWithRed:(223.0/255.0) green:(239.0/255.0) blue:(245.0/255.0) alpha:0.95];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
//    CGFloat thumbsMediasViewPercent = (158.0/372.0);
//    
//    UIView *thumbsMediasView = [[UIView alloc] initWithFrame:
//                                CGRectMake(0,
//                                           0,
//                                           CGRectGetWidth(self.initFrame),
//                                           thumbsMediasViewPercent * CGRectGetHeight(self.initFrame))];
//    thumbsMediasView.tag = SHDDiscoverMediaThumbsTag;
//    thumbsMediasView.backgroundColor = [UIColor colorWithRed:(223.0/255.0) green:(239.0/255.0) blue:(245.0/255.0) alpha:0.95];
//    thumbsMediasView.frame = CGRectMake(0, CGRectGetMaxY(self.initFrame) - CGRectGetHeight(thumbsMediasView.frame), CGRectGetWidth(thumbsMediasView.frame), CGRectGetHeight(thumbsMediasView.frame));
//    
//    [self addSubview:thumbsMediasView];
    
    //
    //
    ////    self.center = CGPointMake((CGRectGetWidth(self.superview.frame) - CGRectGetWidth(self.initFrame)) / 2, self.center.y);
    //
    //    [self setStatistics:[self calcPercentToDiscover]];
    //
    //
    //    UIImageView *userDiscoveredFbProfileImg = [[UIImageView alloc] initWithFrame:self.initFrame];
    //    userDiscoveredFbProfileImg.contentMode = UIViewContentModeScaleAspectFill;
    //    userDiscoveredFbProfileImg.clipsToBounds = YES;
    //
    //    [userDiscoveredFbProfileImg setImageWithURL:
    //     [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", [userDiscovered fbId], (int)self.initFrame.size.width, (int)self.initFrame.size.height]]
    //                  placeholderImage:[UIImage imageNamed:@"TrianglesBG"]]; //10204498235807141
    //    [self insertSubview:userDiscoveredFbProfileImg atIndex:0];
    //
    //    UIVisualEffect *blurEffect;
    //    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //
    //    UIVisualEffectView *visualEffectView;
    //    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //    visualEffectView.frame = userDiscoveredFbProfileImg.bounds;
    //    [userDiscoveredFbProfileImg addSubview:visualEffectView];
    //
    //    CALayer *overlayLayer = [CALayer layer];
    //    overlayLayer.frame = userDiscoveredFbProfileImg.frame;
    //    overlayLayer.name = @"overlayLayerImgMedia";
    //    overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.66].CGColor;
    ////    [userDiscoveredFbProfileImg.layer insertSublayer:overlayLayer atIndex:0];
    //
    //    // remove after
    //    self.initFrame = CGRectMake(10, 10, screenWidth * percentWidthContent, (screenWidth * percentWidthContent) / 1.612903226);
    //
    //    UIImageView *discoveryTypeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 40, 40)];
    //    discoveryTypeIcon.image = [[UIImage imageNamed:@"locationMeetingIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    discoveryTypeIcon.tintColor = [UIColor whiteColor];
    //    discoveryTypeIcon.backgroundColor = [UIColor clearColor];
    //    [self addSubview:discoveryTypeIcon];
    //
    //    if ([self.userDiscovered isRandomDiscover]) {
    //        // locationMeetingIcon randomMeetingIcon
    //    }
    //
    //    UIView *infosView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(discoveryTypeIcon.frame) + 5, 8, 0, 0)];
    //    infosView.backgroundColor = [UIColor clearColor];
    //    [self addSubview:infosView];
    //
    //    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[self.userDiscovered fbId]]) {
    //        NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [self.userDiscovered fbId]]];
    //
    //        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    //        nameLabel.text = [[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
    //        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
    //        nameLabel.textColor = [UIColor whiteColor];
    //        [nameLabel sizeToFit];
    //        [infosView addSubview:nameLabel];
    //    }
    //
    //
    //
    //    NSDateFormatter *discoveryDateFormatter = [NSDateFormatter new];
    //    discoveryDateFormatter.timeStyle = kCFDateFormatterShortStyle;
    //
    //    UIView *infosViewLastView = [infosView.subviews lastObject];
    //
    //
    //    UILabel *discoveryTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    //    discoveryTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [discoveryDateFormatter stringFromDate:[self.userDiscovered lastDiscovery]]];
    //    discoveryTimeLabel.textColor = [UIColor whiteColor];
    //    discoveryTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    //    [discoveryTimeLabel sizeToFit];
    //    discoveryTimeLabel.frame = CGRectMake(0, CGRectGetMaxY(infosViewLastView.frame), CGRectGetWidth(discoveryTimeLabel.frame), CGRectGetHeight(discoveryTimeLabel.frame));
    //    [infosView addSubview:discoveryTimeLabel];
    
    return self;
}

- (void) setStatistics:(CGFloat)percent
{
    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *percentString = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:percent]];
    
    CGFloat percentStringLabelPercentY = (130.0/372.0); //143
    
    UILabel *percentStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.initFrame) * percentStringLabelPercentY, 300, 120)];
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
    percentStringDescLabel.frame = CGRectMake(CGRectGetMaxX(self.initFrame) - CGRectGetWidth(percentStringDescLabel.frame) - 10,
                                              CGRectGetMaxY(percentStringLabel.frame) - 0,
                                              CGRectGetWidth(percentStringDescLabel.frame),
                                              CGRectGetHeight(percentStringDescLabel.frame));
    [self addSubview:percentStringDescLabel];
    
    percentStringLabel.frame = CGRectMake(CGRectGetMinX(percentStringDescLabel.frame),
                                          CGRectGetMinY(percentStringLabel.frame),
                                          CGRectGetWidth(percentStringLabel.frame),
                                          CGRectGetHeight(percentStringLabel.frame));
    
    
    if (!self.currentUser.isSeen) {
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

//- (UIView*) mediaThumbs
//{
//    self.discoveredUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
//    
//    UIView *thumbsMediasView = [[UIView alloc] initWithFrame:CGRectZero];
//    
//    CGFloat thumbMediaPercent = (143.0/600.0);
//    CGFloat thumbMediaWidth = thumbMediaPercent * CGRectGetWidth(self.initFrame);
//    
//    CGFloat thumbMediaMarginWidth = (7.0/600.0)  * CGRectGetWidth(self.initFrame);
//    CGFloat thumbMediaMarginWidth2 = (5.0/600.0)  * CGRectGetWidth(self.initFrame);
//    
//    NSMutableArray *linearizeDiscoveredUserLikes = [NSMutableArray new];
//    // We linearize the likes datas of obth users it will be easier for the next operations
//    for (NSString *keyName in [self.discoveredUserLikes filterKeysForNullObj]) {
//        [linearizeDiscoveredUserLikes addObjectsFromArray:[[self.discoveredUserLikes objectForKey:keyName] valueForKey:@"imdbID"]];
//    }
//    
//    NSMutableArray *linearizeCurrentUserLikes = [NSMutableArray new];
//    for (NSString *keyName in [self.currentUserLikes filterKeysForNullObj]) {
//        [linearizeCurrentUserLikes addObjectsFromArray:[[self.currentUserLikes objectForKey:keyName] valueForKey:@"imdbID"]];
//    }
//    
//    // We want only the datas which are not in current user list of likes
//    NSMutableArray *toDiscoverMediaArray = [NSMutableArray arrayWithArray:linearizeDiscoveredUserLikes];
//    [toDiscoverMediaArray removeObjectsInArray:linearizeCurrentUserLikes];
//    
//    NSUInteger limitThumbs = 4;
//    NSUInteger randomIndex = 0;
//    
//    // We wants now datas in common with current user
//    // We wants to fill the array
//    [linearizeDiscoveredUserLikes removeObjectsInArray:toDiscoverMediaArray];
//    for (NSUInteger idx = 0; idx < limitThumbs && idx < linearizeDiscoveredUserLikes.count; idx++) {
//        if (linearizeDiscoveredUserLikes.count >= 9) {
//            randomIndex = arc4random() % [linearizeDiscoveredUserLikes count];
//        } else {
//            randomIndex = idx;
//        }
//        
//        [toDiscoverMediaArray addObject:[linearizeDiscoveredUserLikes objectAtIndex:randomIndex]];
//    }
//    
//    // We remove duplicate
//    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:toDiscoverMediaArray];
//    toDiscoverMediaArray = [[orderedSet array] mutableCopy];
//    
//    __block NSString *imgName;
//    __block NSString *imgDistURL;
//    NSString *imgSize = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) ? @"w92" : @"w185";
//    
//    for (int idx = 0; idx < toDiscoverMediaArray.count; idx++) {
//        if (idx >= 4) {
//            break;
//        }
//        
//        UIImageView *thumbMedia = [[UIImageView alloc] initWithFrame:CGRectMake(thumbMediaMarginWidth + (idx * thumbMediaWidth) + (idx * thumbMediaMarginWidth2), thumbMediaMarginWidth, thumbMediaWidth, thumbMediaWidth)];
//        thumbMedia.backgroundColor = [UIColor blackColor];
//        
//        thumbMedia.layer.cornerRadius = 5.0f;
//        thumbMedia.layer.masksToBounds = YES;
//        thumbMedia.contentMode = UIViewContentModeScaleAspectFill;
//        
//        NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
//        [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
//        
//        NSString *mediaImdbID = [toDiscoverMediaArray objectAtIndex:idx];
//        
//        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbFind withParameters:@{@"id": mediaImdbID, @"language": userLanguage, @"external_source": @"imdb_id"} andResponseBlock:^(id responseObject, NSError *error) {
//            if(!error){
//                if ([responseObject[@"movie_results"] count] > 0) {
//                    imgName = [responseObject valueForKeyPath:@"movie_results.poster_path"][0];
//                } else if ([responseObject[@"tv_results"] count] > 0) {
//                    imgName = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
//                } else {
//                    return;
//                }
//                
//                imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/%@%@", imgSize, imgName];
//                [thumbMedia setImageWithURL:
//                 [NSURL URLWithString:imgDistURL]
//                           placeholderImage:[UIImage imageNamed:@"TrianglesBG"]];
//            }
//        }];
//        
//        [thumbsMediasView addSubview:thumbMedia];
//    }
//    
//    UIView *thumbsMediasLastView = [[thumbsMediasView subviews] lastObject];
//    thumbsMediasView.frame = CGRectMake(0, 0,
//                                        CGRectGetWidth(thumbsMediasLastView.frame),
//                                        CGRectGetHeight(thumbsMediasLastView.frame));
//    
//    return thumbsMediasView;
//}

- (UIView*) setMediaThumbs:(NSDictionary*)userDiscoveredMedias{
    NSLog(@"userDiscoveredMedias : %@", userDiscoveredMedias);
    UIView *thumbsMediasView = [[UIView alloc] initWithFrame:CGRectZero];
    
    CGFloat thumbMediaPercent = (143.0/600.0);
    CGFloat thumbMediaWidth = thumbMediaPercent * CGRectGetWidth(self.initFrame);
    
    CGFloat thumbMediaMarginWidth = (7.0/600.0)  * CGRectGetWidth(self.initFrame);
    CGFloat thumbMediaMarginWidth2 = (5.0/600.0)  * CGRectGetWidth(self.initFrame);
    
    NSMutableArray *linearizeDiscoveredUserLikes = [NSMutableArray new];
    // We linearize the likes datas of obth users it will be easier for the next operations
    for (NSString *keyName in [userDiscoveredMedias filterKeysForNullObj]) {
        [linearizeDiscoveredUserLikes addObjectsFromArray:[[userDiscoveredMedias objectForKey:keyName] valueForKey:@"imdbID"]];
    }
    
    NSMutableArray *linearizeCurrentUserLikes = [NSMutableArray new];
    for (NSString *keyName in [self.currentUserLikes filterKeysForNullObj]) {
        [linearizeCurrentUserLikes addObjectsFromArray:[[self.currentUserLikes objectForKey:keyName] valueForKey:@"imdbID"]];
    }
    
    // We want only the datas which are not in current user list of likes
    NSMutableArray *toDiscoverMediaArray = [NSMutableArray arrayWithArray:linearizeDiscoveredUserLikes];
    [toDiscoverMediaArray removeObjectsInArray:linearizeCurrentUserLikes];
    
    NSUInteger limitThumbs = 4;
    NSUInteger randomIndex = 0;
    
    // We wants now datas in common with current user
    // We wants to fill the array
    [linearizeDiscoveredUserLikes removeObjectsInArray:toDiscoverMediaArray];
    for (NSUInteger idx = 0; idx < limitThumbs && idx < linearizeDiscoveredUserLikes.count; idx++) {
        if (linearizeDiscoveredUserLikes.count >= 9) {
            randomIndex = arc4random() % [linearizeDiscoveredUserLikes count];
        } else {
            randomIndex = idx;
        }
        
        [toDiscoverMediaArray addObject:[linearizeDiscoveredUserLikes objectAtIndex:randomIndex]];
    }
    
    // We remove duplicate
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:toDiscoverMediaArray];
    toDiscoverMediaArray = [[orderedSet array] mutableCopy];
    
    __block NSString *imgName;
    __block NSString *imgDistURL;
    NSString *imgSize = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) ? @"w92" : @"w185";
    
    for (int idx = 0; idx < toDiscoverMediaArray.count; idx++) {
        if (idx >= 4) {
            break;
        }
        
        UIImageView *thumbMedia = [[UIImageView alloc] initWithFrame:CGRectMake(thumbMediaMarginWidth + (idx * thumbMediaWidth) + (idx * thumbMediaMarginWidth2), thumbMediaMarginWidth, thumbMediaWidth, thumbMediaWidth)];
        thumbMedia.backgroundColor = [UIColor blackColor];
        
        thumbMedia.layer.cornerRadius = 5.0f;
        thumbMedia.layer.masksToBounds = YES;
        thumbMedia.contentMode = UIViewContentModeScaleAspectFill;
        
        NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
        
        NSString *mediaImdbID = [toDiscoverMediaArray objectAtIndex:idx];
        
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
        
        [thumbsMediasView addSubview:thumbMedia];
    }
    
    UIView *thumbsMediasLastView = [[thumbsMediasView subviews] lastObject];
    thumbsMediasView.frame = CGRectMake(0, 0,
                                        CGRectGetWidth(thumbsMediasLastView.frame),
                                        CGRectGetHeight(thumbsMediasLastView.frame));
    
    
    return thumbsMediasView;
//    NSLog(@"%i", [[thumbsMediasView subviews] count]);
//    [self addSubview:thumbsMediasView];
}

- (CGFloat) calcPercentToDiscover
{
    NSDictionary *userMetLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
    
    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
    int commonTasteCount = 0;
    int currentUserNumberItems = 0;
    for (int i = 0; i < [[userMetLikes filterKeysForNullObj] count]; i++) {
        NSString *key = [[userMetLikes filterKeysForNullObj] objectAtIndex:i];
        if (![[self.currentUserLikes objectForKey:key] isEqual:[NSNull null]]) {
            currentUserTasteSet = [NSMutableSet setWithArray:[[self.currentUserLikes objectForKey:key] valueForKey:@"imdbID"]];
            
            currentUserNumberItems += [[userMetLikes objectForKey:key] count];
        }
        
        if (![[userMetLikes objectForKey:key] isEqual:[NSNull null]]) {
            currentUserMetTasteSet = [NSMutableSet setWithArray:[[userMetLikes objectForKey:key] valueForKey:@"imdbID"]];
        }
        
        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the objects that are in both sets
        
        NSArray* result = [currentUserMetTasteSet allObjects];
        
        commonTasteCount += result.count;
    }
    
    CGFloat notCommonLikesPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
    
    if (isnan(notCommonLikesPercent)) {
        notCommonLikesPercent = 0.0f;
    }
    
    // If the user has only 1% in common
    if (notCommonLikesPercent == (float)1) {
        notCommonLikesPercent = 1.0;
    }
    
    // substract 1 cause NSNumberFormatter for percent waits a value between (0 and 1)
    notCommonLikesPercent = 1 - notCommonLikesPercent;
    
    //    if (notCommonLikesPercent == 0) {
    //        self.alpha = .7;
    //    }
    
    return notCommonLikesPercent;
}


- (UILabel*) label {
    
    CGRect frame = CGRectMake(0, 0, 160, 50);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.tag = SHDDiscoverTimeLabelTag;
    
    return label;
}

- (UIView*) mediaThumbsContainer {
    CGFloat thumbsMediasViewPercent = (158.0/372.0);
    
    UIView *thumbsMediasView = [[UIView alloc] initWithFrame:
                                CGRectMake(0,
                                           0,
                                           CGRectGetWidth(self.initFrame),
                                           thumbsMediasViewPercent * CGRectGetHeight(self.initFrame))];
    thumbsMediasView.tag = SHDDiscoverMediaThumbsTag;
    thumbsMediasView.backgroundColor = [UIColor colorWithRed:(223.0/255.0) green:(239.0/255.0) blue:(245.0/255.0) alpha:0.95];
    thumbsMediasView.frame = CGRectMake(0, CGRectGetMaxY(self.initFrame) - CGRectGetHeight(thumbsMediasView.frame), CGRectGetWidth(thumbsMediasView.frame), CGRectGetHeight(thumbsMediasView.frame));
    
    return thumbsMediasView;
    [self addSubview:thumbsMediasView];
}

@end
