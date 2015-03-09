//
//  ViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


#pragma mark - tag list references
// Tag list
// 1 : Facebook button for connect
// 2 : appMottoText (UILabel)
// 3 : UISearchControllerBG | Background of the input
// 4 : userSelectionTableViewController | Tableview of user taste
// 5 : strokeUnderSearchController
// 6 : UIRefreshControl for userTaste
// 7 : emptyResult : Message for no results
// 8 : emptyUserTasteLabel : Message for no user taste
// 9 : searchLoadingIndicator of search
// 10 : metUserFBView


@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.searchController.searchBar.hidden = NO;
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:4];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
    
    self.searchController.searchBar.hidden = YES;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Variables init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    

    // If NSUserDefaults' geoLocEnabled key is not set we set it to no
    if ([userPreferences objectForKey:@"geoLocEnabled"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"geoLocEnabled"];
    }
    
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(userListHaveBeenUpdateNotificationEvent:) name: @"endSave" object: nil];
    
//    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];

    // Design on the view
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(appearsSearchBar)];
    
    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
    gradientBGView.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradientBGView atIndex:0];
    
    CALayer *bgLayer = [CALayer layer];
    bgLayer.frame = self.view.bounds;
    bgLayer.opacity = .7f;
    bgLayer.name = @"TrianglesBG";
    bgLayer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"TrianglesBG"]].CGColor;
    if (!FBSession.activeSession.isOpen || ![userPreferences objectForKey:@"currentUserfbID"]) {
        [self.view.layer insertSublayer:bgLayer atIndex:1];
    }
    
    
    // Loading indicator of the app
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.view addSubview:loadingIndicator];
    
    
    // Uitableview of user selection (what user likes)
    UITableView *userTasteListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tabBarController.tabBar.bounds)) style:UITableViewStylePlain];
    userTasteListTableView.dataSource = self;
    userTasteListTableView.delegate = self;
    userTasteListTableView.backgroundColor = [UIColor clearColor];
    userTasteListTableView.tag = 4;
    userTasteListTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    userTasteListTableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + 15, 0); //self.bottomLayoutGuide.length
    userTasteListTableView.hidden = YES;
    userTasteListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userTasteListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:userTasteListTableView];
    
    // UITableview of results
    self.searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchResultsController.tableView.dataSource = self;
    self.searchResultsController.tableView.delegate = self;
    self.searchResultsController.tableView.backgroundColor = [UIColor clearColor];
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, screenWidth, screenHeight);
    self.searchResultsController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.searchResultsController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchResultsController.tableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    self.searchResultsController.tableView.separatorInset = UIEdgeInsetsZero;
    
    UIActivityIndicatorView *searchLoadingIndicator = [[UIActivityIndicatorView alloc] init];
    searchLoadingIndicator.center = self.searchResultsController.tableView.center;
    searchLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    searchLoadingIndicator.hidesWhenStopped = YES;
    searchLoadingIndicator.tag = 9;
    searchLoadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.searchResultsController.tableView addSubview:searchLoadingIndicator];
    
    //Message for empty search and no Internet connection
    UILabel *emptyResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, screenWidth - 40, 110)];
    emptyResultLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26.0f];
    emptyResultLabel.text = NSLocalizedString(@"No results", nil);
    emptyResultLabel.textColor = [UIColor whiteColor];
    emptyResultLabel.numberOfLines = 0;
    emptyResultLabel.textAlignment = NSTextAlignmentCenter;
    emptyResultLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    emptyResultLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    emptyResultLabel.layer.shadowRadius = 2.5;
    emptyResultLabel.layer.shadowOpacity = 0.75;
    emptyResultLabel.clipsToBounds = NO;
    emptyResultLabel.layer.masksToBounds = NO;
    emptyResultLabel.tag = 7;
    emptyResultLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 75.0);
    emptyResultLabel.hidden = YES;
    [self.searchResultsController.tableView addSubview:emptyResultLabel];

    
    // Message for empty list taste
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Tap on  to fill your list", nil)];
    UIImage *lensIcon = [UIImage imageNamed:@"lens-icon-message"];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = lensIcon;
    textAttachment.bounds = CGRectMake(150, -15, lensIcon.size.width, lensIcon.size.height);
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSRange r = [[attributedString string] rangeOfString:NSLocalizedString(@"Tap on ", nil)];
    [attributedString insertAttributedString:attrStringWithImage atIndex:(r.location + r.length)];
    
    CGFloat emptyUserTasteLabelPosY = 45;// [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:343 forDimension:screenHeight];
    
    UILabel *emptyUserTasteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyUserTasteLabelPosY, screenWidth, 90)];
    emptyUserTasteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyUserTasteLabel.attributedText = attributedString; //Appuyez {sur la loupe} pour rechercher
    emptyUserTasteLabel.textColor = [UIColor whiteColor];
    emptyUserTasteLabel.numberOfLines = 0;
    emptyUserTasteLabel.textAlignment = NSTextAlignmentCenter;
    emptyUserTasteLabel.tag = 8;
    emptyUserTasteLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyUserTasteLabel.hidden = YES;
    [userTasteListTableView addSubview:emptyUserTasteLabel];
    
    
    // Definition of uisearchcontroller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    self.searchController.searchBar.barTintColor = [UIColor colorWithRed:(2.0/255.0f) green:(17.0/255.0f) blue:(28.0/255.0f) alpha:1.0f];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.placeholder = [NSLocalizedString(@"e.g.", nil) stringByAppendingString:@" Breaking Bad"];
    self.searchController.searchBar.frame = CGRectMake(0, -60.0, self.searchController.searchBar.frame.size.width, self.searchController.searchBar.frame.size.height);
    self.searchController.view.backgroundColor = [UIColor colorWithRed:(2.0/255.0f) green:(17.0/255.0f) blue:(28.0/255.0f) alpha:.85f]; //[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f];
    
    UILabel *infosAboutSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, screenWidth, 50)];
    infosAboutSearchLabel.text = @"Gentoo";
    infosAboutSearchLabel.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    infosAboutSearchLabel.bounds = CGRectInset(infosAboutSearchLabel.frame, 10.0f, 10.0f);
//    [self.searchController.view addSubview:infosAboutSearchLabel];
    
    
//    CALayer *searchControllerBGimgLayer = [CALayer layer];
//    searchControllerBGimgLayer.contents = (id)[UIImage imageNamed:@"triangles-bg.png"].CGImage;
//    searchControllerBGimgLayer.masksToBounds = YES;
//    searchControllerBGimgLayer.contentsGravity = @"resizeAspectFill";
//    searchControllerBGimgLayer.frame = self.view.frame;
//    [self.searchController.view.layer insertSublayer:searchControllerBGimgLayer atIndex:0];

    self.searchController.view.opaque = YES;
    self.searchController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    UITextField *textField = [self.searchController.searchBar valueForKey:@"_searchField"];
    textField.textColor = [UIColor whiteColor];
    
    UIView *UISearchControllerBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)]; // [[UIView alloc] initWithFrame:CGRectMake(0, -50, screenWidth, 64)];
    UISearchControllerBG.tag = 3;
    UISearchControllerBG.clipsToBounds = YES;
    UISearchControllerBG.backgroundColor = [UIColor colorWithRed:(44.0f/255.0f) green:(61.0f/255.0f) blue:(69.0f/255.0f) alpha:1];
    
    [self.searchController.view addSubview:UISearchControllerBG];
    
    
    UIRefreshControl *userSelectRefresh = [[UIRefreshControl alloc] init];
    userSelectRefresh.backgroundColor = [UIColor colorWithRed:(5.0f/255.0f) green:(37.0f/255.0f) blue:(72.0f/255.0f) alpha:.9f];
    userSelectRefresh.tintColor = [UIColor whiteColor];
    userSelectRefresh.tag = 6;
    [userSelectRefresh addTarget:self
                          action:@selector(fetchUserDatas)
                forControlEvents:UIControlEventValueChanged];
    

    categoryList = [@[@"book", @"serie", @"movie"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    filteredTableDatas = [NSMutableDictionary new];
    
    
    // Keep the date of installation of app
    if (![userPreferences objectForKey:@"installationDate"]) {
        [userPreferences setObject:[NSDate date] forKey:@"installationDate"];
    }
    
    // Test if it's the first use
    if (![userPreferences boolForKey:@"firstTime"]) {
        // Display and extra button for
        //[userPreferences setBool:YES forKey:@"firstTime"];
//        NSLog(@"Log tutorial");
        
//        UIView *foo = [[ UIView alloc] initWithFrame:self.view.bounds];
//        foo.backgroundColor = [UIColor redColor];
//        [[[UIApplication sharedApplication] keyWindow] addSubview:foo];
    }
    
    if ([userPreferences objectForKey:@"currentUserfbID"]) {
        [self userConnectionForFbID:[userPreferences objectForKey:@"currentUserfbID"]];
    }
}

#pragma mark - header tableview
- (void) updateCurrentUserStats
{
    int index = 0, tagRange = 10000;
    for (id key in userTasteDict) {
        if ([userTasteDict objectForKey:key] != [NSNull null]) {
            UILabel *statCount = (UILabel*)[self.view viewWithTag:tagRange + index];
            NSString *statCountNumber = [[NSNumber numberWithInteger:[[userTasteDict objectForKey:key] count]] stringValue];
            statCount.text = statCountNumber;
            
            index++;
        }
    }
}


- (void) displayCurrentUserStats
{
    UITableView *userTasteListTableView = (UITableView*)[self.view viewWithTag:4];
    
    UIView *metUserFBView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 172)];
    metUserFBView.backgroundColor = [UIColor clearColor];
    metUserFBView.tag = 10;
    
    int tagRange = 10000;
    float widthViews = 99.0f;
    for (int i = 0; i < [[userTasteDict filterKeysForNullObj] count]; i++) {
        NSString *title = [NSLocalizedString([[[userTasteDict filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:i], nil) uppercaseString];
        
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(widthViews, 0.0f, 1.0, 70.0f);
        rightBorder.backgroundColor = [UIColor whiteColor].CGColor;
        
        CGRect statContainerFrame = CGRectMake(0 + (95 * i),
                                               metUserFBView.frame.size.height - 70,
                                               widthViews, 70);
        UIView *statContainer = [[UIView alloc] initWithFrame:statContainerFrame];
        statContainer.backgroundColor = [UIColor clearColor];
        [metUserFBView addSubview:statContainer];
        
        if ( i != ([[userTasteDict filterKeysForNullObj] count] - 1)) {
            [statContainer.layer addSublayer:rightBorder];
        }
        
        UILabel *statTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, widthViews, 30)];
        statTitle.textColor = [UIColor whiteColor];
        statTitle.backgroundColor = [UIColor clearColor];
        statTitle.text = title;
        statTitle.layer.shadowColor = [[UIColor blackColor] CGColor];
        statTitle.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        statTitle.layer.shadowRadius = 2.5;
        statTitle.layer.shadowOpacity = 0.75;
        [statContainer addSubview:statTitle];
        
        UILabel *statCount = [[UILabel alloc] initWithFrame:CGRectMake(12, statContainer.frame.size.height - 34, widthViews, 35.0)];
        statCount.textColor = [UIColor whiteColor];
        statCount.backgroundColor = [UIColor clearColor];
        statCount.text = title;
        statCount.tag = tagRange + i;
        statCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45.0f];
        statCount.layer.shadowColor = [[UIColor blackColor] CGColor];
        statCount.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        statCount.layer.shadowRadius = 2.5;
        statCount.layer.shadowOpacity = 0.75;
        
        NSString *statCountNumber = [[NSNumber numberWithInteger:[[userTasteDict objectForKey:[[[userTasteDict filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:i]] count]] stringValue];
        statCount.text = statCountNumber;
        
        [statContainer insertSubview:statCount atIndex:10];
    }
    
    userTasteListTableView.tableHeaderView = metUserFBView;
    
    [userTasteListTableView setContentOffset:CGPointMake(0, 0)]; //metUserFBView.bounds.size.height
    
    [self displayCurrentUserfbImgProfile];
}

- (void) displayCurrentUserfbImgProfile
{
    UIView *metUserFBView = (UIView*)[self.view viewWithTag:10];

    int intWidthScreen = screenWidth;
    int heightImg = 172;
    
    NSString *fbMetUserString = [[userPreferences objectForKey:@"currentUserfbID"] stringValue];
    NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", fbMetUserString, intWidthScreen, heightImg];
    
    UIImageView *metUserFBImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, heightImg)];
    [metUserFBImgView setImageWithURL:[NSURL URLWithString:metUserFBImgURL] placeholderImage:[UIImage animatedImageNamed:@"list-tab-icon2" duration:.1f]];
    metUserFBImgView.contentMode = UIViewContentModeScaleAspectFit;
    metUserFBImgView.backgroundColor = [UIColor clearColor];
    [metUserFBView insertSubview:metUserFBImgView atIndex:0];
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = metUserFBImgView.bounds;
    [metUserFBImgView addSubview:effectView];
}


- (void) fetchUserDatas
{
    UIRefreshControl *userSelectRefresh = (UIRefreshControl*)[self.view viewWithTag:6];
    [userSelectRefresh endRefreshing];
}


- (NSArray*) fetchDatas
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
 
    return json;
}

#pragma mark - Search Bar
// Search system
- (void) fetchDatasFromServerWithQuery:(NSString*)query completion:(void (^)(id result))completion
{
    if ([query length] == 0) {
        return;
    }

   
    NSString *linkAPI = [settingsDict valueForKey:@"apiPath"];
    linkAPI = [linkAPI stringByAppendingString:@"search.php"];
   // Loading indicator of the app
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    
    [self.view insertSubview:loadingIndicator aboveSubview:self.searchController.searchBar];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:linkAPI parameters:@{ @"query" : query } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion)
            completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        UIAlertView *errConnectionAlertView = [[UIAlertView alloc] initWithTitle:@"Oups" message:@"Il semblerait qu'on ait du mal à afficher cette fiche. \n Réessayez plus tard." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [errConnectionAlertView show];
//        [loadingIndicator stopAnimating];
    }];
}

- (void) appearsSearchBar
{
    self.searchController.searchBar.frame = CGRectMake(0, 9, self.searchController.searchBar.frame.size.width, self.searchController.searchBar.frame.size.height);

    self.searchController.view.alpha = 1;
//    self.searchController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.95f];
    [self.searchController.searchBar becomeFirstResponder];
    
//    [UIView animateWithDuration: 0.1
//                          delay: 0.0
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.searchController.view.alpha = 1;
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) disappearsSearchBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.searchController.searchBar.frame = CGRectMake(0, -60.0,
                                                       self.searchController.searchBar.frame.size.width, self.searchController.searchBar.frame.size.height);
   
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.searchController.view.alpha = 0;
                     }
                     completion:nil];
    
    
    [self.searchController.searchBar resignFirstResponder];

    [self.tabBarController.tabBar setHidden:NO];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self disappearsSearchBar];
}

- (void) didDismissSearchController:(UISearchController *)searchController
{
    [self disappearsSearchBar];
}


//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
//    [self appearsSearchBar];
//    
//    return YES;
//}



// This method have to be called when the user is connected
- (void) userConnectionForFbID:(NSNumber*)userfbID
{
    // We retrieve user taste if it exists in local
    self.userTaste = [UserTaste MR_findFirstByAttribute:@"fbid"
                                              withValue:userfbID];
    userTasteDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       [NSNull null], @"book",
                       [NSNull null], @"movie",
                       [NSNull null], @"serie",
                       nil];
    UITableView *userTasteListTableView = (UITableView*)[self.view viewWithTag:4];
    userTasteListTableView.hidden = YES;
    [loadingIndicator startAnimating];
    if (self.userTaste) {
        // then put it into the NSDictionary of "taste" only if the dict is not nil (really nil)
        if ([NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] != nil) {
            userTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] mutableCopy];
        }
        [self displayUserTasteList];
//        NSLog(@"fetch local datas");
    } else {
        [self getServerDatasForFbID:[userPreferences objectForKey:@"currentUserfbID"] isUpdate:NO];
//        NSLog(@"fetch server datas");
    }
    
    
    // Update location from server
    if ([userPreferences objectForKey:@"lastManualUpdate"] && [self connected] == YES) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *lastDataFetchingInterval = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[userPreferences objectForKey:@"lastManualUpdate"] toDate:[NSDate date] options:0];
        
        NSInteger hours = [lastDataFetchingInterval hour];
        NSInteger minutes = [lastDataFetchingInterval minute];
        NSInteger seconds = [lastDataFetchingInterval second];
        
        // We update user location to the server at launch only every 2 hours
        NSInteger delayLastMeetingUser = (hours * 60 * 60) + (minutes * 60) + seconds;
        if (delayLastMeetingUser > 7200)
        {
            [self updateUserLocation:[userPreferences objectForKey:@"currentUserfbID"]];
        }
    }
}

- (void) displayUserTasteList
{
    [self.view addSubview: self.searchController.searchBar];
 
    
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    userSelectionTableView.alpha = 0;
    userSelectionTableView.hidden = NO;
    
    UILabel *appnameView = (UILabel*)[self.view viewWithTag:2];
    
    for (CALayer *layer in [self.view.layer sublayers]) {
        
        if ([[layer name] isEqualToString:@"TrianglesBG"]) {
            layer.opacity = 0;
        }
    }
    
    if (FBSession.activeSession.isOpen || [userPreferences objectForKey:@"currentUserfbID"]) {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        self.tabBarController.tabBar.hidden = NO;
        [userSelectionTableView reloadData];
        appnameView.hidden = YES;
        appnameView.alpha = 0;
        userSelectionTableView.alpha = 1;
        
        [self displayCurrentUserStats];
        
        
        return;
    }
    
    
    
    [UIView animateWithDuration:0.5 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         appnameView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5 delay:0.2
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              userSelectionTableView.alpha = 1;
                                          }
                                          completion:nil];
                         
                         [[self navigationController] setNavigationBarHidden:NO animated:YES];
                         self.tabBarController.tabBar.hidden = NO;
                         [userSelectionTableView reloadData];
                         appnameView.hidden = YES;
                         appnameView.alpha = 0;
                     }];
}

- (void) userLoggedOutOffb:(id)uselessObj completion:(void (^)(BOOL success))completionBlock
{
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    
    [userTasteDict removeAllObjects];
    
    UILabel *appnameView = (UILabel*)[self.view viewWithTag:2];
    appnameView.hidden = NO;
    
    UILabel *emptyUserTasteLabel = (UILabel*)[self.view viewWithTag:8];
    
    for (CALayer *layer in [self.view.layer sublayers]) {
        
        if ([[layer name] isEqualToString:@"TrianglesBG"]) {
            layer.opacity = 1;
        }
    }

    
    [UIView animateWithDuration:0.5 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         userSelectionTableView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5 delay:0.2
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              appnameView.alpha = 1;
                                          }
                                          completion:nil];
                         
                         [[self navigationController] setNavigationBarHidden:YES animated:YES];
                         self.tabBarController.tabBar.hidden = YES;
                         
                         [self.searchController.searchBar removeFromSuperview];
                         emptyUserTasteLabel.hidden = YES;
                         userSelectionTableView.hidden = YES;
                     }];
    
    // user logged out so we remove his key into the NSUserdefault
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUserfbID"];
    
    self.FirstFBLoginDone = YES;
    
    if (completionBlock != nil) completionBlock(YES);
}


//- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
//{
//    if(!self.isFirstFBLoginDone) {
//        return;
//    }
//    
//    FBLoginView *fbLoginButton = (FBLoginView*)[self.view viewWithTag:1];
//    fbLoginButton.hidden = YES;
//    // We format the user id (NSString) to an NSNumber to be stored in NSUserDefault key
//    NSNumberFormatter *fbIDFormatter = [[NSNumberFormatter alloc] init];
//    [fbIDFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    NSNumber *fbIDNumber = [fbIDFormatter numberFromString:user.objectID];
//    
//    [userPreferences setObject:fbIDNumber forKey:@"currentUserfbID"];
//    // This bool is here to manage some weirdo behaviour with SWRevealViewController (not sure)
//    
//    
////    NSLog(@"user %@ | %@:", user, user.objectID);
//    
//    // Here we add userid (aka user.objectID) to the database
//    
//    //        UserTaste *userTaste = [UserTaste  MR_createEntity];
//    //        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:productManagers];
//    //        userTaste.taste = arrayData;
//    //        userTaste.fbid = [NSNumber numberWithLong:1387984218159370];
//    //        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//
//    [self userConnectionForFbID:fbIDNumber];
//    
//    self.FirstFBLoginDone = NO;
//}
//
//
//// When user logged out
//- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
//{
////    ConnectViewController *connectViewController = [ConnectViewController new];
////    
////    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
////    [mainWindow addSubview: connectViewController.view];
////    [self userLoggedOutOffb:nil completion:^(BOOL success) {
////        if (success) {
////            [self.tabBarController setSelectedIndex:0];
////            FBLoginView *fbLoginButton = (FBLoginView*)[self.view viewWithTag:1];
////            fbLoginButton.frame = CGRectMake((self.view.center.x - (fbLoginButton.frame.size.width / 2)), screenHeight - 150, 218, 46);
////            fbLoginButton.hidden = NO;
////        } else {
////            // Could not log in. Display alert to user.
////        }
////    }];
//}


#pragma mark - Tableview configuration

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        NSString *sectionTitle = [categoryList objectAtIndex:section];
        NSArray *sectionElements = [filteredTableDatas objectForKey:sectionTitle];
        
        return sectionElements.count;
    } else {
        
        NSString *sectionTitle = [[[userTasteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
        NSArray *sectionElements = [userTasteDict objectForKey:sectionTitle];
        // If the category is empty so the section not appears
        if ([sectionElements isKindOfClass:[NSNull class]]) {
            return 0;
        }

        return sectionElements.count;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        // This label is also used for no internet connexion for search
        UILabel *emptyResultLabel = (UILabel*)[self.searchResultsController.tableView viewWithTag:7];

        if ([self connected] == NO) {
            emptyResultLabel.text = NSLocalizedString(@"No internet connection", nil);
            emptyResultLabel.hidden = NO;
            
            return 0;
        }
        
        if ([[filteredTableDatas allKeys] count] == 0 && [self.searchController.searchBar.text length] != 0) {
            emptyResultLabel.text = NSLocalizedString(@"No results", nil);
            emptyResultLabel.hidden = NO;
            
            return 0;
        }
        emptyResultLabel.hidden = YES;
        
        return [categoryList count];
    } else {
        
        // User have no list of taste
        UILabel *emptyUserTasteLabel = (UILabel*)[self.view viewWithTag:8];
        BOOL IsTableViewEmpty = YES;
        // This loop is here to check the content of all NSDict keys
        for (int i = 0; i < [[userTasteDict allKeys] count]; i++) {
            if (![[userTasteDict objectForKey:[[userTasteDict allKeys] objectAtIndex:i]] isKindOfClass:[NSNull class]]) {
                if ([[userTasteDict objectForKey:[[userTasteDict allKeys] objectAtIndex:i]] count] != 0) {
                    IsTableViewEmpty = NO;
                }
            }
        }
        
        if (IsTableViewEmpty == YES && (FBSession.activeSession.isOpen || [userPreferences objectForKey:@"currentUserfbID"])) {
            emptyUserTasteLabel.hidden = NO;
            [loadingIndicator stopAnimating];
            
            return 0;
        }
        emptyUserTasteLabel.hidden = YES;
        
        return userTasteDict.count;
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 52.0;
    }
}

- (NSArray *) rightCellButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:NSLocalizedString(@"Delete", nil)];
    
    return rightUtilityButtons;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
    
    NSString *sectionTitle = [categoryList objectAtIndex:indexPath.section];
    NSString *title, *year, *imdbID;
    ShareListMediaTableViewCell *cell;
    
    //Search results tableview
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray *rowsOfSection = [filteredTableDatas objectForKey:sectionTitle];
        if (cell == nil) {
            cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.delegate = self;
            
            cell.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            cell.textLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
            cell.textLabel.layer.shadowOpacity = .95f;
            
            
            cell.detailTextLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            cell.detailTextLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
            cell.detailTextLabel.layer.shadowOpacity = .95f;
        }
        
        cell.model = [rowsOfSection objectAtIndex:indexPath.row];


        title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
        year = [NSString stringWithFormat:@"%@", [[rowsOfSection objectAtIndex:indexPath.row] valueForKey:@"year"]];
        cell.textLabel.text = title;
        cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.60];
        cell.textLabel.textColor = [UIColor whiteColor];
        
//        cell.alpha = .7f;
        
        if (![userTasteDict[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] isEqual:[NSNull null]]) {
            if ([[userTasteDict[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] valueForKey:@"imdbID"] containsObject:[[rowsOfSection objectAtIndex:indexPath.row] objectForKey:@"imdbID"]]) {
                cell.imageView.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
            } else {
                cell.imageView.image = nil;
            }
        }
        
        // This statement is here for empty key
        // Or else we'll try to compare a NSNull object
//        if ([userTasteDict objectForKey:[[rowsOfSection objectAtIndex:indexPath.row] valueForKey:@"type"]] != [NSNull null]) {
//            //         If this row is among user current taste list so we put a star
//            if ([[userTasteDict[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] valueForKey:@"imdbID"] containsObject:[[rowsOfSection objectAtIndex:indexPath.row] objectForKey:@"imdbID"]]) {
//                CALayer *sublayer = [CALayer layer];
//                sublayer.backgroundColor = [UIColor clearColor].CGColor;
//                sublayer.shadowColor = [UIColor clearColor].CGColor;
//                sublayer.frame = CGRectMake(screenWidth - 60, (cellFrame.size.height / 2) - 11, 22, 22);
//                sublayer.contents = (id) [UIImage imageNamed:@"meetingFavoriteSelected"].CGImage;
//                
//                [cell.layer addSublayer:sublayer];
//            } else {
//                cell.imageView.image = nil;
//            }
//        }
        
//        [UIView transitionWithView:cell
//                          duration:.7f
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{cell.alpha = 1;}
//                        completion:NULL];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray *rowsOfSection = [userTasteDict objectForKey:sectionTitle];
        CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
        
        title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
        imdbID = [rowsOfSection objectAtIndex:indexPath.row][@"imdbID"];
        
        if (cell == nil) {
            cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.delegate = self;
            cell.rightUtilityButtons = [self rightCellButtons];
        }
        cell.delegate = self;
        // For "Classic mode" we want a cell's background more opaque
        cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.35];; //[UIColor colorWithRed:(246.0/255.0) green:(246.0/255.0) blue:(246.0/255.0) alpha:0.87];
        
        
        // We hide this part to get easily datas
        cell.textLabel.frame = cellFrame;
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        cell.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.textLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
        cell.textLabel.layer.shadowOpacity = .75f;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //            cell.textLabel.hidden = YES;
        cell.model = [rowsOfSection objectAtIndex:indexPath.row];
        
        
        if (imdbID != nil) {
            [self getImageCellForData:[rowsOfSection objectAtIndex:indexPath.row] aCell:cell];
        }
        
        UIView *bgColorView = [UIView new];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.7f]];
        [cell setSelectedBackgroundView:bgColorView];

        cell.textLabel.text = title;
        cell.alpha = .3f;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = year;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:(137.0/255.0) green:(137.0/255.0) blue:(137.0/255.0) alpha:1];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    cell.indentationLevel = 1;
    
    
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [loadingIndicator stopAnimating];
    }
}

- (void) getImageCellForData:(id)model aCell:(UITableViewCell*)cell
{
    CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
    
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

    
//    CALayer *imgLayer = [CALayer layer];
//    imgLayer.frame = cellFrame;
//    [imgLayer addSublayer:gradientLayer];

    
    NSString *apiLink;

    __block NSString *imgURL;
    if ([model[@"type"] isEqualToString:@"movie"]) {
        apiLink = kJLTMDbMovie;
    } else {
        apiLink = kJLTMDbFind;
    }

    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    [[JLTMDbClient sharedAPIInstance] setAPIKey:@"f09cf27014943c8114e504bf5fbd352b"];
    
    [[JLTMDbClient sharedAPIInstance] GET:apiLink withParameters:@{@"id": model[@"imdbID"], @"language": userLanguage, @"external_source": @"imdb_id"} andResponseBlock:^(id responseObject, NSError *error) {
        if(!error){
            if ([model[@"type"] isEqualToString:@"serie"] && [[responseObject valueForKeyPath:@"tv_results.poster_path"] count] != 0) {
                imgURL = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
            } else {
                if([responseObject[@"poster_path"] length] != 0) {
                    imgURL = responseObject[@"poster_path"];
                }
            }
            
            imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w396/%@", imgURL];
            [imgBackground setImageWithURL:
             [NSURL URLWithString:imgDistURL]
                          placeholderImage:[UIImage imageNamed:@"TrianglesBG"]];
            [imgBackground.layer insertSublayer:gradientLayer atIndex:0];
            
            [UIView transitionWithView:cell
                              duration:.15f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{cell.alpha = 1;}
                            completion:NULL];
        }
    }];
}

- (NSArray *) rightButtonsForUserFavs
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:(236.0/255.0f) green:(31.0/255.0f) blue:(63.0/255.0f) alpha:1.0]
                     title:@"Retirer"];

    return rightUtilityButtons;
}


- (void)swipeableTableViewCell:(ShareListMediaTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            UITableView *tableView = (UITableView*)[self.view viewWithTag:4];
            
            __block NSIndexPath *cellIndexPath = [tableView indexPathForCell:cell];

//            [[userTasteDict objectForKey:[cell.model valueForKey:@"type"]] removeObject:cell.model];
            
            NSMutableArray *updatedUserTaste = [[userTasteDict objectForKey:[cell.model valueForKey:@"type"]] mutableCopy];
            [updatedUserTaste removeObjectsInArray:[updatedUserTaste filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imdbID == %@", [cell.model valueForKey:@"imdbID"]]]];
            
            [userTasteDict removeObjectForKey:[cell.model valueForKey:@"type"]];
            [userTasteDict setObject:updatedUserTaste forKey:[cell.model valueForKey:@"type"]];
            
            NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", [userPreferences objectForKey:@"currentUserfbID"]];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                UserTaste *userTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:localContext];
                NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
                userTaste.taste = arrayData;
            } completion:^(BOOL success, NSError *error) {
                BOOL lastItem = ([[userTasteDict objectForKey:[cell.model valueForKey:@"type"]] count] == 0);
                
                if (lastItem) {
//                    [userTasteDict removeObjectForKey:[cell.model valueForKey:@"type"]];
                    [tableView reloadData];
                } else {
                    [tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
                }
                [self updateCurrentUserStats];
//                [tableView deleteRowsAtIndexPaths:@[cellIndexPath]
//                           withRowAnimation:UITableViewRowAnimationFade];
//                [self getServerDatasForFbID:[userPreferences objectForKey:@"currentUserfbID"] isUpdate:YES];
            }];
            break;
        }
        default:
            break;
    }
}

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL) swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"foof");
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
//    NSString *titleForHeader = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    
    ShareListMediaTableViewCell *selectedCell = (ShareListMediaTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSObject *object = selectedCell.model;
    
    DetailsMediaViewController *detailsMediaViewController = [DetailsMediaViewController new];
    detailsMediaViewController.mediaDatas = object;
    detailsMediaViewController.delegate = self;
//    // Trick for weird issue about present view and pushview
    detailsMediaViewController.tabBarController.tabBar.hidden = YES;
    
    [self disappearsSearchBar];
    [self.searchController setActive:NO];
    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
}

// Title of categories
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 16.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 69.0)];
    headerView.opaque = YES;

    NSString *title = [NSLocalizedString([categoryList objectAtIndex:section], nil) uppercaseString];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 69.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        headerView.backgroundColor = [UIColor colorWithWhite:.95 alpha:.80f];
        label.textColor = [UIColor blackColor];
    } else {
        headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.9f];
        label.textColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1];
    }
    [headerView addSubview:label];
    
    return headerView;
}

#pragma mark - Custom methods

- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension {
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

#pragma mark - update/fetch datas

// This method retrieve an readable json of user taste for the database
- (NSString *) updateTasteForServer
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userTasteDict
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
//        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
   
        return jsonString;
    }
}

- (void) userListHaveBeenUpdateNotificationEvent:(NSNotification *)note
{
    [self userListHaveBeenUpdate:[note userInfo]];
    
}


- (void) userListHaveBeenUpdate:(NSDictionary *)dict
{
    // We update the view behind the user like this when he comes back the view is updated
    userTasteDict = [dict mutableCopy];
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    userSelectionTableView.hidden = NO;
    [userSelectionTableView reloadData];
    
    [self updateCurrentUserStats];
}

- (void) updateUserLocation:(NSNumber*)userfbID
{
    if ((!FBSession.activeSession.isOpen || ![userPreferences objectForKey:@"currentUserfbID"]) && [self connected] == NO) {
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"]) {
        return;
    }
    
    if (!self.locationManager) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.distanceFilter = 200;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"fbiduser": userfbID,
                             @"latitude": [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude],
                             @"longitude": [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude]};
    NSString *updateUserLocationURL = [[settingsDict valueForKey:@"apiPath"] stringByAppendingString:@"updateUserLocation.php"];
    [manager POST:updateUserLocationURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.locationManager stopUpdatingLocation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

// This methods allows to retrieve and send (?) user datas from the server
- (void) getServerDatasForFbID:(NSNumber*)userfbID isUpdate:(BOOL)isUpdate
{
    NSURL *aUrl = [NSURL URLWithString:[[settingsDict valueForKey:@"apiPath"] stringByAppendingString:@"connexion.php"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];

    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@", userfbID];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Server sends back some datas
    if (self.responseData != nil) {
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        // When responseString var gets the raw data from the server we clear it
        self.responseData = nil;
        self.responseData = [NSMutableData new];
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        // There is some datas from the server
        if (![[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] isKindOfClass:[NSNull class]]) {
            userTasteDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            // We order the NSDictionary key
            for (NSString* key in [userTasteDict allKeys])
            {
                if ([userTasteDict objectForKey:key] != [NSNull null]) {
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                    NSArray *sortedCategory = [[userTasteDict objectForKey:key] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
                    [userTasteDict removeObjectForKey:key];
                    [userTasteDict setObject:sortedCategory forKey:key];
                }
            }
            [self displayUserTasteList];
        } else {
//            NSLog(@"no user datas");
        }
        
        UserTaste *isNewUser = [UserTaste MR_findFirstByAttribute:@"fbid"
                                                        withValue:[userPreferences objectForKey:@"currentUserfbID"]];
    
        // This is the first time for user
        if (isNewUser == nil) {
            UserTaste *userTaste = [UserTaste MR_createEntity];
            
            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
            userTaste.taste = arrayData;
            userTaste.fbid = [userPreferences objectForKey:@"currentUserfbID"];
            userTaste.isFavorite = NO; //User cannot favorite himself (by the way it's impossible technically)
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
}

- (BOOL) connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}


#pragma mark - Content filtering

- (void) updateSearchResultsForSearchController:(UISearchController *) searchController
{
    UIActivityIndicatorView *searchLoadingIndicator = (UIActivityIndicatorView*)[self.searchResultsController.tableView viewWithTag:9];
    [searchLoadingIndicator startAnimating];

    //We wait X seconds before query the server for performances and "limit" the bandwidth
    [self performSelector:@selector(getDatasFromServerForSearchController:) withObject:searchController afterDelay:1.7];
}

- (void) getDatasFromServerForSearchController:(UISearchController *) searchController {
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, CGRectGetWidth(self.searchResultsController.tableView.frame), CGRectGetHeight(self.searchResultsController.tableView.frame));
    
    NSString *searchString = [searchController.searchBar text];
    
    [filteredTableDatas removeAllObjects];
    
    if (![self connected]) {
        UIActivityIndicatorView *searchLoadingIndicator = (UIActivityIndicatorView*)[self.searchResultsController.tableView viewWithTag:9];
        [searchLoadingIndicator stopAnimating];
        [self.searchResultsController.tableView reloadData];
        
        return;
    }
    
    // Fetch online datas
    [self fetchDatasFromServerWithQuery:searchString completion:^(NSArray *result){
        for (int i = 0; i < [[result valueForKey:@"type"] count]; i++) {
            NSPredicate *nameForTypePredicate = [NSPredicate predicateWithFormat:@"type = %@", [[result valueForKey:@"type"] objectAtIndex:i]];
            
            // For each category we add an alphabetical ordered NSArray of medias which match with the NSPredicate above
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *datasToSort = [[NSArray alloc] initWithArray:[[result filteredArrayUsingPredicate:nameForTypePredicate] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
            NSArray *sortedDatas = [[NSArray alloc] initWithArray:[datasToSort copy]];
            [filteredTableDatas setValue:sortedDatas forKey:[[result valueForKey:@"type"] objectAtIndex:i]];
        }
        
        [self.searchResultsController.tableView reloadData];
        
        UIActivityIndicatorView *searchLoadingIndicator = (UIActivityIndicatorView*)[self.searchResultsController.tableView viewWithTag:9];
        [searchLoadingIndicator stopAnimating];
    }];
    
//    // Fetch local datas
//    NSMutableArray *filteredDatas = [[NSMutableArray alloc] init];
//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", searchString];
//    [filteredDatas setArray:[APIdatas filteredArrayUsingPredicate:searchPredicate]];
//    UIActivityIndicatorView *searchLoadingIndicator = (UIActivityIndicatorView*)[self.searchResultsController.tableView viewWithTag:9];
//    [searchLoadingIndicator stopAnimating];
//    for (int i = 0; i < [[filteredDatas valueForKey:@"type"] count]; i++) {
//        
//        // This predicate manage a media in several categories
//        NSPredicate *nameForTypePredicate = [NSPredicate predicateWithFormat:@"type = %@", [[filteredDatas valueForKey:@"type"] objectAtIndex:i]];
//
//        // For each category we add an alphabetical ordered NSArray of medias which match with the NSPredicate above
//        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//        NSArray *datasToSort = [[NSArray alloc] initWithArray:[[filteredDatas filteredArrayUsingPredicate:nameForTypePredicate] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
//        NSArray *sortedDatas = [[NSArray alloc] initWithArray:[datasToSort copy]];
//        [filteredTableDatas setValue:sortedDatas forKey:[[filteredDatas valueForKey:@"type"] objectAtIndex:i]];
//    }
//    
//    [self.searchResultsController.tableView reloadData];
    
    // Blurred background
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage: [self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = .95f;
    [bluredImageView setFrame:self.searchResultsController.tableView.frame];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = bluredImageView.bounds;
    [bluredImageView addSubview:visualEffectView];
    
    self.searchResultsController.tableView.backgroundView = bluredImageView;
//    self.searchController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.05f];
}



- (UIImage*) changeImg:(UIImage*)image forColor:(UIColor*)aColor
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Avoid img flip after CGContextClipToMask method
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}



#pragma mark - Delegate methods

// When the user starts to scroll we hide the keyboard
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchController.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
