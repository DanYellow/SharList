//
//  DetailsMediaViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "DetailsMediaViewController.h"


@interface DetailsMediaViewController ()

@property (strong, nonatomic) Discovery *userTaste;

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
// 3 : __undefined__
// 4 : title label
// 5 : mediaLikeNumberLabel
// 6 : imgMedia
// 7 : buy button
// 8 : tutorialView
// 9 : errConnectionAlertView
// 10 : connectWithBSBtn
// 11 : mediaGenresLabel
// 12 : mediaDescription
// 13 : numberOfIterationAmongDiscoveriesLabel
// 14 : fbFriendsContainer
// 15 : titleBuyMedia
// 16 : storesView
// 17 : thumbFbFriendImg
// 18 : friendPatronymLabel
// 19 : __empty__
// 20 : addRemoveFromListBtn

// Before page loading we hide the tabbar
// Because we don't need it

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
    

    // We just want the title of the uiviewcontroller
    self.navigationItem.titleView = [UIView new];
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
    buyButtonsInitPositions = [NSMutableArray new];
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    // Disabled the swipe back of the view
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    


    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // We create an offset to manage uisplitview
    NSUInteger offsetWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? self.splitViewController.primaryColumnWidth : 0;
    
    screenWidth = screenRect.size.width - offsetWidth;
    screenHeight = screenRect.size.height;
    
//    pfPushManager = [[PFPushManager alloc] initForType:UpdateList];
    

    

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
    
    if (self.mediaDatas == nil) {
        return;
    }
    
    UIScrollView *infoMediaView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, screenWidth, screenHeight)];
    infoMediaView.backgroundColor = [UIColor clearColor];
    infoMediaView.opaque = NO;
    infoMediaView.hidden = NO;
    infoMediaView.tag = 2;
    infoMediaView.showsVerticalScrollIndicator = YES;
    infoMediaView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    
    self.userTaste = [Discovery MR_findFirstByAttribute:@"fbId"
                                              withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    userTasteDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     [NSNull null], @"book",
                     [NSNull null], @"movie",
                     [NSNull null], @"serie",
                     nil];
    
    
    // This statement is hre for prevent empty user list
    // Because it corrupt the NSMutableDictionary
    // And you're not able to update it
    if ([NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste likes]] != nil) {
        userTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste likes]] mutableCopy];
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
//            self.Added = NO;
            addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
        } else {
            self.Added = YES;
            addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
        }
    } else {
        self.Added = NO;
        addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
    }

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
            // We made a second query for tv show to get datas with imdb id
            if (responseObject[@"tv_results"] != nil && [responseObject[@"tv_results"] count] != 0) {
                NSDictionary *tvQueryParams = @{@"id": [responseObject valueForKeyPath: @"tv_results.id"][0], @"language": userLanguage};
                [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTV withParameters:tvQueryParams andResponseBlock:^(id responseObject, NSError *error) {
                    if(!error){
                        [self setMediaViewForData:responseObject];
                    }
                }];
            // It's a serie directly from themoviedbapi
            } else if ([responseObject objectForKey:@"number_of_seasons"] != nil) {
                [self setMediaViewForData:responseObject];
            } else {
                // It's a movie
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
        
    UILabel *mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, screenWidth - 22, 55)];
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
    

    // SHOUND API
    
    // This NSDict will be used to set id to local media
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.mediaDatas];
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/beta"];
    
    NSDictionary *parameters = @{@"imdbId": self.mediaDatas[@"imdbID"]};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager.requestSerializer setValue:@"mince" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (!self.mediaDatas[@"id"]) {
                  [tempDict setObject:(NSString *)[responseObject valueForKeyPath:@"response.id"] forKey:@"id"];
                  self.mediaDatas = tempDict;
              }
              
              // If the name of the media change in the database, the user keep the last name in the db
              if (responseObject[@"name"] != nil && ![self.mediaDatas[@"name"] isEqualToString:(NSString *)responseObject[@"name"]]) {
                  [tempDict setObject:(NSString *)[responseObject valueForKeyPath:@"response.name"] forKey:@"name"];
                  self.mediaDatas = tempDict;
              }
              
              [self displayBuyButtonForShops:[responseObject valueForKeyPath:@"response.storeLinks"]];
              
              
              NSNumber *numberComments = [NSNumber numberWithInteger:[[responseObject valueForKeyPath:@"response.commentsCount"] integerValue]];

              self.numberOfComments = numberComments;
              
              NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
              [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
              
              UIButton *messagesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
              [messagesBtn addTarget:self action:@selector(displayMessageForMediaWithId:) forControlEvents:UIControlEventTouchUpInside]; // numberMessages
              [messagesBtn setTitle:[numberFormatter stringFromNumber:numberComments] forState:UIControlStateNormal];
              messagesBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
              [messagesBtn setImage:[[UIImage imageNamed:@"listMessagesNavIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                           forState:UIControlStateNormal];
              messagesBtn.frame = CGRectMake(0, 0, 55, 24);
              messagesBtn.backgroundColor = [UIColor clearColor];
              [messagesBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
              [messagesBtn setTitleColor:[UIColor colorWithRed:(114.0/255.0) green:(117.0/255.0) blue:(121.0/255.0) alpha:1.0f] forState:UIControlStateHighlighted];
              messagesBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -messagesBtn.titleLabel.frame.size.width,
                                                             0, messagesBtn.imageView.frame.size.width);
              messagesBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -messagesBtn.imageView.frame.size.width + 10, 0, 0);
              messagesBtn.titleLabel.textAlignment = NSTextAlignmentRight;
              messagesBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
              
              UIBarButtonItem *messagesBarBtn = [[UIBarButtonItem alloc] initWithCustomView:messagesBtn];
              
              self.navigationItem.rightBarButtonItems = @[addMediaToFavoriteBtnItem, messagesBarBtn];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error viewDidLoad - : %@", error);
    }];
    

    [self.view insertSubview:infoMediaView atIndex:1];
    
    if (![self connected]) {
        UIView *infoMediaViewLastView = [infoMediaView.subviews lastObject];
        
        UILabel *nbIterationAmongDiscoveries = [self displayNumberOfIterationsAmongDiscoveries];
        nbIterationAmongDiscoveries.frame = CGRectMake(0, CGRectGetMaxY(infoMediaViewLastView.frame) + 30,
                                                       CGRectGetWidth(nbIterationAmongDiscoveries.frame),
                                                       CGRectGetHeight(nbIterationAmongDiscoveries.frame));
        [infoMediaView addSubview:nbIterationAmongDiscoveries];
//        [self displayNumberOfIterationsAmongDiscoveriesForView:infoMediaView];
    }
    
   
    
    loadingIndicator = [UIActivityIndicatorView new];
    loadingIndicator.center = CGPointMake(screenWidth/2, self.view.center.y);
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



- (UILabel*) displayNumberOfIterationsAmongDiscoveries
{
    NSPredicate *facebookFriendsFilter = [NSPredicate predicateWithFormat:@"fbId != %@",
                                          [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    NSArray *meetings = [Discovery MR_findAllSortedBy:@"lastDiscovery" ascending:NO withPredicate:facebookFriendsFilter];
    
    NSUInteger numberOfApparitionAmongDiscoveries = 0;
    for (Discovery *discovery in meetings) {
        NSDictionary *userTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[discovery likes]] mutableCopy];
        id userTasteForType = [userTaste objectForKey:[self.mediaDatas valueForKey:@"type"]];
        if (![[userTasteForType valueForKey:@"imdbID"] isEqual:[NSNull null]]) {
            if ([[userTasteForType valueForKey:@"imdbID"] containsObject:self.mediaDatas[@"imdbID"]]) {
                numberOfApparitionAmongDiscoveries++;
            }
        }
    }
    
    // This label shows the number of iteration of the card currently shown among user's discoverties
    UILabel *numberOfIterationAmongDiscoveriesLabel = [UILabel new];
    numberOfIterationAmongDiscoveriesLabel.tag = 13;
    
//    UIView *facebookFriendsContainer = (UITextView*)[aContainerView viewWithTag:14];
//    CGFloat mediaDescriptionHeight = CGRectGetMaxY(facebookFriendsContainer.frame) + 30;
    
//    CGFloat numberOfIterationAmongDiscoveriesLabelY = ([self connected]) ? mediaDescriptionHeight : screenHeight - 83;
    
    numberOfIterationAmongDiscoveriesLabel.frame = CGRectMake(0, 0, screenWidth, 20);
    numberOfIterationAmongDiscoveriesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    
    CGFloat iterationAmongDiscoveriesPercent = ((float)numberOfApparitionAmongDiscoveries / (float)meetings.count);
    
    if (isnan(iterationAmongDiscoveriesPercent) || isinf(iterationAmongDiscoveriesPercent)) {
        iterationAmongDiscoveriesPercent = 0.0f;
    }
    
    
    NSString *serieOrMovieString = ([self.mediaDatas[@"type"] isEqualToString:@"serie"]) ? NSLocalizedString(@"serieU", nil) : NSLocalizedString(@"movieU", nil);
    NSString *presentString = ([self.mediaDatas[@"type"] isEqualToString:@"serie"]) ? NSLocalizedString(@"Presentf", nil) : NSLocalizedString(@"Presentm", nil);
    
    
    if (iterationAmongDiscoveriesPercent == 0) {
        NSString *localizeKey = @"%@ %@ in no discovery";
        numberOfIterationAmongDiscoveriesLabel.text = [NSString stringWithFormat:NSLocalizedString(localizeKey, nil), serieOrMovieString, presentString];
    } else {
        NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
        [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        NSString *percentApparition = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:iterationAmongDiscoveriesPercent]];
        
        NSMutableAttributedString *NbrDiscoveriesAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ %@ Present of %@ discoveries", nil), serieOrMovieString, presentString, percentApparition] attributes:nil];
        
        NSRange hellStringRange = [[NbrDiscoveriesAttrString string] rangeOfString:[NSString stringWithFormat:NSLocalizedString(@"p %@ discoveries", nil), percentApparition]];
        
        [NbrDiscoveriesAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0] range:NSMakeRange(hellStringRange.location, hellStringRange.length)];
        
        numberOfIterationAmongDiscoveriesLabel.attributedText = NbrDiscoveriesAttrString;
    }
    
    numberOfIterationAmongDiscoveriesLabel.textColor = [UIColor whiteColor];
    numberOfIterationAmongDiscoveriesLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat layerWidth = (90 * screenWidth) / 100;
    CGFloat layerX = (self.view.frame.size.width - layerWidth) / 2;

    CALayer *numberOfIterationAmongDiscoveriesLabelLayerT = [CALayer layer];
    numberOfIterationAmongDiscoveriesLabelLayerT.frame = CGRectMake(layerX, -16.0f, layerWidth, 1.0);
    numberOfIterationAmongDiscoveriesLabelLayerT.backgroundColor = [UIColor whiteColor].CGColor;
    numberOfIterationAmongDiscoveriesLabelLayerT.anchorPoint = CGPointMake(0.5, 0.5);
    [numberOfIterationAmongDiscoveriesLabel.layer addSublayer:numberOfIterationAmongDiscoveriesLabelLayerT];

    
    return numberOfIterationAmongDiscoveriesLabel;
}

- (UIButton*) displayAddRemoveFromListBtn:(NSString*)txt
{
    UIButton *addRemoveFromListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addRemoveFromListBtn.tag = 20;
    [addRemoveFromListBtn setFrame:CGRectMake(0, 0, (screenWidth * 90) / 100, 54)];
    [addRemoveFromListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addRemoveFromListBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    addRemoveFromListBtn.center = CGPointMake(self.view.center.x, addRemoveFromListBtn.center.y);
    
    [addRemoveFromListBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]]
                                    forState:UIControlStateHighlighted];
    [addRemoveFromListBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.1 alpha:.5]]
                                    forState:UIControlStateDisabled];
    [addRemoveFromListBtn addTarget:self action:@selector(addAndRemoveMediaToList:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [addRemoveFromListBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [addRemoveFromListBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    [addRemoveFromListBtn setTitle:txt forState:UIControlStateNormal];
    addRemoveFromListBtn.backgroundColor = [UIColor clearColor];
    addRemoveFromListBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    addRemoveFromListBtn.layer.borderWidth = 2.0f;
    
    
    CGFloat layerWidth = (90 * screenWidth) / 100;
    CGFloat layerX = ((self.view.frame.size.width - layerWidth) / 2) - CGRectGetMinX(addRemoveFromListBtn.frame);
    
    CALayer *connectWithBSBtnLayerT = [CALayer layer];
    connectWithBSBtnLayerT.frame = CGRectMake(layerX, -15.0f, layerWidth, 1.0);
    connectWithBSBtnLayerT.backgroundColor = [UIColor whiteColor].CGColor;
    connectWithBSBtnLayerT.anchorPoint = CGPointMake(0.5, 0.5);
    [addRemoveFromListBtn.layer addSublayer:connectWithBSBtnLayerT];
    
    return addRemoveFromListBtn;
}

- (NSArray*) fetchFacebookFriendsForMedia
{
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
        return @[];
    }
    
    // We retrieve the list of facebook friends
//    NSPredicate *facebookFriendsFilter = [NSPredicate predicateWithFormat:@"fbId IN %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"]];
    NSArray *facebookFriends = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"];

//    NSPredicate *facebookFrienddbIdFilter = [NSPredicate predicateWithFormat:@"dbId != 0"];
//    NSArray *facebookFriends = [[Discovery MR_findAllWithPredicate:facebookFriendsFilter] valueForKey:@"fbId"];
    
    NSString *paramsString = @"";
    NSMutableArray *paramsArray = [NSMutableArray new];
    for (NSString *friendId in facebookFriends) {
        [paramsArray addObject:[NSString stringWithFormat:@"friends[]=%@", friendId]];
    }
    
    paramsString = [paramsArray componentsJoinedByString:@"&"];
    paramsString = [paramsString stringByAppendingString:[NSString stringWithFormat:@"&imdbId=%@", self.mediaDatas[@"imdbID"]]];


    NSString *urlString = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/friends?"];
    urlString = [urlString stringByAppendingString:paramsString];
    

    NSURL *aUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:9.0];
    [request setValue:@"discover" forHTTPHeaderField:@"X-Shound"];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response error:&error];
    
    if (error == nil) {
        NSMutableDictionary *serverResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSPredicate *facebookFriendsForMedia = [NSPredicate predicateWithFormat:@"id IN %@", [serverResponse[@"response"] valueForKey:@"fbId" ]];
        NSArray *facebookFriends = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"]  filteredArrayUsingPredicate:facebookFriendsForMedia];

        return facebookFriends;
    } else {
        return @[];
    }
    
    return @[];

//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        if (error) {
//            
//        } else {
//            __block NSMutableDictionary *serverResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            callback((NSArray*) serverResponse[@"response"]);
////            return serverResponse[@"response"];
//        }
//    }];
}

- (UIView*) displayFacebookFriends
{
    UIView *facebookFriendsContainer = [UIView new];
    facebookFriendsContainer.backgroundColor = [UIColor clearColor];
    
    NSArray *facebookFriendsList = [self fetchFacebookFriendsForMedia];
    
    // None of user facebook friends has this media among his list
    // So we add a button to talk about the movie / serie to the user friends
    if ([facebookFriendsList count] == 0) {
        
        [facebookFriendsContainer addSubview:[self introduceMediaToFriends]];
        
        UIView *facebookFriendsContainerLastView = [[facebookFriendsContainer subviews] lastObject];
        facebookFriendsContainerLastView.backgroundColor = [UIColor clearColor];
        facebookFriendsContainer.frame = CGRectMake(0, 0,
                                                    screenWidth, CGRectGetMaxY(facebookFriendsContainerLastView.frame));
        
        return facebookFriendsContainer;
    }
    
    UILabel *facebookFriendListIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (90 * screenWidth) / 100, 20)];
    facebookFriendListIndicatorLabel.text = NSLocalizedString(@"Present in following friends list", nil);
    facebookFriendListIndicatorLabel.textColor = [UIColor whiteColor];
    facebookFriendListIndicatorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    facebookFriendListIndicatorLabel.backgroundColor = [UIColor clearColor];
    facebookFriendListIndicatorLabel.center = CGPointMake(self.view.center.x, 10);
    
    [facebookFriendsContainer addSubview:facebookFriendListIndicatorLabel];
    
    
    // Contains the list of thumbnails of facebook friends
    UIScrollView *thumbsFriendsScrollView = [UIScrollView new];
    thumbsFriendsScrollView.pagingEnabled = NO;
    thumbsFriendsScrollView.showsHorizontalScrollIndicator = NO;
    thumbsFriendsScrollView.showsVerticalScrollIndicator = NO;
    thumbsFriendsScrollView.frame = CGRectMake(0, CGRectGetHeight(facebookFriendListIndicatorLabel.frame) + CGRectGetMaxY(facebookFriendListIndicatorLabel.frame) - 7, screenWidth, 0);
    thumbsFriendsScrollView.backgroundColor = [UIColor clearColor];
    
    [facebookFriendsContainer addSubview:thumbsFriendsScrollView];

    int offsetX = (5 * screenWidth) / 100;
    int limitFriendsThumbs = 13;
    CGFloat thumbFriendContainerSize = 70.0f;
    
    [facebookFriendsList enumerateObjectsUsingBlock:^(NSDictionary *friend, NSUInteger idx, BOOL *stop) {
        if (idx == limitFriendsThumbs) {
            UIView *moreFriendsIndicator = [[UIView alloc] initWithFrame:CGRectMake(offsetX + (idx * thumbFriendContainerSize) + (idx * 12),
                                                                                         0,
                                                                                         thumbFriendContainerSize,
                                                                                    thumbFriendContainerSize)];
            
            CATextLayer *extraFbFriendsLayer = [CATextLayer layer];
            extraFbFriendsLayer.frame = CGRectMake(0, 10, thumbFriendContainerSize, thumbFriendContainerSize);
            extraFbFriendsLayer.foregroundColor = [UIColor whiteColor].CGColor;
            extraFbFriendsLayer.backgroundColor = [UIColor clearColor].CGColor;
            
            NSUInteger remainingFriends = [facebookFriendsList count] - limitFriendsThumbs;
            extraFbFriendsLayer.string = [@"+" stringByAppendingString:[[NSNumber numberWithInteger:remainingFriends] stringValue]];
            extraFbFriendsLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"HelveticaNeue" size:30]);
            extraFbFriendsLayer.alignmentMode = kCAAlignmentCenter;
            extraFbFriendsLayer.wrapped = true;
            // Removes aliasing
            extraFbFriendsLayer.contentsScale = [[UIScreen mainScreen] scale];

            moreFriendsIndicator.backgroundColor = [UIColor clearColor];
            moreFriendsIndicator.layer.cornerRadius = 33;
            moreFriendsIndicator.layer.borderColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
            moreFriendsIndicator.layer.borderWidth = 1.0f;
            [moreFriendsIndicator.layer addSublayer:extraFbFriendsLayer];
            [thumbsFriendsScrollView addSubview:moreFriendsIndicator];
            
            *stop = YES;
            
            return;
        }
        
        NSURL *facebookFriendImgProfile = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%.0f&height=%.0f", friend[@"id"], thumbFriendContainerSize, thumbFriendContainerSize]];
        
        UIButton *thumbFbFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [thumbFbFriendBtn addTarget:self action:@selector(seeFriendPatronym:) forControlEvents:UIControlEventTouchUpInside];
        thumbFbFriendBtn.frame = CGRectMake(offsetX + (idx * thumbFriendContainerSize) + (idx * 12), 0, thumbFriendContainerSize, thumbFriendContainerSize);
        thumbFbFriendBtn.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *thumbFbFriendImg = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                          -(thumbFriendContainerSize/2),
                                                                                          thumbFriendContainerSize,
                                                                                          thumbFriendContainerSize)];
        thumbFbFriendImg.backgroundColor = [UIColor clearColor];
        thumbFbFriendImg.clipsToBounds = YES;
        thumbFbFriendImg.layer.anchorPoint = CGPointMake(.5, 0);
        thumbFbFriendImg.layer.cornerRadius = thumbFriendContainerSize/2;
        thumbFbFriendImg.layer.borderColor = [[UIColor colorWithWhite:1 alpha:.1] CGColor];
        thumbFbFriendImg.layer.borderWidth = 1.0f;
        thumbFbFriendImg.tag = 17;
        
        CALayer *overlayLayer = [CALayer layer];
        overlayLayer.frame = thumbFbFriendImg.frame;
        overlayLayer.opacity = 0;
        overlayLayer.name = @"overlayLayerThumbFbFriendImg";
        overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8].CGColor;
        [thumbFbFriendImg.layer insertSublayer:overlayLayer atIndex:1];
        
        UILabel *friendPatronymLabel = [UILabel new];
        friendPatronymLabel.text = friend[@"first_name"];
        friendPatronymLabel.tag = 18;
        [friendPatronymLabel sizeToFit];
        friendPatronymLabel.frame = CGRectMake(0, CGRectGetHeight(thumbFbFriendBtn.frame) - CGRectGetHeight(friendPatronymLabel.frame) + 50,
                                 CGRectGetWidth(thumbFbFriendBtn.frame), CGRectGetHeight(friendPatronymLabel.frame));
        friendPatronymLabel.textColor = [UIColor whiteColor];
        friendPatronymLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        friendPatronymLabel.textAlignment = NSTextAlignmentCenter;

        [UIView transitionFromView:thumbFbFriendImg toView:thumbFbFriendImg
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:NULL];
        
        [thumbFbFriendImg setImageWithURL:facebookFriendImgProfile
                         placeholderImage:nil];
        
        
        [thumbFbFriendBtn addSubview:thumbFbFriendImg];
        [thumbFbFriendBtn addSubview:friendPatronymLabel];
        
        
        [thumbsFriendsScrollView addSubview:thumbFbFriendBtn];
    }];
    
    UIView *thumbsFriendsScrollViewLastView = [[thumbsFriendsScrollView subviews] lastObject];
    thumbsFriendsScrollView.frame = CGRectMake(thumbsFriendsScrollView.frame.origin.x,
                                               thumbsFriendsScrollView.frame.origin.y,
                                               thumbsFriendsScrollView.frame.size.width,
                                               CGRectGetMaxY(thumbsFriendsScrollViewLastView.frame));

    thumbsFriendsScrollView.contentSize = CGSizeMake(CGRectGetMaxX(thumbsFriendsScrollViewLastView.frame) + offsetX, thumbFriendContainerSize);

    
    UIView *facebookFriendsContainerLastView = [[facebookFriendsContainer subviews] lastObject];
    facebookFriendsContainerLastView.backgroundColor = [UIColor clearColor];
    facebookFriendsContainer.frame = CGRectMake(0, 0,
                                                screenWidth, CGRectGetMaxY(facebookFriendsContainerLastView.frame));
    
    CGFloat layerWidth = (90 * screenWidth) / 100;
    CGFloat layerX = (self.view.frame.size.width - layerWidth) / 2;
    
    CALayer *numberOfIterationAmongDiscoveriesLabelLayerT = [CALayer layer];
    numberOfIterationAmongDiscoveriesLabelLayerT.frame = CGRectMake(layerX, -16.0f, layerWidth, 1.0);
    numberOfIterationAmongDiscoveriesLabelLayerT.backgroundColor = [UIColor whiteColor].CGColor;
    numberOfIterationAmongDiscoveriesLabelLayerT.anchorPoint = CGPointMake(0.5, 0.5);
    [facebookFriendsContainer.layer addSublayer:numberOfIterationAmongDiscoveriesLabelLayerT];

    return facebookFriendsContainer;
}


- (UIButton *) introduceMediaToFriends
{
    UIButton *introduceMediaToFriendsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    introduceMediaToFriendsBtn.tag = 20;
    [introduceMediaToFriendsBtn setFrame:CGRectMake(0, 0, (screenWidth * 90) / 100, 54)];
    [introduceMediaToFriendsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [introduceMediaToFriendsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    introduceMediaToFriendsBtn.center = CGPointMake(self.view.center.x, introduceMediaToFriendsBtn.center.y);
    
    [introduceMediaToFriendsBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]]
                                    forState:UIControlStateHighlighted];
    [introduceMediaToFriendsBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.1 alpha:.5]]
                                    forState:UIControlStateDisabled];
    [introduceMediaToFriendsBtn addTarget:self action:@selector(introduceMediaToFriendsAction:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [introduceMediaToFriendsBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [introduceMediaToFriendsBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    [introduceMediaToFriendsBtn setTitle:NSLocalizedString(@"To introduce friends", nil)
                                forState:UIControlStateNormal];
    
    
    introduceMediaToFriendsBtn.backgroundColor = [UIColor clearColor];
    introduceMediaToFriendsBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    introduceMediaToFriendsBtn.layer.borderWidth = 2.0f;
    
    return introduceMediaToFriendsBtn;
}


- (void) seeFriendPatronym:(UIButton*)sender
{
    UIImageView *imgBtn = (UIImageView*)[sender viewWithTag:17];
    UILabel *friendPatronymLabel = (UILabel*)[sender viewWithTag:18];
    
    CGFloat animDuration = .3;
    CABasicAnimation *overlayAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];

    if ([[self myLayerWithName:@"overlayLayerThumbFbFriendImg" andParent:imgBtn] opacity] == 0) {
        [self myLayerWithName:@"overlayLayerThumbFbFriendImg" andParent:imgBtn].opacity = 1;
        
        [UIView animateWithDuration:animDuration
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             friendPatronymLabel.frame = CGRectMake(0, CGRectGetHeight(sender.frame) - CGRectGetHeight(friendPatronymLabel.frame) - 10,
                                                                    CGRectGetWidth(sender.frame), CGRectGetHeight(friendPatronymLabel.frame));
                         }
                         completion:nil];
    } else {
        [self myLayerWithName:@"overlayLayerThumbFbFriendImg" andParent:imgBtn].opacity = 0;
        
        [UIView animateWithDuration:animDuration
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             friendPatronymLabel.frame = CGRectMake(0, CGRectGetHeight(sender.frame) - CGRectGetHeight(friendPatronymLabel.frame) + 50,
                                                                    CGRectGetWidth(sender.frame), CGRectGetHeight(friendPatronymLabel.frame));
                         }
                         completion:nil];
    }
    
    overlayAlphaAnim.duration = animDuration;
    overlayAlphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    overlayAlphaAnim.fillMode = kCAFillModeForwards;
    overlayAlphaAnim.removedOnCompletion = NO;
    [[self myLayerWithName:@"overlayLayerThumbFbFriendImg" andParent:imgBtn] addAnimation:overlayAlphaAnim forKey:@"overlayAnimation"];
    
}

- (void) getTrailerAndNextEpisodeDateForResponse:(NSDictionary*)responseObject
{

    if ([responseObject valueForKeyPath:@"id"] == nil) {
        return;
    }
    
    // Retrieve trailer
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
    
    if ([lastAirEpisode isKindOfClass:[NSNull class]]) {
        return;
    }
    
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

#pragma mark - Tutorial

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
    [[[UIApplication sharedApplication] keyWindow] addSubview:tutorialView];
    
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

#pragma mark - buying part

// Creates view for to buy media
- (void) buyScreenForStores:(NSDictionary*)storesList
{
    UIView *displayBuyView = [[UIView alloc] initWithFrame:self.view.bounds];
    displayBuyView.tag = 1;
    displayBuyView.hidden = YES;
    displayBuyView.alpha = 0.0f;

    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = displayBuyView.frame;
    
    [displayBuyView addSubview:visualEffectView];
    
    [self.view addSubview:displayBuyView];
    
    UILabel *titleBuyMedia = [[UILabel alloc] initWithFrame:CGRectMake(((screenWidth - [self computeRatio:574 forDimension:screenWidth]) / 2), [self computeRatio:86 forDimension:screenHeight], [self computeRatio:574 forDimension:screenWidth], 16.0f)];
    titleBuyMedia.textColor = [UIColor whiteColor];
    titleBuyMedia.backgroundColor = [UIColor clearColor];
    titleBuyMedia.opaque = NO;
    titleBuyMedia.tag = 15;
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
    
    // It's used later in the code
    UIView *displayBuyViewLastView = [displayBuyView.subviews lastObject];
    
    
    // Close button
    CGRect lineFrame = CGRectMake(0, 18, 35, 4);
    
    UIButton *closeBuyScreenWindowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBuyScreenWindowBtn.frame = CGRectMake([self computeRatio:250 forDimension:screenWidth], screenHeight - [self computeRatio:116 forDimension:screenHeight], 50, 50);
    [closeBuyScreenWindowBtn addTarget:self action:@selector(hideBuyScreen) forControlEvents:UIControlEventTouchUpInside];
    closeBuyScreenWindowBtn.backgroundColor = [UIColor clearColor];
    closeBuyScreenWindowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    closeBuyScreenWindowBtn.layer.borderWidth = 1.0f;
    closeBuyScreenWindowBtn.layer.cornerRadius = 25;
    closeBuyScreenWindowBtn.layer.masksToBounds = YES;
    [closeBuyScreenWindowBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]]
                                       forState:UIControlStateHighlighted];
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
    
    
    UIScrollView *storesView = [self displayButtonsForStores:storesList];
    storesView.frame = CGRectMake(0, CGRectGetMaxY(displayBuyViewLastView.frame) + 20,
                                  screenWidth, CGRectGetMinY(closeBuyScreenWindowBtn.frame) - CGRectGetMaxY(displayBuyViewLastView.frame) - 40);
    storesView.tag = 16;
    storesView.center = CGPointMake(storesView.center.x, self.view.center.y);
    [displayBuyView addSubview:storesView];
}

- (void) showBuyScreen
{
    // We don't need uinavigationcontroller so...
    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];
    displayBuyView.hidden = NO;
    
    [UIView animateWithDuration:0.4 delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         displayBuyView.alpha = 1;
                     }
                     completion:nil];
}

- (void) hideBuyScreen
{
    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];
    UIView *storesView = (UIView*)[self.view viewWithTag:16];
    
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
                         
            
                         [storesView.subviews enumerateObjectsUsingBlock:^(StoreButton *storeButton, NSUInteger idx, BOOL *stop) {
                             if ([storeButton isKindOfClass:[StoreButton class]]) {
                                 storeButton.frame = [[buyButtonsInitPositions objectAtIndex:idx] CGRectValue];
                                 
                                 CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, DegreesToRadians(0));
                                 storeButton.transform = transform;
                             }
                         }];
                         [animator removeAllBehaviors];
                     }];
}

// It displays the button 'buy' at the bottom of the screen
- (void) displayBuyButtonForShops:(NSDictionary*)storesList
{
    
    
    // There is no links to stores
    if([storesList isKindOfClass:[NSNull class]]) return;
    if ([storesList count] == 0) return;
    
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

    [self.view insertSubview:buyButton atIndex:42];
    // Display screen with all buttons to buy
    [self buyScreenForStores:storesList];


    [UIView animateWithDuration:0.4 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         buyButton.frame = CGRectSetPos( buyButton.frame, 0, screenHeight - 50 );
                     }
                     completion:^(BOOL completion){
                         
                     }];
}

- (UIScrollView*) displayButtonsForStores:(NSDictionary*)storesList
{

    UIScrollView *storesBtnsContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 200, screenWidth, 42)];
    storesBtnsContainer.backgroundColor = [UIColor clearColor];
    storesBtnsContainer.showsHorizontalScrollIndicator = NO;
    storesBtnsContainer.showsVerticalScrollIndicator = NO;

    CGSize buttonSize = CGSizeMake((90 * screenWidth) / 100, 50.0f);
    
    NSUInteger idx = 0;
    NSArray *sortedStoreList = [[storesList allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (NSString *key in sortedStoreList) {
        NSString *storeName = @"";
        StoreButton *storeButton;
        
        if ([key isEqualToString:@"amazonLinkDVD"] && ![storesList[key] isKindOfClass:[NSNull class]]) {
            storeButton = [[StoreButton alloc] initWithType:Amazon];
            storeButton.storeLink = storesList[key];
            storeName = NSLocalizedString(@"amazonDVD", nil);
        } else if ([key isEqualToString:@"amazonLinkBR"] && ![storesList[key] isKindOfClass:[NSNull class]]) {
            storeButton = [[StoreButton alloc] initWithType:Amazon];
            storeButton.storeLink = storesList[key];
            storeName = NSLocalizedString(@"amazonBR", nil);
        } else if ([key isEqualToString:@"fnacLink"] && ![storesList[key] isKindOfClass:[NSNull class]]) {
            storeButton = [[StoreButton alloc] initWithType:Fnac];
            storeButton.storeLink = storesList[key];
            storeName = NSLocalizedString(@"fnac", nil);
        } else if ([key isEqualToString:@"itunesLinkVF"] && ![storesList[key] isKindOfClass:[NSNull class]]) {
            storeButton = [[StoreButton alloc] initWithType:Itunes];
            storeButton.storeLink = storesList[key];
            storeName = NSLocalizedString(@"itunesVF", nil);
        } else if ([key isEqualToString:@"itunesLinkVO"] && ![storesList[key] isKindOfClass:[NSNull class]]) {
            storeButton = [[StoreButton alloc] initWithType:Itunes];
            storeButton.storeLink = storesList[key];
            storeName = NSLocalizedString(@"itunesVO", nil);
        } else {
            // We dont want to shift the button so we dont increment the button pos if there is no datas
            continue;
        }
        CGPoint buttonPos = CGPointMake( ((screenWidth - buttonSize.width) / 2), (buttonSize.height * idx) + (idx * 22));
        storeButton.frame = CGRectMake(buttonPos.x, buttonPos.y, buttonSize.width, buttonSize.height);
        [storeButton setTitle:[storeName uppercaseString] forState:UIControlStateNormal];
        [storeButton addTarget:self action:@selector(openStore:) forControlEvents:UIControlEventTouchUpInside];
        
        [storesBtnsContainer addSubview:storeButton];
        
        [buyButtonsInitPositions addObject:[NSValue valueWithCGRect:storeButton.frame]];
        
        idx++;
    }


    UIView *storesBtnsContainerLastView = [storesBtnsContainer.subviews lastObject];
    storesBtnsContainer.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(storesBtnsContainerLastView.frame));
    
    
    return storesBtnsContainer;
}

- (void) setMediaViewForData:(NSDictionary*)data
{
    if ([self.mediaDatas[@"type"] isEqualToString:@"serie"]) {
        [self getTrailerAndNextEpisodeDateForResponse:data];
    }
    
    
    UIScrollView *infoMediaView = (UIScrollView*)[self.view viewWithTag:2];

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
    overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8].CGColor;
    [imgMedia.layer insertSublayer:overlayLayer atIndex:0];
    
    CABasicAnimation *overlayAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    overlayAlphaAnim.fromValue = @0;
    overlayAlphaAnim.toValue   = @1;
    overlayAlphaAnim.duration  = 0.42;
    overlayAlphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [overlayLayer addAnimation:overlayAlphaAnim forKey:@"overlayAnimation"];


    UILabel *mediaTitleLabel = (UILabel*)[self.view viewWithTag:4];
    
    UIView *infoMediaViewLastView = [infoMediaView.subviews lastObject];
    
    NSString *genresString = NSLocalizedString(@"Genres", nil);
    
    NSMutableArray *genresArray = [NSMutableArray new];
    for (id genre in data[@"genres"]) {
        [genresArray addObject:genre[@"name"]];
    }
    
    genresString = [genresString stringByAppendingString:[genresArray componentsJoinedByString:@", "]];
    
    UILabel *mediaGenresLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(mediaTitleLabel.frame) + 40, screenWidth - 30, 25)];
    mediaGenresLabel.translatesAutoresizingMaskIntoConstraints = NO;
    mediaGenresLabel.text = genresString;
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
    
    
    infoMediaViewLastView = [infoMediaView.subviews lastObject];
    
    CGFloat mediaDescriptionWidthPercentage = 82.0;
    CGFloat mediaDescriptionWidth = roundf((screenWidth * mediaDescriptionWidthPercentage) / 100);
    CGFloat mediaDescriptionY = CGRectGetMaxY(infoMediaViewLastView.frame) + 7;

    UITextView *mediaDescription = [[UITextView alloc] initWithFrame:CGRectMake(11, mediaDescriptionY, mediaDescriptionWidth, 0)];
    
    if (data[@"overview"] == [NSNull null] || [data[@"overview"] isEqualToString:@""]) {
        // the movie db does not provide description for this media
        mediaDescription.text = NSLocalizedString(@"nodescription", nil);
    } else {
        mediaDescription.text = [data[@"overview"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    // http://www.amazon.fr/gp/product/B00RTG7894?ie=UTF8&camp=1642&creativeASIN=B00RTG7894&linkCode=xm2&tag=shound-21
    
//    http://www.amazon.fr/Breaking-Bad-Int%C3%A9grale-%C3%89dition-Collector/dp/B00FZ6JX5C/?_encoding=UTF8&camp=1642&creative=6746&linkCode=ur2&qid=1435001328&s=dvd&sr=1-1&tag=shound-21
    
    
    mediaDescription.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    if (mediaDescription.contentSize.height > mediaDescription.frame.size.height) {
        int fontIncrement = 1;
        while (mediaDescription.contentSize.height > mediaDescription.frame.size.height) {
            mediaDescription.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
            fontIncrement++;
        }
    }
    
    mediaDescription.scrollEnabled = NO;
    [mediaDescription sizeToFit];
    [mediaDescription layoutIfNeeded];
    mediaDescription.translatesAutoresizingMaskIntoConstraints = NO;
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
    mediaDescription.tag = 12;
    
    [infoMediaView addSubview:mediaDescription];
    
    
    infoMediaViewLastView = [infoMediaView.subviews lastObject];
    
    UIView *fbFriendsContainer = [self displayFacebookFriends];
    fbFriendsContainer.tag = 14;
    fbFriendsContainer.frame = CGRectMake(0, CGRectGetMaxY(infoMediaViewLastView.frame) + 20,
                                          CGRectGetWidth(fbFriendsContainer.frame),
                                          CGRectGetHeight(fbFriendsContainer.frame));
    [infoMediaView addSubview:fbFriendsContainer];
    
    infoMediaViewLastView = [infoMediaView.subviews lastObject];
    
    UILabel *nbIterationAmongDiscoveries = [self displayNumberOfIterationsAmongDiscoveries];
    // This variable is here to manage the case where there is no facebook friends
    NSUInteger fbFriendsContainerPosY = (fbFriendsContainer.frame.size.height == 0) ? CGRectGetMaxY(fbFriendsContainer.frame) : CGRectGetMaxY(infoMediaViewLastView.frame) + 30;
    
    nbIterationAmongDiscoveries.frame = CGRectMake(0, fbFriendsContainerPosY,
                                                   CGRectGetWidth(nbIterationAmongDiscoveries.frame),
                                                   CGRectGetHeight(nbIterationAmongDiscoveries.frame));
    [infoMediaView addSubview:nbIterationAmongDiscoveries];



    
    // Btn add / remove from list
    infoMediaViewLastView = [infoMediaView.subviews lastObject];
    
    NSString *addRemoveFromListBtnText = (self.isAdded) ? NSLocalizedString(@"RemoveToList", nil) : NSLocalizedString(@"AddToList", nil);

    UIButton *addRemoveFromListBtn = [self displayAddRemoveFromListBtn:addRemoveFromListBtnText];
    addRemoveFromListBtn.frame = CGRectMake(0, CGRectGetMaxY(infoMediaViewLastView.frame) + 30,
                                                   CGRectGetWidth(addRemoveFromListBtn.frame),
                                                   CGRectGetHeight(addRemoveFromListBtn.frame));
    addRemoveFromListBtn.center = CGPointMake(self.view.center.x, addRemoveFromListBtn.center.y);
    [infoMediaView addSubview:addRemoveFromListBtn];
    
    
    
    // We display the betaseries button only if the user has his device language set to french
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"fr"] && [self.mediaDatas[@"type"] isEqualToString:@"serie"]) {
        NSString *BSUserToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"BSUserToken"];
        if (BSUserToken != nil || [BSUserToken isKindOfClass:[NSNull class]]) {
            
            infoMediaViewLastView = [infoMediaView.subviews lastObject];
            
            UIButton *connectWithBSBtn = [self connectWithBSAccount:BSUserToken];
            connectWithBSBtn.frame = CGRectMake(0, CGRectGetMaxY(infoMediaViewLastView.frame) + 30,
                                                CGRectGetWidth(connectWithBSBtn.frame),
                                                CGRectGetHeight(connectWithBSBtn.frame));
            connectWithBSBtn.center = CGPointMake(self.view.center.x, connectWithBSBtn.center.y);
            
            
            [infoMediaView addSubview:connectWithBSBtn];
        }
    }
    
    // set the good dimension of the main container (UIScrollview)
    
    infoMediaViewLastView = [infoMediaView.subviews lastObject];

    
    infoMediaView.frame = CGRectMake(infoMediaView.frame.origin.x,
                                     CGRectGetMinY(infoMediaView.frame),
                                     CGRectGetWidth(infoMediaView.frame),
                                     CGRectGetHeight(infoMediaView.frame) - 60);
    
    infoMediaView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(infoMediaViewLastView.frame) + 30);
    
    [UIView animateWithDuration:0.3 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         mediaDescription.alpha = 1;
                         imgMedia.alpha = .95f;
                     }
                     completion:nil];
    
    
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
    overlayAlphaAnim.duration  = 0.21;
    overlayAlphaAnim.fillMode  = kCAFillModeForwards;
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
    UIScrollView *infoMediaView = (UIScrollView*)[self.view viewWithTag:2];
    
    UIButton *seeTrailerMediaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    seeTrailerMediaBtn.frame = CGRectMake(screenWidth - 45, -40, 40, 40);
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
    UIButton *connectWithBSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectWithBSBtn.tag = 10;
    connectWithBSBtn.enabled = NO;
    [connectWithBSBtn setFrame:CGRectMake(0, 0, (screenWidth * 90) / 100, 54)];
    [connectWithBSBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [connectWithBSBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    connectWithBSBtn.trailerID = BSUserToken;  // This is not a trailer but this extra property is useful
    connectWithBSBtn.center = CGPointMake(self.view.center.x, connectWithBSBtn.center.y);
    
    [connectWithBSBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]] forState:UIControlStateHighlighted];
    [connectWithBSBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.1 alpha:.5]] forState:UIControlStateDisabled];
    
    [connectWithBSBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [connectWithBSBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    connectWithBSBtn.backgroundColor = [UIColor clearColor];
    connectWithBSBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    connectWithBSBtn.layer.borderWidth = 2.0f;
    

    CGFloat layerWidth = (90 * screenWidth) / 100;
    CGFloat layerX = ((self.view.frame.size.width - layerWidth) / 2) - CGRectGetMinX(connectWithBSBtn.frame);

    CALayer *connectWithBSBtnLayerT = [CALayer layer];
    connectWithBSBtnLayerT.frame = CGRectMake(layerX, -15.0f, layerWidth, 1.0);
    connectWithBSBtnLayerT.backgroundColor = [UIColor whiteColor].CGColor;
    connectWithBSBtnLayerT.anchorPoint = CGPointMake(0.5, 0.5);
    [connectWithBSBtn.layer addSublayer:connectWithBSBtnLayerT];
    

    return connectWithBSBtn;
}

- (UIButton*) connectWithBSAccount:(NSString*)BSUserToken
{
    UIButton *connectWithBSBtn = [self displayBetaSeriesButtonForToken:BSUserToken];
    [self contentForBSButton:connectWithBSBtn];

    
    return connectWithBSBtn;
}

// This function put the good text and add event to betaseries button
- (void) contentForBSButton:(UIButton*)BSButton
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"a6843502959f" forHTTPHeaderField:@"X-BetaSeries-Key"];
    [manager.requestSerializer setValue:BSButton.trailerID forHTTPHeaderField:@"X-BetaSeries-Token"];
    [manager GET:@"https://api.betaseries.com/shows/display" parameters:@{@"imdb_id" : self.mediaDatas[@"imdbID"], @"client_id" : @"8bc04c11b4c283b72a3fa48cfc6149f3"} success:^(AFHTTPRequestOperation *operation, id responseObject) {

        BOOL isAmongUserBSAccount = [[responseObject valueForKeyPath:@"show.in_account"] boolValue];
        // Add it
        if (!isAmongUserBSAccount) {
            [BSButton setTitle:NSLocalizedString(@"BSAdd", nil) forState:UIControlStateNormal];
        } else {
            [BSButton setTitle:NSLocalizedString(@"BSRemove", nil) forState:UIControlStateNormal];
        }
        BSButton.enabled = YES;
        self.AmongBSAccount = isAmongUserBSAccount;
        [BSButton addTarget:self action:@selector(toggleAmongBSAccount:) forControlEvents:UIControlEventTouchUpInside];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"contentForBSButton - Error: %@", error);
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
    BSActivityIndicator.center = CGPointMake(25.0, connectWithBSBtn.bounds.size.height / 2);
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
    UIView *storesView = (UIView*)[self.view viewWithTag:16];
    
    NSPredicate *storePredicate = [NSPredicate predicateWithFormat:@"self.class = %@", [StoreButton class]];
    NSArray *storeBtns = [storesView.subviews filteredArrayUsingPredicate:storePredicate];

    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    gravity = [[UIGravityBehavior alloc] initWithItems:@[[storeBtns firstObject]]];
    collision = [[UICollisionBehavior alloc] initWithItems:storeBtns];
    collision.collisionDelegate = self;
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[[storeBtns firstObject]]];
    itemBehaviour.elasticity = 0.9;
    itemBehaviour.allowsRotation = NO;
    itemBehaviour.density = .90000;
    
    [animator addBehavior:gravity];
    [animator addBehavior:itemBehaviour];
    [animator addBehavior:collision];
        
    self.PhysicsAdded = YES;
}

- (void) hideTutorial
{
    
    self.navigationItem.hidesBackButton = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UIView *tutorialView = (UIView*)[[[UIApplication sharedApplication] keyWindow] viewWithTag:8];

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
    mediaCommentsViewController.numberOfComments = self.numberOfComments;
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

- (void) addAndRemoveMediaToList:(id) sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIBarButtonItem *barBtnItem = (UIBarButtonItem*)[self.navigationItem.rightBarButtonItems objectAtIndex:0];
        UIButton *addRemoveFromListBtn = (UIButton *)sender;
        
        barBtnItem.enabled = NO;
        addRemoveFromListBtn.enabled = NO;
        
        if ([barBtnItem.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
            barBtnItem.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
            [addRemoveFromListBtn setTitle:NSLocalizedString(@"RemoveToList", nil) forState:UIControlStateNormal];
            [self addMediaToUserList];
        } else {
            barBtnItem.image = [UIImage imageNamed:@"meetingFavoriteUnselected"];
            [addRemoveFromListBtn setTitle:NSLocalizedString(@"AddToList", nil) forState:UIControlStateNormal];
            [self removeMediaToUserList];
        }
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIButton *addRemoveFromListBtn = (UIButton*)[self.view viewWithTag:20];
        UIBarButtonItem *barBtnItem = (UIBarButtonItem *)sender;
        
        barBtnItem.enabled = NO;
        addRemoveFromListBtn.enabled = NO;
        
        if ([barBtnItem.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
            barBtnItem.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
            [addRemoveFromListBtn setTitle:NSLocalizedString(@"RemoveToList", nil) forState:UIControlStateNormal];
            [self addMediaToUserList];
        } else {
            barBtnItem.image = [UIImage imageNamed:@"meetingFavoriteUnselected"];
            [addRemoveFromListBtn setTitle:NSLocalizedString(@"AddToList", nil) forState:UIControlStateNormal];
            [self removeMediaToUserList];
        }
    }
    
//    // indicate the update of the list
    [JDStatusBarNotification showWithStatus:NSLocalizedString(@"list updated", nil)
                               dismissAfter:3
                                  styleName:@"JDStatusBarStyleDark"];
}

- (void) addAndRemoveMediaToListForBtn:(UIButton*) sender
{
    if ([sender.titleLabel.text isEqualToString:@"hello"]) {
        [self addMediaToUserList];
    } else {
        [self removeMediaToUserList];
    }
    
    [JDStatusBarNotification showWithStatus:NSLocalizedString(@"list updated", nil)
                               dismissAfter:3
                                  styleName:@"JDStatusBarStyleDark"];
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
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbId == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Discovery *userTaste = [Discovery MR_findFirstWithPredicate:userPredicate inContext:localContext];
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
        userTaste.likes = arrayData;
    } completion:^(BOOL success, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(userListHaveBeenUpdate:)]) {
            [self.delegate userListHaveBeenUpdate:userTasteDict];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"endSave" object:nil userInfo:userTasteDict];
        }
        
        UIBarButtonItem *barBtnItem = (UIBarButtonItem*)[self.navigationItem.rightBarButtonItems objectAtIndex:0];
        barBtnItem.enabled = YES;
        UIButton *addRemoveFromListBtn = (UIButton*)[self.view viewWithTag:20];
        addRemoveFromListBtn.enabled = YES;
        
        
        // 7 seconds after update user list we update the database with new datas
        // Like this we are "sure" that user really wants to add this media to his list
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(synchronizeUserListWithServer) object:nil];
        [self performSelector:@selector(synchronizeUserListWithServer) withObject:nil afterDelay:7.5]; // 7.0
        // [pfPushManager notifyUpdateList];
        
//        [self synchronizeUserListWithServer];
        
        [self cancelLocalNotificationWithValueForKey:@"updateList"];
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:2592000]; //One month later 2592000
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 0;
        localNotification.alertAction = nil;
        localNotification.alertBody = NSLocalizedString(@"localNotificationAlertBodyNotUpdateList", nil);
        localNotification.userInfo = @{@"locatificationName" : @"updateList"};
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
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
//         NSLog(@"responseObject: %@", responseObject);
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 9) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Misc

- (void) openStore:(StoreButton*)sender
{
    NSString *storeLink = @"";

    switch (sender.storeName)
    {
        case Amazon:
            storeLink = [NSString stringWithFormat:@"http://www.amazon.fr/gp/product/%@/?ie=UTF8&camp=1642&creative=19458&linkCode=as2&tag=shound-21", sender.storeLink];
            break;
        case Itunes:
            storeLink = [NSString stringWithFormat:@"https://itunes.apple.com/fr/%@?uo=4&at=11lRd6", sender.storeLink];
            break;
        case Fnac:
            storeLink = [NSString stringWithFormat:@"http://www.shound.fr"];
            break;
        default:
            return;
            break;
    }
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeLink]];
}

- (void) introduceMediaToFriendsAction:(UIButton*)sender
{
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
    content.contentTitle = [NSString stringWithFormat:NSLocalizedString(@"FBLinkShareParams_introducemedia_name %@", nil), self.title];
    content.contentDescription = NSLocalizedString(@"FBLinkShareParams_introducemedia_desc", nil);
    // We use the url of the application or else Facebook tricks us
    content.contentURL = [NSURL URLWithString:@"http://www.shound.fr"];
    content.imageURL = [NSURL URLWithString:@"http://shound.fr/shound_logo_fb.jpg"];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
}

- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FBLinkShareParams_postsuccess_title", nil)
                                message:NSLocalizedString(@"FBLinkShareParams_postsuccess", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
}

- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                message:NSLocalizedString(@"FBLinkShareParams_posterror", nil)
                               delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {}

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
