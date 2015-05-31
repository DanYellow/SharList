//
//  DetailsMediaViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "DetailsMediaViewController.h"


@interface DetailsMediaViewController ()

@property (strong, nonatomic) UserTaste *userTaste;

@end



#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation DetailsMediaViewController


#pragma mark - Tag List
// Tag list
// 1 : displayBuyView (blurred view)
// 2 : addMediaBtnItem
// 3 : addRemoveMediaLabel
// 4 : title label
// 5 : mediaLikeNumberLabel
// 6 : imgMedia
// 7 : buy button
// 8 : tutorialView
// 9 : errConnectionAlertView
// 10 : connectWithBSBtn
// 11 : mediaGenresLabel

// 400 - 410 : Buttons buy range
// 400 : Amazon
// 401 : iTunes

// Before page loading we hide the tabbar

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    CALayer *bottomBorderLayer = [self.navigationController.navigationBar.layer valueForKey:@"bottomBorder"];
    [bottomBorderLayer removeFromSuperlayer];
    [self.navigationController.navigationBar.layer setValue:nil forKey:@"bottomBorder"];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    NSArray* sublayers = [NSArray arrayWithArray:self.navigationController.navigationBar.layer.sublayers];
    for (CALayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"bottomBorderLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"detailsMediaTutorial"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"detailsMediaTutorial"];
        [self showTutorial];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [self.tabBarController.tabBar setHidden:NO];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.name = @"bottomBorderLayer";
    bottomBorder.frame = CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 1.0f);
    
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    
    // Init vars
    self.PhysicsAdded = NO;
    self.itunesIDString = @"";
    buyButtonsInitPositions = [NSMutableArray new];
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    pfPushManager = [[PFPushManager alloc] initForType:UpdateList];
    
    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.name = @"selfviewGradient";
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradient.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat imgMediaHeight = [self computeRatio:470 forDimension:screenHeight];
    
    UIView *infoMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    infoMediaView.backgroundColor = [UIColor clearColor];
    infoMediaView.opaque = NO;
    infoMediaView.hidden = NO;
    infoMediaView.tag = 2;
    
    UILabel *addRemoveMediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, 60, screenWidth - 5, 20)];
    addRemoveMediaLabel.textColor = [UIColor whiteColor];
    addRemoveMediaLabel.textAlignment = NSTextAlignmentRight;
    
    addRemoveMediaLabel.alpha = 0;
    addRemoveMediaLabel.hidden = YES;
    addRemoveMediaLabel.tag = 3;
    [infoMediaView insertSubview:addRemoveMediaLabel atIndex:10];
    

    
    self.userTaste = [UserTaste MR_findFirstByAttribute:@"fbid"
                                              withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    userTasteDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     [NSNull null], @"book",
                     [NSNull null], @"movie",
                     [NSNull null], @"serie",
                     nil];
    
    
    // This statement is hre for prevent empty user list
    // Because it corrupt the NSMutableDictionary
    // And you're not able to update it
    if ([NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] != nil) {
        userTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] mutableCopy];
    }
    
    //Navigationbarcontroller
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIBarButtonItem *addMediaToFavoriteBtnItem;
    
    // User has data of this type
    if ([[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] class] != [NSNull class]) {
        // This media is not among user list
        // Because imdbID's key is unique we check if this key is among user media list api key
        // Like the we are not screwed if we change api or CoreData'model structure
        if (![[[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] valueForKey:@"imdbID"] containsObject:self.mediaDatas[@"imdbID"]]) {
            self.Added = NO;
            addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
            addRemoveMediaLabel.text = NSLocalizedString(@"Added", nil);
        } else {
            self.Added = YES;
            addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
            addRemoveMediaLabel.text = NSLocalizedString(@"Deleted", nil);
        }
    } else {
        self.Added = NO;
        addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
        addRemoveMediaLabel.text = NSLocalizedString(@"Added", nil);
    }
    
//    UIBarButtonItem *messagesBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"listMessagesNavIcon@2x"]
//                                                                       style:UIBarButtonItemStylePlain
//                                                                      target:self
//                                                                      action:@selector(displayMessageForMediaWithId:)];
    

    if (![self connected]) {
        self.navigationItem.rightBarButtonItems = @[addMediaToFavoriteBtnItem];
    }
    

    [[JLTMDbClient sharedAPIInstance] setAPIKey:@"f09cf27014943c8114e504bf5fbd352b"];
    
    NSString *apiLink, *trailerApiLink;
    NSDictionary *queryParams;
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    __block NSString *trailerID = @"";

    // Tricky part
    // We used now themoviedb
    // But database still have ids from imdb and only movie in themoviedb uses them
    // and I don't have time / want now to fill the db w/ themoviedb's id
    if ([self.mediaDatas[@"type"] isEqualToString:@"movie"]) {
        apiLink = kJLTMDbMovie;
        queryParams = @{@"id": self.mediaDatas[@"imdbID"], @"language": userLanguage};
        trailerApiLink = kJLTMDbMovieTrailers;
    } else if ([self.mediaDatas[@"type"] isEqualToString:@"serie"] && ([self.mediaDatas[@"themoviedbID"] isEqualToString:@""] || ![self.mediaDatas objectForKey:@"themoviedbID"] || [[self.mediaDatas objectForKey:@"themoviedbID"] isEqualToString:@"(null)"])) {
        apiLink = kJLTMDbFind;
        trailerApiLink = kJLTMDbTVTrailers;
        queryParams =  @{@"id": self.mediaDatas[@"imdbID"], @"language": userLanguage, @"external_source": @"imdb_id"};
    } else if ([self.mediaDatas[@"type"] isEqualToString:@"serie"] && ![self.mediaDatas[@"themoviedbID"] isEqualToString:@""]  && [self.mediaDatas objectForKey:@"themoviedbID"]) {
        apiLink = kJLTMDbTV;
        queryParams =  @{@"id": self.mediaDatas[@"themoviedbID"], @"language": userLanguage};
        trailerApiLink = kJLTMDbTVTrailers;
    } else {
        return;
    }

    [[JLTMDbClient sharedAPIInstance] GET:apiLink withParameters:queryParams andResponseBlock:^(id responseObject, NSError *error) {
        if(!error){
            // We made a second query for tv show to get datas from imdb
            if (responseObject[@"tv_results"] != nil && [responseObject[@"tv_results"] count] != 0) {
                NSDictionary *tvQueryParams = @{@"id": [responseObject valueForKeyPath: @"tv_results.id"][0], @"language": userLanguage};
                [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTV withParameters:tvQueryParams andResponseBlock:^(id responseObject, NSError *error) {
                    if(!error){
                        [self setMediaViewForData:responseObject];
                        [self getTrailerAndNextEpisodeDateForResponse:responseObject];
                    }
                }];
            // It's a serie directly from themoviedbapi
            } else if([responseObject objectForKey:@"number_of_seasons"] != nil) {
                [self setMediaViewForData:responseObject];
                [self getTrailerAndNextEpisodeDateForResponse:responseObject];
            } else {
                [self setMediaViewForData:responseObject];
                [[JLTMDbClient sharedAPIInstance] GET:trailerApiLink withParameters:@{@"id": self.mediaDatas[@"imdbID"]} andResponseBlock:^(id responseObject, NSError *error) {
                    if ([responseObject valueForKeyPath:@"youtube.source"] != nil && [[responseObject valueForKeyPath:@"youtube.source"] count] > 0) {
                        trailerID = [responseObject valueForKeyPath:@"youtube.source"][0];
                        if (![trailerID isEqualToString:@""]) {
                            [self displayTrailerButtonForId:trailerID];
                        }
                    }
                }];
            }
        } else {
            [self noInternetConnexionAlert];
        }
    }];

    // If the user is not connected to Internet it can still add a card to his account
//    if (![self connected]) {
//        self.navigationItem.rightBarButtonItems = @[addMediaToFavoriteBtnItem];
//    }
    
    CGFloat mediaTitleLabelY = [self computeRatio:236 forDimension:imgMediaHeight];
    
    UILabel *mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, mediaTitleLabelY, screenWidth - 22, 55)];
    mediaTitleLabel.text = self.mediaDatas[@"name"];
    mediaTitleLabel.textColor = [UIColor whiteColor];
    mediaTitleLabel.textAlignment = NSTextAlignmentLeft;
    mediaTitleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    mediaTitleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    mediaTitleLabel.layer.shadowRadius = 2.5;
    mediaTitleLabel.layer.shadowOpacity = 0.75;
    mediaTitleLabel.clipsToBounds = NO;
    mediaTitleLabel.layer.masksToBounds = NO;
    mediaTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    mediaTitleLabel.numberOfLines = 0;
    mediaTitleLabel.backgroundColor = [UIColor clearColor];
    mediaTitleLabel.opaque = NO;
    mediaTitleLabel.alpha = .85f;
    mediaTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0];
    mediaTitleLabel.tag = 4;
    [mediaTitleLabel sizeToFit];
    
    [infoMediaView insertSubview:mediaTitleLabel atIndex:9];
    
    // This NSDict will be used to set id to local media
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.mediaDatas];
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media"];
    
    NSDictionary *parameters = @{@"imdbId": self.mediaDatas[@"imdbID"]};

    NSURL *baseURL = [NSURL URLWithString:@"https://api.themoviedb.org/3/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager.requestSerializer setValue:@"mince" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSNumber *mediaLikeNumber = [responseObject valueForKeyPath:@"response.hits"];
              
              NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
              [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
              
              if (!self.mediaDatas[@"id"]) {
                  [tempDict setObject:(NSString *)[responseObject valueForKeyPath:@"response.id"] forKey:@"id"];
                  self.mediaDatas = tempDict;
              }
              
              // If the name of the media change in the database, the user keep the last name in the db
              if (responseObject[@"name"] != nil && ![self.mediaDatas[@"name"] isEqualToString:(NSString *)responseObject[@"name"]]) {
                  [tempDict setObject:(NSString *)[responseObject valueForKeyPath:@"response.name"] forKey:@"name"];
                  self.mediaDatas = tempDict;
              }
              
//              NSDecimalNumber *amountNumber = [NSDecimalNumber decimalNumberWithString:[responseObject valueForKeyPath:@"response.hits"]];
              NSString *numberString = [numberFormatter stringFromNumber:mediaLikeNumber];

              if ([mediaLikeNumber integerValue] > 1) {
                  self.numberLikesString = numberString;
              }
              
              self.itunesIDString = [responseObject valueForKeyPath:@"response.itunesId"];
              
              UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
              [buyButton addTarget:self action:@selector(showBuyScreen) forControlEvents:UIControlEventTouchUpInside]; //
              buyButton.tag = 7;
              [buyButton setTitle:[NSLocalizedString(@"buy", nil) uppercaseString] forState:UIControlStateNormal];
              buyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
              buyButton.frame = CGRectMake(0, screenHeight + 50, screenWidth, 50);
              buyButton.backgroundColor = [UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f];
              [buyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:(22.0f/255.0f) green:(22.0f/255.0f) blue:(22.0f/255.0f) alpha:1.0f]] forState:UIControlStateHighlighted];
              
              [buyButton setImage:[UIImage imageNamed:@"cart-icon"] forState:UIControlStateNormal];
              [buyButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
              [buyButton setTitleColor:[UIColor colorWithRed:(114.0/255.0) green:(117.0/255.0) blue:(121.0/255.0) alpha:1.0f]
                              forState:UIControlStateHighlighted];
              [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
              
              // There is no link to itunes
              if ([self.itunesIDString length] != 0) {
                  [infoMediaView insertSubview:buyButton atIndex:42];
                  
                  [UIView animateWithDuration:0.4 delay:0.0
                                      options: UIViewAnimationOptionCurveEaseOut
                                   animations:^{
                                       buyButton.frame = CGRectSetPos( buyButton.frame, 0, screenHeight - 50 );
                                   }
                                   completion:nil];
              }
              
              [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
              
              
              NSNumber *numberMessages = [NSNumber numberWithInteger:[[responseObject valueForKeyPath:@"response.commentsCount"] integerValue]];
              
              UIButton *messagesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
              [messagesBtn addTarget:self action:@selector(displayMessageForMediaWithId:) forControlEvents:UIControlEventTouchUpInside];
              [messagesBtn setTitle:[numberFormatter stringFromNumber:numberMessages] forState:UIControlStateNormal];
              messagesBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
              [messagesBtn setImage:[[UIImage imageNamed:@"listMessagesNavIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                           forState:UIControlStateNormal];
              messagesBtn.frame = CGRectMake(0, 0, 55, 24);
              messagesBtn.backgroundColor = [UIColor clearColor];
              [messagesBtn setTitleColor:[UIColor colorWithRed:(114.0/255.0) green:(117.0/255.0) blue:(121.0/255.0) alpha:1.0f] forState:UIControlStateHighlighted];
              messagesBtn.imageEdgeInsets = UIEdgeInsetsMake(0, messagesBtn.titleLabel.frame.size.width, 0, -messagesBtn.titleLabel.frame.size.width - 5);
              messagesBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -messagesBtn.imageView.frame.size.width, 3, messagesBtn.imageView.frame.size.width + 10);
              messagesBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
              
              UIBarButtonItem *messagesBarBtn = [[UIBarButtonItem alloc] initWithCustomView:messagesBtn];
              
              self.navigationItem.rightBarButtonItems = @[addMediaToFavoriteBtnItem, messagesBarBtn];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@", error);
    }];
    

    [self.view insertSubview:infoMediaView atIndex:1];
    
    // We display the BS part only if the device's user iPhone is in French
    if ([userLanguage isEqualToString:@"fr"] && [self.mediaDatas[@"type"] isEqualToString:@"serie"]) {
        NSString *BSUserToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"BSUserToken"];
        if (BSUserToken != nil || [BSUserToken isKindOfClass:[NSNull class]]) {
            [self connectWithBSAccount:BSUserToken];
        }
    }
    
    [self displayNumberOfIterationAmongDiscoveriesForView:infoMediaView];
   
    
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [loadingIndicator startAnimating];
    
    [self.view insertSubview:loadingIndicator atIndex:2];
    
    // <----
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showPoster)];
    leftEdgeGesture.edges = UIRectEdgeRight;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
    
    // ---->
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMediaDetails:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGesture];
}

- (void) displayNumberOfIterationAmongDiscoveriesForView:(UIView*) aContainerView
{
    
    NSPredicate *facebookFriendsFilter = [NSPredicate predicateWithFormat:@"fbid != %@",
                                          [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:facebookFriendsFilter];
    
    NSUInteger numberOfApparitionAmongDiscoveries = 0;
    for (UserTaste *user in meetings) {
        NSDictionary *userTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[user taste]] mutableCopy];
        id userTasteForType = [userTaste objectForKey:[self.mediaDatas valueForKey:@"type"]];
        if (![[userTasteForType valueForKey:@"imdbID"] isEqual:[NSNull null]]) {
            if ([[userTasteForType valueForKey:@"imdbID"] containsObject:self.mediaDatas[@"imdbID"]]) {
                numberOfApparitionAmongDiscoveries++;
            }
        }
    }
    
    // This label shows the number of iteration of the card currently shown among user's discoverties
    UILabel *numberOfIterationAmongDiscoveriesLabel = [UILabel new];
    numberOfIterationAmongDiscoveriesLabel.frame = CGRectMake(0, screenHeight - 83, screenWidth, 20);
    numberOfIterationAmongDiscoveriesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    
    CGFloat iterationAmongDiscoveriesPercent = ((float)numberOfApparitionAmongDiscoveries / (float)meetings.count);
    
    if (isnan(iterationAmongDiscoveriesPercent) || isinf(iterationAmongDiscoveriesPercent)) {
        iterationAmongDiscoveriesPercent = 0.0f;
    }
    
    if (iterationAmongDiscoveriesPercent == 0) {
        NSString *localizeKey = @"Present in no discovery";
        numberOfIterationAmongDiscoveriesLabel.text = NSLocalizedString(localizeKey, nil);
    } else {
        NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
        [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        NSString *percentApparition = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:iterationAmongDiscoveriesPercent]];
        
        NSMutableAttributedString *NbrDiscoveriesAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Present of %@ discoveries", nil), percentApparition] attributes:nil];
        
        NSRange hellStringRange = [[NbrDiscoveriesAttrString string] rangeOfString:[NSString stringWithFormat:NSLocalizedString(@"p %@ discoveries", nil), percentApparition]];
        
        [NbrDiscoveriesAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] range:NSMakeRange(hellStringRange.location, hellStringRange.length)];
        
        numberOfIterationAmongDiscoveriesLabel.attributedText = NbrDiscoveriesAttrString;
    }
    
    numberOfIterationAmongDiscoveriesLabel.textColor = [UIColor whiteColor];
    numberOfIterationAmongDiscoveriesLabel.textAlignment = NSTextAlignmentCenter;
    
    [aContainerView addSubview:numberOfIterationAmongDiscoveriesLabel];
}

- (void) getTrailerAndNextEpisodeDateForResponse:(NSDictionary*)responseObject
{
    __block NSString *trailerID = @"";
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTVTrailers withParameters:@{@"id": [responseObject valueForKeyPath:@"id"]} andResponseBlock:^(id responseObject, NSError *error) {
        // We check if there is a video called "trailer"
        // if yes we take it
        // else we take the first video
        if ([[responseObject valueForKeyPath:@"results"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"Trailer"]] != nil && [[responseObject valueForKeyPath:@"results"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"Trailer"]].count > 0 ) {
            trailerID = [[[responseObject valueForKeyPath:@"results"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @"Trailer"]] valueForKeyPath:@"key"][0];
        } else if([[responseObject valueForKeyPath:@"results"] count] > 0) {
            trailerID = [responseObject valueForKeyPath:@"results.key"][0];
        }
        
        if (![trailerID isEqualToString:@""]) {
            [self displayTrailerButtonForId:trailerID];
        }
    }];
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
        
        [self displayLabelForNextOrLastEpisodeForDate:dateForEpisode
                                  andSeasonForEpisode:[NSString stringWithFormat:@"S%02iE%02i", [tvSeasonQueryParams[@"season_number"] intValue], episodeNumber]];

    }];
}

#pragma mark - Overlay views

- (void) showTutorial
{
    self.navigationItem.hidesBackButton = YES;
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGRect biggerRect = CGRectMake(0, 0, screenWidth, screenHeight);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];

    int radius = 23.0;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(screenWidth - 50, 18.0, 2.0 * radius, 2.0 * radius) cornerRadius:radius];
    [maskPath appendPath:circlePath];
    
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setFillColor:[[UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f] CGColor]];
    
    
    UIView *tutorialView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    tutorialView.backgroundColor = [UIColor colorWithRed:(18.0/255.0f) green:(33.0f/255.0f) blue:(49.0f/255.0f) alpha:.989f];
    tutorialView.layer.mask = maskWithHole;
    tutorialView.tag = 8;
    tutorialView.alpha = .25;
    tutorialView.opaque = NO;
    [self.view insertSubview:tutorialView atIndex:4];
    
    [UIView animateWithDuration:0.35 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tutorialView.alpha = 1.0;
                     }
                     completion:nil];
    

    // TUTORIAL VIEW
    UITextView *tutFavsMessageTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 40, 90)];
    tutFavsMessageTV.text = NSLocalizedString(@"tutFavsMessage", nil);
    tutFavsMessageTV.textColor = [UIColor whiteColor];
    tutFavsMessageTV.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    tutFavsMessageTV.textAlignment = NSTextAlignmentCenter;
    tutFavsMessageTV.backgroundColor = [UIColor clearColor];
    [tutFavsMessageTV sizeToFit];
    tutFavsMessageTV.center = CGPointMake(self.view.center.x, self.view.center.y);
    [tutorialView addSubview:tutFavsMessageTV];
    
    UIButton *endTutorial = [UIButton buttonWithType:UIButtonTypeCustom];
    [endTutorial addTarget:self action:@selector(hideTutorial) forControlEvents:UIControlEventTouchUpInside];
    [endTutorial setTitle:[NSLocalizedString(@"gotit", nil) uppercaseString] forState:UIControlStateNormal];
    endTutorial.frame = CGRectMake(0, screenHeight - 150, screenWidth, 49);
    endTutorial.tintColor = [UIColor whiteColor];
    [endTutorial setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [endTutorial setTitleColor:[UIColor colorWithWhite:1.0 alpha:.50] forState:UIControlStateHighlighted];
    endTutorial.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    [tutorialView addSubview:endTutorial];
}

- (void) showBuyScreen
{
    // We don't need uinavigationcontroller so...
    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIView *displayBuyView = [[UIView alloc] initWithFrame:self.view.bounds];
    displayBuyView.tag = 1;
    displayBuyView.hidden = NO;
    displayBuyView.alpha = .25f;
    displayBuyView.backgroundColor = [UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f];
    
    
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage: [self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = .85f;
    [bluredImageView setFrame:displayBuyView.frame];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = bluredImageView.bounds;
    
    [bluredImageView addSubview:visualEffectView];
    
    [displayBuyView addSubview:bluredImageView];
    
    BOOL doesContain = [self.view.subviews containsObject:(UIView*)[self.view viewWithTag:1]];
    UIView *displayBuyViewAlias = (UIView*)[self.view viewWithTag:1];
    if (doesContain == YES) {
        displayBuyViewAlias.hidden = NO;
    } else {
        [self.view addSubview:displayBuyView];
    }
    
    [UIView animateWithDuration:0.4 delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         displayBuyView.alpha = 1;
                         displayBuyViewAlias.alpha = 1;
                     }
                     completion:nil];
    
    
    UILabel *titleBuyMedia = [[UILabel alloc] initWithFrame:CGRectMake(((screenWidth - [self computeRatio:574 forDimension:screenWidth]) / 2), [self computeRatio:86 forDimension:screenHeight], [self computeRatio:574 forDimension:screenWidth], 16.0f)];
    titleBuyMedia.textColor = [UIColor whiteColor];
    titleBuyMedia.backgroundColor = [UIColor clearColor];
    titleBuyMedia.opaque = NO;
    titleBuyMedia.lineBreakMode = NSLineBreakByWordWrapping;
    titleBuyMedia.font = [UIFont fontWithName:@"HelveticaNeue" size:19.0f];
    
    NSMutableAttributedString *typeMeetingAttrString = [[NSMutableAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"buy %@", nil), self.mediaDatas[@"name"]] uppercaseString] attributes: nil];
    
    NSString *stringToHighlight = [NSLocalizedString(@"buy", nil) uppercaseString];
    NSRange r = [[typeMeetingAttrString string] rangeOfString:stringToHighlight];
    [typeMeetingAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:19.0] range:NSMakeRange(r.location, r.length)];
    
    titleBuyMedia.attributedText = typeMeetingAttrString;
    
    
    titleBuyMedia.textAlignment = NSTextAlignmentCenter;
    titleBuyMedia.numberOfLines = 0;
    titleBuyMedia.lineBreakMode = NSLineBreakByWordWrapping;
    [titleBuyMedia heightToFit];
    
    [displayBuyView addSubview:titleBuyMedia];
    
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica" size:18.0f];
    CGSize buttonSize = CGSizeMake([self computeRatio:574 forDimension:screenWidth], 41.0f);
    CGPoint buttonPos = CGPointMake(((screenWidth - [self computeRatio:574 forDimension:screenWidth]) / 2), [self computeRatio:190 forDimension:screenHeight]);
    
    
    UIColor *amazonOrange = [UIColor colorWithRed:1 green:(124.0f/255.0f) blue:(2.0f/255.0f) alpha:1.0f];
    
    ShopButton *amazonBuyButton = [ShopButton buttonWithType:UIButtonTypeCustom];
    amazonBuyButton.tag = 400;
    [amazonBuyButton addTarget:self action:@selector(openStore:) forControlEvents:UIControlEventTouchUpInside];
    [amazonBuyButton setTitle:[@"Amazon" uppercaseString] forState:UIControlStateNormal];
    [amazonBuyButton setTitleColor:amazonOrange forState:UIControlStateNormal];
    amazonBuyButton.titleLabel.font = buttonFont;
    amazonBuyButton.frame = CGRectMake(buttonPos.x, buttonPos.y + 30, buttonSize.width, buttonSize.height);
    amazonBuyButton.backgroundColor = [UIColor clearColor];
    amazonBuyButton.layer.borderColor = amazonOrange.CGColor;
    amazonBuyButton.layer.borderWidth = 2.0f;
//    [displayBuyView addSubview:amazonBuyButton];
    
    
    
//    CGFloat itunesBuyButtonPosY = amazonBuyButton.frame.origin.y + amazonBuyButton.frame.size.height + (38/2);
    UIColor *itunesGray = [UIColor colorWithRed:(166.0f/255.0f) green:(166.0f/255.0f) blue:(166.0f/255.0f) alpha:1.0f];
    UIColor *itunesGrayHighlight = [UIColor colorWithRed:(133.0f/255.0f) green:(133.0f/255.0f) blue:(133.0f/255.0f) alpha:1.0f];
    
    ShopButton *itunesBuyButton = [ShopButton buttonWithType:UIButtonTypeCustom];
    itunesBuyButton.tag = 401;
    [itunesBuyButton addTarget:self action:@selector(openStore:) forControlEvents:UIControlEventTouchUpInside];
    [itunesBuyButton setTitle:[@"itunes" uppercaseString] forState:UIControlStateNormal];
    itunesBuyButton.titleLabel.font = buttonFont;
    [itunesBuyButton setTitleColor:itunesGray forState:UIControlStateNormal];
    [itunesBuyButton setTitleColor:itunesGrayHighlight forState:UIControlStateHighlighted];
    itunesBuyButton.frame = CGRectMake(buttonPos.x, buttonPos.y + 30, buttonSize.width, buttonSize.height);
    //CGRectMake(buttonPos.x, itunesBuyButtonPosY, buttonSize.width, buttonSize.height);
    itunesBuyButton.backgroundColor = [UIColor clearColor];
    itunesBuyButton.layer.borderColor = itunesGray.CGColor;
    itunesBuyButton.layer.borderWidth = 2.0f;
    
    [displayBuyView addSubview:itunesBuyButton];
    
    
    
    
    CGRect lineFrame = CGRectMake(0, 18, 35, 4);
    
    
    UIButton *closeBuyScreenWindowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBuyScreenWindowBtn.frame = CGRectMake([self computeRatio:250 forDimension:screenWidth], screenHeight - [self computeRatio:116 forDimension:screenHeight], 50, 50);
    [closeBuyScreenWindowBtn addTarget:self action:@selector(hideBuyScreen) forControlEvents:UIControlEventTouchUpInside];
    closeBuyScreenWindowBtn.backgroundColor = [UIColor clearColor];
    closeBuyScreenWindowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    closeBuyScreenWindowBtn.layer.borderWidth = 1.0f;
    closeBuyScreenWindowBtn.layer.cornerRadius = 25;
    closeBuyScreenWindowBtn.layer.masksToBounds = YES;
    [closeBuyScreenWindowBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.4]] forState:UIControlStateHighlighted];
    closeBuyScreenWindowBtn.center = CGPointMake(self.view.center.x, closeBuyScreenWindowBtn.frame.origin.y);
    [displayBuyView addSubview:closeBuyScreenWindowBtn];
    
    UIView *lineRight = [[UIView alloc] initWithFrame:lineFrame];
    lineRight.backgroundColor = [UIColor whiteColor];
    lineRight.center = CGPointMake(closeBuyScreenWindowBtn.frame.size.width / 2, closeBuyScreenWindowBtn.frame.size.height / 2);
    lineRight.transform = CGAffineTransformMakeRotation(DegreesToRadians(-45));
    lineRight.userInteractionEnabled = NO;
    [closeBuyScreenWindowBtn addSubview:lineRight];
    
    UIView *lineLeft = [[UIView alloc] initWithFrame:lineFrame];
    lineLeft.backgroundColor = [UIColor whiteColor];
    lineLeft.userInteractionEnabled = NO;
    lineLeft.center = CGPointMake(closeBuyScreenWindowBtn.frame.size.width / 2, closeBuyScreenWindowBtn.frame.size.height / 2);
    lineLeft.transform = CGAffineTransformMakeRotation(DegreesToRadians(45));
    [closeBuyScreenWindowBtn addSubview:lineLeft];
    
    
    // Create array of all shop buttons one time only
    if (self.isPhysicsAdded == NO) {
        for (ShopButton *shopButton in displayBuyView.subviews) {
            if ([shopButton isKindOfClass:[ShopButton class]]) {
                [buyButtonsInitPositions addObject:[NSValue valueWithCGRect:shopButton.frame]];
            }
        }
    }
}


- (void) setMediaViewForData:(NSDictionary*)data
{
    themovieDBID = data[@"id"];

    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];

    UIImageView *imgMedia = [UIImageView new];
    NSURL *imgMediaURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://image.tmdb.org/t/p/w396%@", data[@"poster_path"]]];
    
    [imgMedia setImageWithURL:imgMediaURL
             placeholderImage:[UIImage imageNamed:@"TrianglesBG"]];
    imgMedia.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    imgMedia.contentMode = UIViewContentModeScaleAspectFill;
    imgMedia.clipsToBounds = YES;
    imgMedia.alpha = 0;
    imgMedia.tag = 6;
    [self.view insertSubview:imgMedia belowSubview:infoMediaView];
    

    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = imgMedia.frame;
    overlayLayer.name = @"overlayLayerImgMedia";
    overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.83].CGColor;
    [imgMedia.layer insertSublayer:overlayLayer atIndex:0];
    
    CABasicAnimation *overlayAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    overlayAlphaAnim.fromValue = @0;
    overlayAlphaAnim.toValue   = @1;
    overlayAlphaAnim.duration = 0.42;
    overlayAlphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [overlayLayer addAnimation:overlayAlphaAnim forKey:@"overlayAnimation"];


    UILabel *mediaTitleLabel = (UILabel*)[self.view viewWithTag:4];
    
    CGFloat mediaDescriptionWidthPercentage = 82.0;
    CGFloat mediaDescriptionWidth = roundf((screenWidth * mediaDescriptionWidthPercentage) / 100);
    CGFloat mediaDescriptionY = mediaTitleLabel.frame.origin.y + mediaTitleLabel.frame.size.height + 55;
    CGFloat mediaDescriptionHeight = (screenHeight * 45.00) / 100; //(280 * 100) / 568

    UITextView *mediaDescription = [[UITextView alloc] initWithFrame:CGRectMake(11, mediaDescriptionY, mediaDescriptionWidth, mediaDescriptionHeight)];
    if (data[@"overview"] == [NSNull null] || [data[@"overview"] isEqualToString:@""]) {
        // the movie db does not provide description for this media
        mediaDescription.text = NSLocalizedString(@"nodescription", nil);
    } else {
        mediaDescription.text = [data[@"overview"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    mediaDescription.textColor = [UIColor whiteColor];
    mediaDescription.editable = NO;
    mediaDescription.selectable = YES;
    mediaDescription.delegate = self;
    mediaDescription.showsHorizontalScrollIndicator = NO;
    mediaDescription.showsVerticalScrollIndicator = NO;
    mediaDescription.contentInset = UIEdgeInsetsMake(-10, 0, -10, 0);
    mediaDescription.textAlignment = NSTextAlignmentLeft;
    mediaDescription.backgroundColor = [UIColor clearColor];
    mediaDescription.alpha = 0;
    mediaDescription.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [infoMediaView addSubview:mediaDescription];
    
    
    [UIView animateWithDuration:0.3 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         mediaDescription.alpha = 1;
                         imgMedia.alpha = .95f;
                     }
                     completion:nil];
    
    
    NSString *genresString = NSLocalizedString(@"Genres", nil);
    
    NSMutableArray *genresArray = [NSMutableArray new];
    for (id genre in data[@"genres"]) {
        [genresArray addObject:genre[@"name"]];
    }
    
    genresString = [genresString stringByAppendingString:[genresArray componentsJoinedByString:@", "]];
    
    UILabel *mediaGenresLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, mediaDescriptionY - 34, screenWidth - 30, 25)];
    mediaGenresLabel.text = genresString; // Space + comma
    mediaGenresLabel.textColor = [UIColor colorWithWhite:.5 alpha:1];
    mediaGenresLabel.textAlignment = NSTextAlignmentLeft;
    mediaGenresLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    mediaGenresLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    mediaGenresLabel.layer.shadowRadius = 2.5;
    mediaGenresLabel.layer.shadowOpacity = 0.75;
    mediaGenresLabel.clipsToBounds = NO;
    mediaGenresLabel.numberOfLines = 0;
    mediaGenresLabel.backgroundColor = [UIColor clearColor];
    mediaGenresLabel.layer.masksToBounds = NO;
    mediaGenresLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    [mediaGenresLabel sizeToFit];
    mediaGenresLabel.tag = 11;
    mediaGenresLabel.alpha = (genresArray.count == 0) ? 0 : 1;
    [infoMediaView insertSubview:mediaGenresLabel atIndex:10];
    
    if ([self.numberLikesString integerValue] > 1) {
        // Like by X people
        NSString *mediaLikeNumberString = [NSString stringWithFormat:NSLocalizedString(@"Liked by %@ people", nil), self.numberLikesString];
        
        int mediaLikeNumberLabelY = mediaGenresLabel.frame.origin.y + mediaGenresLabel.frame.size.height - 6;
        
        UILabel *mediaLikeNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, mediaLikeNumberLabelY, screenWidth, 25)];
        mediaLikeNumberLabel.text = mediaLikeNumberString;
        mediaLikeNumberLabel.textColor = [UIColor colorWithWhite:.5 alpha:1];
        mediaLikeNumberLabel.textAlignment = NSTextAlignmentLeft;
        mediaLikeNumberLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        mediaLikeNumberLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        mediaLikeNumberLabel.layer.shadowRadius = 2.5;
        mediaLikeNumberLabel.layer.shadowOpacity = 0.75;
        mediaLikeNumberLabel.clipsToBounds = NO;
        mediaLikeNumberLabel.tag = 5;
        mediaLikeNumberLabel.backgroundColor = [UIColor clearColor];
        mediaLikeNumberLabel.layer.masksToBounds = NO;
        mediaLikeNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        [infoMediaView insertSubview:mediaLikeNumberLabel atIndex:11];
    }
    
    [loadingIndicator stopAnimating];
}



- (void) displayLabelForNextOrLastEpisodeForDate:(NSDate*)aDate andSeasonForEpisode:(NSString*)aEpisodeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSString *lastAirEpisodeDateString = [dateFormatter stringFromDate:aDate];
    
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    
    UILabel *mediaTitleLabel = (UILabel*)[infoMediaView viewWithTag:4];
    
    int lastEpisodeDateLabelY = mediaTitleLabel.frame.origin.y + mediaTitleLabel.frame.size.height - 5;
    
    UILabel *lastEpisodeDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, lastEpisodeDateLabelY, screenWidth - 30, 25)];
    
    lastEpisodeDateLabel.text = ([aDate timeIntervalSinceNow] > 0) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil), lastAirEpisodeDateString] : @"";
    // If an episode of this serie is release today we notify the user
    lastEpisodeDateLabel.text = ([[NSCalendar currentCalendar] isDateInToday:aDate]) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil), NSLocalizedString(@"release today", @"aujourd'hui !")] : lastEpisodeDateLabel.text;
    // If an episode of this serie is release tomorrow we notify the user
    lastEpisodeDateLabel.text = ([[NSCalendar currentCalendar] isDateInTomorrow:aDate]) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil),  NSLocalizedString(@"release tomorrow", @"demain !")] : lastEpisodeDateLabel.text;
    
    if ([aDate timeIntervalSinceNow] > 0 || [[NSCalendar currentCalendar] isDateInToday:aDate] || [[NSCalendar currentCalendar] isDateInTomorrow:aDate]) {
        lastEpisodeDateLabel.text = [lastEpisodeDateLabel.text stringByAppendingString:[NSString stringWithFormat:@" • %@", aEpisodeString]];
    }

    lastEpisodeDateLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    lastEpisodeDateLabel.textAlignment = NSTextAlignmentLeft;
    lastEpisodeDateLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    lastEpisodeDateLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    lastEpisodeDateLabel.layer.shadowRadius = 2.5;
    lastEpisodeDateLabel.layer.shadowOpacity = 0.75;
    lastEpisodeDateLabel.backgroundColor = [UIColor clearColor];
    lastEpisodeDateLabel.layer.masksToBounds = NO;
    lastEpisodeDateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
    
    [infoMediaView addSubview:lastEpisodeDateLabel];
}

#pragma mark - Custom Events

- (void) showPoster
{
    if ([[UIApplication sharedApplication] isStatusBarHidden] == YES) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self myLayerWithName:@"selfviewGradient" andParent:self.view].opacity = 0;
    
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    infoMediaView.alpha = 0;
    
    UIImageView *imgMedia = (UIImageView*)[self.view viewWithTag:6];
    imgMedia.contentMode = UIViewContentModeScaleAspectFit;
    
    CABasicAnimation *overlayAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    overlayAlphaAnim.fromValue = @1;
    overlayAlphaAnim.toValue   = @0;
    overlayAlphaAnim.duration = 0.21;
    overlayAlphaAnim.fillMode = kCAFillModeForwards;
    overlayAlphaAnim.removedOnCompletion = NO;
    overlayAlphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [[self myLayerWithName:@"overlayLayerImgMedia" andParent:imgMedia] addAnimation:overlayAlphaAnim forKey:@"overlayAnimation2"];
    
    UIButton *buyButton = (UIButton*)[self.view viewWithTag:7];
    [UIView animateWithDuration:0.4 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         buyButton.frame = CGRectSetPos( buyButton.frame, 0, screenHeight + 50 );
                         [self myLayerWithName:@"overlayLayerImgMedia" andParent:imgMedia].opacity = 0;
                     }
                     completion:nil];
}

- (void) showMediaDetails:(UISwipeGestureRecognizer*)sender
{
    if ([[UIApplication sharedApplication] isStatusBarHidden] == NO) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self myLayerWithName:@"selfviewGradient" andParent:self.view].opacity = 1;
    
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    infoMediaView.alpha = 1;
    
    UIImageView *imgMedia = (UIImageView*)[self.view viewWithTag:6];
    imgMedia.contentMode = UIViewContentModeScaleAspectFill;
    
    CABasicAnimation *overlayAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    overlayAlphaAnim.fromValue = @0;
    overlayAlphaAnim.toValue   = @1;
    overlayAlphaAnim.duration = 0.21;
    overlayAlphaAnim.fillMode = kCAFillModeForwards;
    overlayAlphaAnim.removedOnCompletion = NO;
    overlayAlphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [[self myLayerWithName:@"overlayLayerImgMedia" andParent:imgMedia] addAnimation:overlayAlphaAnim forKey:@"overlayAnimation"];
    
    UIButton *buyButton = (UIButton*)[self.view viewWithTag:7];
    [UIView animateWithDuration:0.4 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         buyButton.frame = CGRectSetPos( buyButton.frame, 0, screenHeight - 50 );
                     }
                     completion:nil];
}

- (void) displayTrailerButtonForId:(NSString*)aTrailerID
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    
    UIButton *seeTrailerMediaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    seeTrailerMediaBtn.frame = CGRectMake(screenWidth - 45, 80, 40, 40);
    seeTrailerMediaBtn.trailerID = aTrailerID;
    [seeTrailerMediaBtn addTarget:self action:@selector(seeTrailerMedia:) forControlEvents:UIControlEventTouchUpInside];
    [seeTrailerMediaBtn setTintColor:[UIColor whiteColor]];
    [seeTrailerMediaBtn setImage:[[UIImage imageNamed:@"trailer-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    seeTrailerMediaBtn.backgroundColor = [UIColor clearColor];
    seeTrailerMediaBtn.opaque = YES;
    [infoMediaView addSubview:seeTrailerMediaBtn];
}

- (void) seeTrailerMedia:(UIButton*)sender
{
    // Display the youtube video in the app
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:sender.trailerID];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
    
    // Rotate the view to see the trailer in landscape
    CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
    landscapeTransform = CGAffineTransformTranslate (landscapeTransform, +80.0, +100.0);
    
    [videoPlayerViewController.view setTransform:landscapeTransform];
}


/*
 * Display button to allow user to add / remove serie from it's BetaSeries account
 *
 *
 **/

- (UIButton*) displayBetaSeriesButtonForToken:(NSString*)BSUserToken
{
//    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    
    
    UIButton *connectWithBSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectWithBSBtn.tag = 10;
    
    [connectWithBSBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [connectWithBSBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [connectWithBSBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    [connectWithBSBtn setHighlighted:YES];
    
    connectWithBSBtn.trailerID = BSUserToken; // This is not a trailer but this extra property is useful
    connectWithBSBtn.frame = CGRectMake(screenWidth - 220, 81, 170, 40);
    connectWithBSBtn.backgroundColor = [UIColor clearColor];
    connectWithBSBtn.opaque = YES;
    connectWithBSBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    connectWithBSBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    connectWithBSBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];

    return connectWithBSBtn;
}

- (void) connectWithBSAccount:(NSString*)BSUserToken
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    UIButton *connectWithBSBtn = [self displayBetaSeriesButtonForToken:BSUserToken];
    [infoMediaView addSubview:connectWithBSBtn];
    
    // If user is not connected to bs we propose him to do it
//    if (BSUserToken != nil || BSUserToken != (id)[NSNull null]) {
        [self checkForIfUserHasMediaInBS:BSUserToken];
//    }
}

- (void) checkForIfUserHasMediaInBS:(NSString*)BSUserToken
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    UIButton *connectWithBSBtn = (UIButton*)[infoMediaView viewWithTag:10];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"a6843502959f" forHTTPHeaderField:@"X-BetaSeries-Key"];
    [manager.requestSerializer setValue:BSUserToken forHTTPHeaderField:@"X-BetaSeries-Token"];
    [manager GET:@"https://api.betaseries.com/shows/display" parameters:@{@"imdb_id" : self.mediaDatas[@"imdbID"], @"client_id" : @"8bc04c11b4c283b72a3fa48cfc6149f3"} success:^(AFHTTPRequestOperation *operation, id responseObject) {

        BOOL isAmongUserBSAccount = [[responseObject valueForKeyPath:@"show.in_account"] boolValue];
        // Add it
        if (!isAmongUserBSAccount) {
            [connectWithBSBtn setTitle:NSLocalizedString(@"BSAdd", nil) forState:UIControlStateNormal];
        } else {
            [connectWithBSBtn setTitle:NSLocalizedString(@"BSRemove", nil) forState:UIControlStateNormal];
        }
        
        self.AmongBSAccount = isAmongUserBSAccount;
        [connectWithBSBtn addTarget:self action:@selector(toggleAmongBSAccount:) forControlEvents:UIControlEventTouchUpInside];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) toggleAmongBSAccount:(UIButton*)sender
{
    sender.enabled = NO;
    [self toggleAddingMediaInUserBSAccountForUserToken:sender.trailerID
                                              forState:self.AmongBSAccount];
    
    self.AmongBSAccount = !self.AmongBSAccount;
}

/*
 * Allow to remove or add serie / movie to an user
 * aBool = YES -> Add Serie
 * aBool = NO -> Remove serie
 */

- (void) toggleAddingMediaInUserBSAccountForUserToken:(NSString*)BSUserToken forState:(BOOL)aBool
{
    self.navigationController.navigationItem.backBarButtonItem.enabled = NO;
    
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    UIButton *connectWithBSBtn = (UIButton*)[infoMediaView viewWithTag:10];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"a6843502959f" forHTTPHeaderField:@"X-BetaSeries-Key"];
    [manager.requestSerializer setValue:BSUserToken forHTTPHeaderField:@"X-BetaSeries-Token"];
    [manager.requestSerializer setValue:@"2.4" forHTTPHeaderField:@"X-BetaSeries-Version"];
    
    NSDictionary *URLParams = @{@"client_id" : @"8bc04c11b4c283b72a3fa48cfc6149f3"};
    NSString *urlAPI = [NSString stringWithFormat:@"http://api.betaseries.com/shows/show?imdb_id=%@", self.mediaDatas[@"imdbID"]];
    
    UIActivityIndicatorView *BSActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    BSActivityIndicator.hidesWhenStopped = YES;
    BSActivityIndicator.center = CGPointMake(0.0, connectWithBSBtn.bounds.size.height / 2);
    [BSActivityIndicator startAnimating];
    [connectWithBSBtn addSubview:BSActivityIndicator];
    
    
    if (aBool == NO) {
        // Add serie /
        [manager POST:urlAPI
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [connectWithBSBtn setTitle:NSLocalizedString(@"BSRemove", nil) forState:UIControlStateNormal];
                  [BSActivityIndicator stopAnimating];
                  [self performSelector:@selector(enableButtonWithDelay) withObject:nil afterDelay:1.75];
                  self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else {
        // remove serie /
        [manager DELETE:urlAPI
             parameters:URLParams
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [connectWithBSBtn setTitle:NSLocalizedString(@"BSAdd", nil) forState:UIControlStateNormal];
                    [BSActivityIndicator stopAnimating];
                    [self performSelector:@selector(enableButtonWithDelay) withObject:nil afterDelay:1.75];
                    self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);            
        }];
    }
}

- (void) enableButtonWithDelay {
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    UIButton *connectWithBSBtn = (UIButton*)[infoMediaView viewWithTag:10];
    
    connectWithBSBtn.enabled = YES;
}

- (void) addPhysics
{
//    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];

    
//    ShopButton *amazonBuyButton = (ShopButton*)[self.view viewWithTag:400];
    ShopButton *itunesBuyButton = (ShopButton*)[self.view viewWithTag:401];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    gravity = [[UIGravityBehavior alloc] initWithItems:@[itunesBuyButton]];
    collision = [[UICollisionBehavior alloc] initWithItems:@[itunesBuyButton]]; //itunesBuyButton
    collision.collisionDelegate = self;
    
    UIDynamicItemBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[itunesBuyButton]]; //itunesBuyButton
    itemBehaviour.elasticity = 0.9;
    itemBehaviour.allowsRotation = NO;
    itemBehaviour.density = .4000;
    
    [animator addBehavior:gravity];
    [animator addBehavior:itemBehaviour];
    [animator addBehavior:collision];
        
    self.PhysicsAdded = YES;
}

- (void) hideBuyScreen
{
    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];
    
//    ShopButton *amazonBuyButton = (ShopButton*)[self.view viewWithTag:400];
//    ShopButton *itunesBuyButton = (ShopButton*)[self.view viewWithTag:401];
    
    [self addPhysics];
    
    [UIView animateWithDuration:0.7 delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         displayBuyView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         displayBuyView.hidden = YES;
                         
                         // We need uinavigationcontroller so...
                         [self.navigationController setNavigationBarHidden:NO];

                         
                         NSUInteger count = 0;
                         // shopButton.frame = [(UIView *)[buyButtonsInitPositions objectAtIndex:count] frame];
                         // shopButton.frame = [[buyButtonsInitPositions objectAtIndex:count] CGRectValue];
                         for (ShopButton *shopButton in displayBuyView.subviews) {
                             if ([shopButton isKindOfClass:[ShopButton class]]) {
//                                 ShopButton *foo = (ShopButton *)[buyButtonsInitPositions objectAtIndex:count];
//                                 shopButton.frame = [(ShopButton *)[buyButtonsInitPositions objectAtIndex:count] frame];
                                 shopButton.frame = [[buyButtonsInitPositions objectAtIndex:count] CGRectValue];
                                 count++;
                             }
                         }
                         [animator removeAllBehaviors];
                     }];
}


- (void) hideTutorial
{
    self.navigationItem.hidesBackButton = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    UIView *tutorialView = (UIView*)[self.view viewWithTag:8];
    [UIView animateWithDuration:0.25 delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tutorialView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [tutorialView removeFromSuperview];
                     }];
}

#pragma mark - displayMessageForMediaWithId

- (void) displayMessageForMediaWithId:(UIBarButtonItem*)sender
{
    MediaCommentsViewController *mediaCommentsViewController = [MediaCommentsViewController new];
    mediaCommentsViewController.mediaId = self.mediaDatas[@"imdbID"];
    mediaCommentsViewController.userDiscoverId = self.userDiscoverId;
    
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:[self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = 0.99f;
    [bluredImageView setFrame:mediaCommentsViewController.view.frame];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = bluredImageView.bounds;
    
    [bluredImageView addSubview:visualEffectView];
    [mediaCommentsViewController.view addSubview:bluredImageView];
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"close", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mediaCommentsViewController];
    navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Saving user list

- (void) addAndRemoveMediaToList:(UIBarButtonItem*) sender
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    UILabel *addRemoveMediaLabel = (UILabel*)[infoMediaView viewWithTag:3];
    addRemoveMediaLabel.hidden = NO;
    addRemoveMediaLabel.alpha = 1;
    
    if ([sender.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
        sender.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        [self addMediaToUserList];
        addRemoveMediaLabel.text = NSLocalizedString(@"Added", nil);
    }else{
        sender.image = [UIImage imageNamed:@"meetingFavoriteUnselected"];
        [self removeMediaToUserList];
        addRemoveMediaLabel.text = NSLocalizedString(@"Deleted", nil);
    }
    
    [UIView animateWithDuration:0.6 delay:0.1
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         addRemoveMediaLabel.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         addRemoveMediaLabel.hidden = YES;
                     }];
}

- (void) addMediaToUserList
{
    // If the value of the key is nil so we create an new NSArray that contains the first elmt of the category
    if ([userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] == [NSNull null]) {
        NSArray *firstEntryToCategory = [[NSArray alloc] initWithObjects:self.mediaDatas, nil];
        [userTasteDict setObject:firstEntryToCategory forKey:[self.mediaDatas valueForKey:@"type"]];
    } else {
        NSMutableArray *updatedUserTaste = [[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] mutableCopy];
        [updatedUserTaste addObject:self.mediaDatas];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortedCategory = [updatedUserTaste sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];

        [userTasteDict removeObjectForKey:[self.mediaDatas valueForKey:@"type"]];
        [userTasteDict setObject:sortedCategory forKey:[self.mediaDatas valueForKey:@"type"]];
    }

    [self saveMediaUpdateForAdding:YES];
}

- (void) removeMediaToUserList
{
    NSMutableArray *updatedUserTaste = [[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] mutableCopy];
    [updatedUserTaste removeObjectsInArray:[updatedUserTaste filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imdbID == %@", [self.mediaDatas valueForKey:@"imdbID"]]]];

    [userTasteDict removeObjectForKey:[self.mediaDatas valueForKey:@"type"]];
    [userTasteDict setObject:updatedUserTaste forKey:[self.mediaDatas valueForKey:@"type"]];
    
    
    [self saveMediaUpdateForAdding:NO];
}

- (void) saveMediaUpdateForAdding:(BOOL)isAdding
{
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        UserTaste *userTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:localContext];
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
        userTaste.taste = arrayData;
    } completion:^(BOOL success, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(userListHaveBeenUpdate:)]) {
            [self.delegate userListHaveBeenUpdate:userTasteDict];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"endSave" object:nil userInfo:userTasteDict];
        }
        // 7 secondes after update user list we update the database with new datas
        // Like this we are "sure" that user really wants to add this media to his list
        
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(synchronizeUserListWithServer) object:nil];
//        [self performSelector:@selector(synchronizeUserListWithServer) withObject:nil afterDelay:7.0]; // 7.0
        // [pfPushManager notifyUpdateList];
        
        [self synchronizeUserListWithServer];
        
        [self cancelLocalNotificationWithValueForKey:@"updateList"];
//        UILocalNotification *localNotification = [UILocalNotification new];
//        localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:NSCalendarUnitMonth]; //One month later
//        localNotification.soundName = UILocalNotificationDefaultSoundName;
//        localNotification.applicationIconBadgeNumber = 0;
//        localNotification.alertAction = nil;
//        localNotification.alertBody = NSLocalizedString(@"localNotificationAlertBodyNotUpdateList", nil);
//        localNotification.userInfo = @{@"locatificationName" : @"updateList"};
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }];
}

#pragma mark - Server part


- (BOOL) connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}


- (void) synchronizeUserListWithServer
{
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user/list"];
    
    NSDictionary *parameters = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"], @"list": [self updateTasteForServer]};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"foo" forHTTPHeaderField:@"X-Shound"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [manager PATCH:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"responseObject: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
    }];
}

// This method retrieve an readable json of user taste for the database
- (NSString *) updateTasteForServer
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userTasteDict
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [NSString urlEncodeValue:jsonString];
        
        return jsonString;
    }
}


- (void) noInternetConnexionAlert
{
    UIAlertView *errConnectionAlertView;
    
    if (![self connected]) {
        errConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"noconnection", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    } else {
        errConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"issuesWithDetailsMedia", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        errConnectionAlertView.tag = 9;
    }
    
    [errConnectionAlertView show];
    [loadingIndicator stopAnimating];

    
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 9) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Misc

- (void) openStore:(UIButton*)sender
{
    NSString *iTunesURLString = @"https://itunes.apple.com/fr/";
    iTunesURLString = [iTunesURLString stringByAppendingString:self.itunesIDString];
    iTunesURLString = [iTunesURLString stringByAppendingString:@"?uo=4&at=11lRd6"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesURLString]];
}

- (void) cancelLocalNotificationWithValueForKey:(NSString*)aValue
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *listLocalNotification = [app scheduledLocalNotifications];
    for (int i = 0; i < [listLocalNotification count]; i++)
    {
        UILocalNotification* aLocalNotification = [listLocalNotification objectAtIndex:i];
        NSDictionary *userInfoCurrent = aLocalNotification.userInfo;
        NSString *aLocalNotifValue = [NSString stringWithFormat:@"%@", [userInfoCurrent valueForKey:@"locatificationName"]];
        if ([aLocalNotifValue isEqualToString:aValue])
        {
            [app cancelLocalNotification:aLocalNotification];
            break;
        }
    }
}



//<a href="https://itunes.apple.com/fr/movie/scarface-1983/id371011281" target="itunes_store">Scarface (1983)</a>


- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension
{
    CGFloat ratio = 0;
    ratio = ((aNumber * 100)/aDimension);
    ratio = ((ratio*aDimension)/100);
    
    if ([UIScreen mainScreen].scale > 2.1) {
        
        ratio = ratio/3; // Because we are in retina HD
        
    } else {
        ratio = ratio/2; // Because we are in retina
    }
    
    
    return roundf(ratio);
}

- (UIImage *) takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (CALayer *) myLayerWithName:(NSString*)myLayerName andParent:(UIView*)aParentView
{
    for (CALayer *layer in [aParentView.layer sublayers]) {
        
        if ([[layer name] isEqualToString:myLayerName]) {
            return layer;
        }
    }
    
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
