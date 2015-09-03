//
//  SHDMediaDatas.m
//  SharList
//
//  Created by Jean-Louis Danielo on 21/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "SHDMediaDatas.h"


@interface SHDMediaDatas()


@property (strong, atomic) NSString *trailerAPILink;

@property (strong, atomic) NSDictionary *settingsDict;

@end

@implementation SHDMediaDatas

dispatch_group_t dFinishLoadDatas;


- (instancetype) initWithMedia:(NSDictionary *)mediaObj
{
    self = [super init];
    if ( !self ) return nil;
    
    
    self.mediaDatas = [NSMutableDictionary new];
    self.type = mediaObj[@"type"];
    self.imdbId = mediaObj[@"imdbID"];
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    self.settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    [[JLTMDbClient sharedAPIInstance] setAPIKey:@THEMOVIEDBAPIKEY];
    
    dFinishLoadDatas = dispatch_group_create();
    
    [self fetchGlobalInfosForObj:mediaObj];
    [self numberOfIterationsAmongDiscoveries];
    [self fetchShoundAPIDatas];
    [self fetchFacebookFriends];
    
    self.isInCurrentUserList = [self currentUserInfosAboutMedia];
    
    dispatch_group_notify(dFinishLoadDatas, dispatch_get_main_queue(), ^{
        if (self.delegate != nil) {
            [self.delegate datasAreReady];
        }
    });

    return self;
}

- (BOOL) currentUserInfosAboutMedia
{
    NSPredicate *discoveriesWoCUser = [NSPredicate predicateWithFormat:@"fbId == %@",
                                       [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    Discovery *currentUser = [Discovery MR_findFirstWithPredicate:discoveriesWoCUser];
    
    NSDictionary *currentUserLikes = [NSKeyedUnarchiver unarchiveObjectWithData:currentUser.likes];
    
    NSMutableArray *linearizeCurrentUserLikes = [NSMutableArray new];
    for (NSString *keyName in [currentUserLikes filterKeysForNullObj]) {
        [linearizeCurrentUserLikes addObjectsFromArray:[[currentUserLikes objectForKey:keyName] valueForKey:@"imdbID"]];
    }

    return [linearizeCurrentUserLikes containsObject:self.imdbId];
}

- (void) fetchGlobalInfosForObj:(NSDictionary*)mediaObj
{
    dispatch_group_enter(dFinishLoadDatas);
    NSDictionary *queryParams;
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0], *apiLink;
    
    if ([self.type isEqualToString:@"movie"]) {
        apiLink = kJLTMDbMovie;
        queryParams = @{@"id": mediaObj[@"imdbID"], @"language": userLanguage};
        self.trailerAPILink = kJLTMDbMovieVideos;
    } else if ([self.type isEqualToString:@"serie"]) {
        apiLink = kJLTMDbFind;
        self.trailerAPILink = kJLTMDbTVVideos;
        queryParams =  @{@"id": mediaObj[@"imdbID"], @"language": userLanguage, @"external_source": @"imdb_id"};
    } else {
        NSLog(@"error");
    }
    
    [[JLTMDbClient sharedAPIInstance] GET:apiLink withParameters:queryParams andResponseBlock:^(id responseObject, NSError *error) {
        if(!error){
            if ([responseObject[@"tv_results"] count] != 0) {
                NSDictionary *tvQueryParams = @{@"id": [responseObject valueForKeyPath: @"tv_results.id"][0], @"language": userLanguage};
                [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTV withParameters:tvQueryParams andResponseBlock:^(id responseObject, NSError *error) {
                    if(!error){
                        NSDictionary *serieObj = @{
                                                   @"id": responseObject[@"id"],
                                                   @"original_name": responseObject[@"original_name"],
                                                   @"name": responseObject[@"name"],
                                                   @"genres": responseObject[@"genres"],
                                                   @"poster_path": responseObject[@"poster_path"],
                                                   @"description": responseObject[@"overview"],
                                                   @"website": responseObject[@"homepage"],
                                                   @"number_of_seasons": responseObject[@"number_of_seasons"]
                        };
                        
                        [self.mediaDatas addEntriesFromDictionary:serieObj];
                        [self getNextEpisodeDate];
                        [self fetchTrailerIDForMediaWithId:responseObject[@"id"]];
                        dispatch_group_leave(dFinishLoadDatas);
                    }
                }];
            } else {
                NSDictionary *movieObj = @{
                        @"id": responseObject[@"id"],
                        @"original_name": responseObject[@"original_title"],
                        @"name": responseObject[@"title"],
                        @"genres": responseObject[@"genres"],
                        @"poster_path": responseObject[@"poster_path"],
                        @"description": responseObject[@"overview"],
                        @"website": responseObject[@"homepage"]
                };
                [self.mediaDatas addEntriesFromDictionary:movieObj];
                [self fetchTrailerIDForMediaWithId:responseObject[@"id"]];
                dispatch_group_leave(dFinishLoadDatas);
            }
        }
    }];
}

- (void) fetchTrailerIDForMediaWithId:(NSString*)idMedia
{
    dispatch_group_enter(dFinishLoadDatas);
    [[JLTMDbClient sharedAPIInstance] GET:self.trailerAPILink withParameters:@{@"id": idMedia} andResponseBlock:^(id responseObject, NSError *error) {
        NSString *trailerID = ([responseObject[@"results"] count] > 0) ? responseObject[@"results"][0][@"key"] : @"";
        [self.mediaDatas setObject:trailerID forKey:@"yt_id"];
        dispatch_group_leave(dFinishLoadDatas);
    }];
}

- (void) numberOfIterationsAmongDiscoveries
{
    NSPredicate *discoveriesWoCUser = [NSPredicate predicateWithFormat:@"fbId != %@",
                                          [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    NSArray *meetings = [Discovery MR_findAllWithPredicate:discoveriesWoCUser];
    NSUInteger numberOfApparitionAmongDiscoveries = 0;
    for (Discovery *discovery in meetings) {
        NSDictionary *userTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[discovery likes]] mutableCopy];
        id userTasteForType = [userTaste objectForKey:self.type];
        if (![[userTasteForType valueForKey:@"imdbID"] isEqual:[NSNull null]]) {
            if ([[userTasteForType valueForKey:@"imdbID"] containsObject:self.imdbId]) {
                numberOfApparitionAmongDiscoveries++;
            }
        }
    }
    
    CGFloat iterationAmongDiscoveriesPercent = ((float)numberOfApparitionAmongDiscoveries / (float)meetings.count);
    
    if (isnan(iterationAmongDiscoveriesPercent) || isinf(iterationAmongDiscoveriesPercent)) {
        iterationAmongDiscoveriesPercent = 0.0f;
    }
    [self.mediaDatas setObject:[NSNumber numberWithFloat:iterationAmongDiscoveriesPercent]
                        forKey:@"nb_iterations"];
}

- (void) getNextEpisodeDate
{
    dispatch_group_enter(dFinishLoadDatas);
    NSDictionary *tvSeasonQueryParams = @{@"id": [self.mediaDatas valueForKeyPath:@"id"],
                                          @"season_number": [self.mediaDatas valueForKeyPath:@"number_of_seasons"]};
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    // Fake date for show ended or no episodes currently
    NSDate *nullDate = [dateFormatter dateFromString:@"1992-02-29"];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTVSeasons withParameters:tvSeasonQueryParams andResponseBlock:^(id responseObject, NSError *error) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        NSDate *closestDate = nil;
        
        NSUInteger episodeNumber = 0;
        for (NSDictionary* episode in responseObject[@"episodes"]) {
            if ([episode objectForKey:@"air_date"] != (id)[NSNull null]) {
                NSString *dateString = (NSString *)[episode objectForKey:@"air_date"];
                
                NSDate *episodeDate = [dateFormatter dateFromString:dateString];
                episodeNumber++;
                // Episode is passed
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
       
        self.nextEpisodeDate = (closestDate != nil) ? closestDate : nullDate;
        // Hey, hey, hey... coding everyday
        self.nextEpisodeRef = [NSString stringWithFormat:@"S%02iE%02li", [tvSeasonQueryParams[@"season_number"] intValue], (unsigned long)episodeNumber];
        
        [self.mediaDatas setObject:self.nextEpisodeDate forKey:@"next_episode_date"];
        [self.mediaDatas setObject:self.nextEpisodeRef forKey:@"next_episode_ref"];
        dispatch_group_leave(dFinishLoadDatas);
    }];
}

-  (void) fetchShoundAPIDatas
{
    dispatch_group_enter(dFinishLoadDatas);

    NSString *shoundAPIPath = [[self.settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media"];
    
    NSDictionary *parameters = @{@"imdbId": self.imdbId};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager.requestSerializer setValue:@"PRcOqcephWVp" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *obj = @{
                                   @"store_links": [responseObject valueForKeyPath:@"response.storeLinks"],
                                   @"comments_count": [NSNumber numberWithInteger:[[responseObject valueForKeyPath:@"response.commentsCount"] integerValue]]
                                   };
             [self.mediaDatas addEntriesFromDictionary:obj];
             dispatch_group_leave(dFinishLoadDatas);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error viewDidLoad - : %@", error);
             dispatch_group_leave(dFinishLoadDatas);
         }];
}


- (void) fetchFacebookFriends
{
    dispatch_group_enter(dFinishLoadDatas);
    
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
        [self.mediaDatas setObject:@[]
                            forKey:@"media_facebook_friends"];
        dispatch_group_leave(dFinishLoadDatas);
    }
    
    NSArray *facebookFriends = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"];
    NSString *paramsString = @"";
    NSMutableArray *paramsArray = [NSMutableArray new];
    for (NSString *friendId in facebookFriends) {
        [paramsArray addObject:[NSString stringWithFormat:@"friends[]=%@", friendId]];
    }
    paramsString = [paramsArray componentsJoinedByString:@"&"];
    paramsString = [paramsString stringByAppendingString:[NSString stringWithFormat:@"&imdbId=%@", self.imdbId]];
    
    NSString *urlString = [[self.settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/friends?"];
    urlString = [urlString stringByAppendingString:paramsString];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager.requestSerializer setValue:@"PRcOQcEpSPVp" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:urlString parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self.mediaDatas setObject:[responseObject[@"response"] valueForKey:@"fbId"] forKey:@"media_facebook_friends"];
             
             dispatch_group_leave(dFinishLoadDatas);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"error viewDidLoad - : %@", error);
             [self.mediaDatas setObject:@[]
                                 forKey:@"media_facebook_friends"];
             dispatch_group_leave(dFinishLoadDatas);
         }];
}


@end
