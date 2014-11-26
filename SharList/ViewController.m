//
//  ViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign, getter=isConnectedToInternet) BOOL ConnectedToInternet;


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


@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.searchController.searchBar.hidden = NO;
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:4];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    if (!FBSession.activeSession.isOpen) {
        self.navigationController.navigationBar.hidden = YES;
    }
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
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.omdbapi.com/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                self.ConnectedToInternet = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                self.ConnectedToInternet = NO;
                break;
        }
    }];
    
    // Variables init
    USERALREADYMADEARESEARCH = NO;
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];

    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    
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
    
    bgLayer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"triangles-bg.png"]].CGColor;
//    [self.view.layer insertSublayer:bgLayer atIndex:1];
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:
//                      @"app" ofType:@"plist"];
//    // Build the array from the plist
//    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
//    
//    NSArray *value = [dict valueForKey:@"apiURL"];
//    NSLog(@"foo : %@", value );
    
    // Motto of the app
    UIView *appnameView = [[UIView alloc] initWithFrame:CGRectMake([self computeRatio:44.0 forDimension:screenWidth],
                                                                  [self computeRatio:104.0 forDimension:screenHeight],
                                                                  screenWidth, 61)];
    appnameView.tag = 2;
    appnameView.backgroundColor = [UIColor clearColor];
    appnameView.opaque = YES;
    [self.view addSubview:appnameView];
    
    UILabel *appnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    appnameLabel.text = @"Shike";
    appnameLabel.font = [UIFont fontWithName:@"Helvetica" size:50.0];
    appnameLabel.textColor = [UIColor whiteColor];
    appnameLabel.textAlignment = NSTextAlignmentLeft;
    [appnameView addSubview:appnameLabel];
    
    UILabel *appMottoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 51, screenWidth, 15)];
    appMottoLabel.text = [@"Faites découvrir au monde ce que vous aimez" uppercaseString];
    appMottoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    appMottoLabel.textColor = [UIColor whiteColor];
    appMottoLabel.textAlignment = NSTextAlignmentLeft;
    [appnameView addSubview:appMottoLabel];
    
    

    
    // Facebook login
    FBLoginView *fbLoginButton = [FBLoginView new];
    fbLoginButton.delegate = self;
    fbLoginButton.tag = 1;
    fbLoginButton.frame = CGRectMake(51, screenHeight - 150, 218, 46);
//    fbLoginButton.frame = CGRectOffset(fbLoginButton.frame, (self.view.center.x - (fbLoginButton.frame.size.width / 2)), [self computeRatio:740.0 forDimension:screenHeight]);
    
    
    // Uitableview of user selection (what user likes)
    UITableViewController *userSelectionTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    userSelectionTableViewController.tableView.frame = CGRectMake(0, 0, screenWidth, screenHeight - 49); //[self computeRatio:800.0 forDimension:screenHeight] + 44
    userSelectionTableViewController.tableView.dataSource = self;
    userSelectionTableViewController.tableView.delegate = self;
    userSelectionTableViewController.tableView.backgroundColor = [UIColor clearColor];
    userSelectionTableViewController.tableView.tag = 4;
    userSelectionTableViewController.tableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    //    userSelectionTableViewController.refreshControl = userSelectRefresh;
    userSelectionTableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableViewController.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:userSelectionTableViewController.tableView];
    
    // UITableview of results
    self.searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchResultsController.tableView.dataSource = self;
    self.searchResultsController.tableView.delegate = self;
    self.searchResultsController.tableView.backgroundColor = [UIColor clearColor];
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, screenWidth, screenHeight);
    self.searchResultsController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.searchResultsController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchResultsController.tableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    
    //Message for empty search
    UILabel *emptyResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, screenWidth, 90)];
    emptyResultLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26.0f];
    emptyResultLabel.text = @"No results";
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
    emptyResultLabel.hidden = YES;
    [self.searchResultsController.view addSubview:emptyResultLabel];

    
    // Message for empty list taste
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Appuyez sur   pour remplir votre liste"];
    UIImage *lensIcon = [self changeImg:[UIImage imageNamed:@"lens-icon"] forColor:[UIColor whiteColor]];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = lensIcon;
    textAttachment.bounds = CGRectMake(150, -15, lensIcon.size.width, lensIcon.size.height);
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSRange r = [[attributedString string] rangeOfString:@"Appuyez sur  "];
    [attributedString insertAttributedString:attrStringWithImage atIndex:(r.location + r.length)];
    
    CGFloat emptyUserTasteLabelPosY = 45;// [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:343 forDimension:screenHeight];
    
    UILabel *emptyUserTasteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyUserTasteLabelPosY, screenWidth, 90)];
    emptyUserTasteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyUserTasteLabel.attributedText = attributedString;
    emptyUserTasteLabel.textColor = [UIColor whiteColor];
    emptyUserTasteLabel.numberOfLines = 0;
    emptyUserTasteLabel.textAlignment = NSTextAlignmentCenter;
    emptyUserTasteLabel.tag = 8;
    emptyUserTasteLabel.hidden = YES;
    [self.view addSubview:emptyUserTasteLabel];
    
    
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
    self.searchController.searchBar.placeholder = @"Ex. Breaking Bad";
    self.searchController.searchBar.frame = CGRectMake(0, -60.0,
                                                       self.searchController.searchBar.frame.size.width, self.searchController.searchBar.frame.size.height);
    self.searchController.view.backgroundColor = [UIColor colorWithRed:(2.0/255.0f) green:(17.0/255.0f) blue:(28.0/255.0f) alpha:.85f]; //[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f];
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
    

    APIdatas = [[NSArray alloc] initWithArray:[self fetchDatas]];
//    NSLog(@"APIdatas : %@", APIdatas);
    categoryList = [[[self fetchDatas] valueForKeyPath:@"@distinctUnionOfObjects.type"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    filteredTableDatas = [[NSMutableDictionary alloc] init];
    
     [self.view addSubview:fbLoginButton];
    // Detect if user not is connected
    if (!FBSession.activeSession.isOpen) {
        // We don't want message for empty user list for no fb connexion
        [self.view addSubview:fbLoginButton];
    } else {

//        if ([userPreferences boolForKey:@"appHasBeenLaunched"]) {
//            [self userConnectionForFbID:[userPreferences objectForKey:@"fbUserID"]];
//        }
    }
    
    // Test if it's the first use
    if (![userPreferences boolForKey:@"firstTime"]) {
        // Display and extra button for
        [userPreferences setBool:YES forKey:@"firstTime"];
    }
    
    
//    [UserTaste MR_truncateAll];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:24];
    [comps setMonth:11];
    [comps setYear:2014];
    [comps setMinute:9];
    [comps setHour:43];

    NSDate *newDate = [cal dateFromComponents:comps];
    
    NSArray *fooArray = @[
                          @{ @"imdbID": @"tt1486217", @"id": @21, @"year": @2008, @"name" : @"Archer", @"type" : @"serie" },
                          @{ @"imdbID": @"tt2372162", @"id": @23, @"year": @2008, @"name" : @"Orange is the new Black", @"type" : @"serie" },
                          @{ @"imdbID": @"tt1826940", @"id": @27, @"year": @2008, @"name" : @"New Girl", @"type" : @"serie" },
                         ];

    NSArray *moviesArray = @[
                      @{ @"imdbID": @"tt0848228", @"id": @24, @"year": @2008, @"name" : @"The Avengers", @"type" : @"serie" },
                      @{ @"imdbID": @"tt0114709", @"id": @39, @"year": @2008, @"name" : @"Toy Story", @"type" : @"serie" }
                      ];
    NSDictionary *productManagers = @{@"serie": fooArray, @"movie": moviesArray, @"book": fooArray};
//
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//    
//    } completion:nil];
        UserTaste *userTaste = [UserTaste  MR_createEntity];
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:productManagers];
        userTaste.taste = arrayData;
        userTaste.fbid = [NSNumber numberWithLong:1387984218159351];
    userTaste.lastMeeting = newDate; //[NSDate date];
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

//    
//    self.userTaste = [UserTaste MR_findFirstByAttribute:@"fbid"
//                                                 withValue:[NSNumber numberWithLong:1387984218159370]]; //1387984218159370
//    
//    userTasteDict = [NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]];
//    NSLog(@"userTasteDict : %@, %lu", userTasteDict , (unsigned long)userTasteDict.count);
    
//    NSMutableDictionary *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[people objectAtIndex:0] taste]];
    
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    
    [self.view addSubview:loadingIndicator];
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

- (void) appearsSearchBar
{
    self.searchController.searchBar.frame = CGRectMake(0, 10, self.searchController.searchBar.frame.size.width, self.searchController.searchBar.frame.size.height);

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


#pragma mark - Facebook user connection

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    self.FirstFBLoginDone = YES;
}


// This method have to be called when the user is connected
- (void) userConnectionForFbID:(NSNumber*)userfbID
{
    // We retrieve user taste if it exists in local
    self.userTaste = [UserTaste MR_findFirstByAttribute:@"fbid"
                                              withValue:userfbID];
    userTasteDict = [[NSMutableDictionary alloc] init];
    
    if (self.userTaste) {
        //
        // then put it into the NSDictionary of "taste"
        userTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] mutableCopy];
        [self displayUserTasteList];
        NSLog(@"fetch local datas");
    } else {
        [self getServerDatasForFbID:[userPreferences objectForKey:@"fbUserID"] isUpdate:NO];
        NSLog(@"fetch server datas");
    }
}

- (void) displayUserTasteList
{
    [self.view addSubview: self.searchController.searchBar];
    
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    userSelectionTableView.alpha = 0;
    userSelectionTableView.hidden = NO;
    [userSelectionTableView reloadData];
    
    UILabel *appnameView = (UILabel*)[self.view viewWithTag:2];
    
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
                         appnameView.hidden = YES;
                         appnameView.alpha = 0;
                         [loadingIndicator stopAnimating];
                     }];
}


- (void) userLoggedOutOffb
{
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    
    

    [userTasteDict removeAllObjects];
    
    UILabel *appnameView = (UILabel*)[self.view viewWithTag:2];
    appnameView.hidden = NO;
    
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

                         userSelectionTableView.hidden = YES;
                     }];
    
    // user logged out so we remove his key into the NSUserdefault
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fbUserID"];
    
    self.FirstFBLoginDone = YES;
}


- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    if(!self.isFirstFBLoginDone) {
        return;
    }
    
    FBLoginView *fbLoginButton = (FBLoginView*)[self.view viewWithTag:1];
    
    // We format the user id (NSString) to an NSNumber to be stored in NSUserDefault key
    NSNumberFormatter *fbIDFormatter = [[NSNumberFormatter alloc] init];
    [fbIDFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *fbIDNumber = [fbIDFormatter numberFromString:user.objectID];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:fbIDNumber forKey:@"fbUserID"];
    // This bool is here to manage some weirdo behaviour with SWRevealViewController (not sure)
    [userPreferences setBool:YES forKey:@"appHasBeenLaunched"];
    
    
    
    // We remove facebook's button into a thread for solve a curious issue
//    [fbLoginButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
//    NSLog(@"user %@ | %@:", user, user.objectID);
    
    // Here we add userid (aka user.objectID) to the database
    
    //        UserTaste *userTaste = [UserTaste  MR_createEntity];
    //        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:productManagers];
    //        userTaste.taste = arrayData;
    //        userTaste.fbid = [NSNumber numberWithLong:1387984218159370];
    //        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    [self userConnectionForFbID:fbIDNumber];
    
    self.FirstFBLoginDone = NO;
}


// When user logged out
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [self userLoggedOutOffb];
}

// Manage error for connection
- (void) loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

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
        UILabel *emptyResultLabel = (UILabel*)[self.searchResultsController.view viewWithTag:7];
        if ([[filteredTableDatas allKeys] count] == 0 && [self.searchController.searchBar.text length] != 0) {
            emptyResultLabel.hidden = NO;
            
            return 0;
        }
        emptyResultLabel.hidden = YES;
        
        return [categoryList count];
    } else {
        // User have no list of taste
        UILabel *emptyUserTasteLabel = (UILabel*)[self.view viewWithTag:8];
        if ([[userTasteDict allKeys] count] == 0 && FBSession.activeSession.isOpen) {
            emptyUserTasteLabel.hidden = NO;
            
            return 0;
        }
        emptyUserTasteLabel.hidden = YES;
        
        return userTasteDict.count;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [categoryList objectAtIndex:section];
    } else {
        return [[userTasteDict allKeys] objectAtIndex:section];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 52.0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
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
        }
        
        cell.model = [rowsOfSection objectAtIndex:indexPath.row];
        title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
        year = [NSString stringWithFormat:@"%@", [[rowsOfSection objectAtIndex:indexPath.row] valueForKey:@"year"]];
        cell.textLabel.text = title;
        cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];
        cell.textLabel.textColor = [UIColor whiteColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray *rowsOfSection = [userTasteDict objectForKey:sectionTitle];
        CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
        
        title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
        imdbID = [rowsOfSection objectAtIndex:indexPath.row][@"imdbID"];
        
        if (cell == nil) {
            cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.delegate = self;
        // For "Classic mode" we want a cell's background more opaque
        cell.backgroundColor = [UIColor colorWithRed:(246.0/255.0) green:(246.0/255.0) blue:(246.0/255.0) alpha:0.87];
        
        //            cell.rightUtilityButtons = [self rightButtonsForSearch];
        
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
            [self getImageCellForData:imdbID aCell:cell];
        }
        
        UIView *bgColorView = [UIView new];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.7f]];
        [cell setSelectedBackgroundView:bgColorView];

        cell.textLabel.text = title;
    }

    
    //            NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", sectionTitle];
    //            NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name == %@", title];
    
    
    //             NSLog(@"row :%ld, section : %ld, %@", (long)indexPath.row, (long)indexPath.section, [[[APIdatas filteredArrayUsingPredicate:typePredicate] filteredArrayUsingPredicate:namePredicate] valueForKey:@"year"]);

    
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = year;
//    }
    

    return cell;
}

- (void) getImageCellForData:(NSString*)imdbID aCell:(UITableViewCell*)cell
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
    

    cell.backgroundView = imgBackground; //[cell addSubview:imgBackground];
    
    __block NSString *imgDistURL; // URL of the image from imdb database api
    
    NSString *linkAPI = @"http://www.omdbapi.com/?i=";
    linkAPI = [linkAPI stringByAppendingString:imdbID];
    linkAPI = [linkAPI stringByAppendingString:@"&plot=short&r=json"];
    
    CALayer *imgLayer = [CALayer layer];
    imgLayer.frame = cellFrame;
    [imgLayer addSublayer:gradientLayer];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:linkAPI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        imgDistURL = responseObject[@"Poster"];
        
        [imgBackground setImageWithURL:
         [NSURL URLWithString:imgDistURL]
                      placeholderImage:[UIImage imageNamed:@"bb"]];
        [imgBackground.layer insertSublayer:gradientLayer atIndex:0];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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

- (NSArray *) rightButtonsForSearch
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
            
            NSIndexPath *cellIndexPath = [tableView indexPathForCell:cell];
            [[userTasteDict objectForKey:[cell.model valueForKey:@"type"]] removeObject:cell.model];
            
            NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", [userPreferences objectForKey:@"fbUserID"]];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                UserTaste *userTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:localContext];
                NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
                userTaste.taste = arrayData;
            } completion:^(BOOL success, NSError *error) {
                [tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                           withRowAnimation:UITableViewRowAnimationFade];
                [self getServerDatasForFbID:[userPreferences objectForKey:@"fbUserID"] isUpdate:YES];
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
    
    ShareListMediaTableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    DetailsMediaViewController *detailsMediaViewController = [[DetailsMediaViewController alloc] init];
    detailsMediaViewController.mediaDatas = selectedCell.model;
    detailsMediaViewController.delegate = self;
    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
    
    [self.searchController setActive:NO];
//    NSLog(@"cell : %@", [tableView indexPathForSelectedRow]);
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.alpha = .5f;
//
//    NSString *titleForHeader = [self tableView:tableView titleForHeaderInSection:indexPath.section];
//    
//    [[userTasteDict objectForKey:@"movie"] removeObject:cell.textLabel.text];
//    NSLog(@"%@", cell.textLabel.text);
////    NSLog(@"cell: %@, %@, %li, %@, %@", cell.textLabel.text, titleForHeader, (long)indexPath.row, [userTasteDict objectForKey:@"serie"], [userPreferences objectForKey:@"fbUserID"]);
////    NSLog(@"string : %@", [[userTasteDict objectForKey:@"serie"] isKindOfClass:[NSMutableArray class]]);
//    
//    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", [userPreferences objectForKey:@"fbUserID"]];
//
//
////    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
////        UserTaste *userTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:localContext];
////        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
////        userTaste.taste = arrayData;
////    } completion:^(BOOL success, NSError *error) {
//        [tableView reloadData];
////    }];
//
//
//    cell.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];

}

- (void) userListHaveBeenUpdate:(NSDictionary *)dict
{

    userTasteDict = [dict mutableCopy];
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    userSelectionTableView.hidden = NO;
    [userSelectionTableView reloadData];
}


// Title of categories
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 18.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 69.0)];
    headerView.opaque = YES;

    NSString *title = [[categoryList objectAtIndex:section] uppercaseString];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 69.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        headerView.backgroundColor = [UIColor colorWithWhite:.95 alpha:.80f];
        label.textColor = [UIColor blackColor];
    } else {
        headerView.backgroundColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:.9f];
        label.textColor = [UIColor whiteColor];
    }
    [headerView addSubview:label];
    
    return headerView;
}

#pragma mark - custom methods

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

// This method retrieve an readable json of user taste for the database
- (NSString *) updateTasteForServer
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userTasteDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
   
        return jsonString;
    }
}

// This methods allows to retrieve and send (?) user datas from the server
- (void) getServerDatasForFbID:(NSNumber*)userfbID isUpdate:(BOOL)isUpdate
{
    NSURL *aUrl= [NSURL URLWithString:@"http://192.168.1.55:8888/Share/connexion.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    // We send the json to the server only when we need it
    NSString *userTasteJSON;
    if (isUpdate == YES) {
        userTasteJSON = [self updateTasteForServer];
    } else {
        userTasteJSON = @"";
    }

    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@&userTaste=%@", userfbID, userTasteJSON];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    // Server sends back some datas
    if (self.responseData != nil) {
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
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
        } else {
            NSLog(@"no user datas");
        }
        
        UserTaste *isNewUser = [UserTaste MR_findFirstByAttribute:@"fbid"
                                                        withValue:[userPreferences objectForKey:@"fbUserID"]];
        self.responseData = nil;
        self.responseData = [NSMutableData new];
        
        // This is the first time for user
        if (isNewUser == nil) {
            UserTaste *userTaste = [UserTaste MR_createEntity];
            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
            userTaste.taste = arrayData;
            userTaste.fbid = [userPreferences objectForKey:@"fbUserID"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
        [self displayUserTasteList];
    }
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
}


#pragma mark - Content filtering

- (void) updateSearchResultsForSearchController:(UISearchController *) searchController
{
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, CGRectGetWidth(self.searchResultsController.tableView.frame), CGRectGetHeight(self.searchResultsController.tableView.frame));
    
    NSString *searchString = [searchController.searchBar text];
    
    NSMutableArray *filteredDatas = [[NSMutableArray alloc] init];
    [filteredTableDatas removeAllObjects];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", searchString];
    
    [filteredDatas setArray:[APIdatas filteredArrayUsingPredicate:searchPredicate]];

    for (int i = 0; i < [[filteredDatas valueForKey:@"type"] count]; i++) {
        
        // This predicate manage a media in several categories
        NSPredicate *nameForTypePredicate = [NSPredicate predicateWithFormat:@"type = %@", [[filteredDatas valueForKey:@"type"] objectAtIndex:i]];

        // For each category we add an alphabetical ordered NSArray of medias which match with the NSPredicate above
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *datasToSort = [[NSArray alloc] initWithArray:[[filteredDatas filteredArrayUsingPredicate:nameForTypePredicate] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
        NSArray *sortedDatas = [[NSArray alloc] initWithArray:[datasToSort copy]];
    
        [filteredTableDatas setValue:sortedDatas forKey:[[filteredDatas valueForKey:@"type"] objectAtIndex:i]];
    }
    
    [self.searchResultsController.tableView reloadData];
    
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

// When the user starts to scroll we hide the keyboard
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchController.searchBar resignFirstResponder];
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

# pragma mark - Delegate methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
