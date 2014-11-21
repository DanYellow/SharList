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



// Tag list
// 1 : Facebook button for connect
// 2 : appMottoText (UILabel)
// 3 : UISearchControllerBG | Background of the input
// 4 : userSelectionTableViewController | Tableview of user taste
// 5 : strokeUnderSearchController
// 6 : UIRefreshControl for userTaste


@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = [self.title uppercaseString];
    self.tabBarController.tabBarItem.title = [self.title lowercaseString];
    
    self.searchController.searchBar.hidden = NO;
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
    
//    CGPoint centerOfView = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    // Variables init
    USERALREADYMADEARESEARCH = NO;
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];

    // Contains raw data from the server
    self.responseData = [NSMutableData data];
    
    
//    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    
    
    // Design on the view
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(appearsSearchBar)];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradient.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    CALayer *bgLayer = [CALayer layer];
    bgLayer.frame = self.view.bounds;
    bgLayer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"triangles-bg.png"]].CGColor;
    [self.view.layer insertSublayer:bgLayer atIndex:1];
    
    // Motto of the app
    CGFloat appMottoYPos = [self computeRatio:260.0 forDimension:screenHeight];

    UILabel *appMottoText = [[UILabel alloc] initWithFrame:CGRectMake(0, appMottoYPos, screenWidth, 20)];
    appMottoText.text = @"Partagez ce que vous aimez avec l'inconnu";
    appMottoText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    appMottoText.textAlignment = NSTextAlignmentCenter;
    appMottoText.textColor = [UIColor blackColor];
    appMottoText.tag = 2;
    
    [self.view addSubview:appMottoText];
    
    // Facebook login
    FBLoginView *fbLoginButton = [FBLoginView new];
    fbLoginButton.delegate = self;
    fbLoginButton.tag = 1;
    fbLoginButton.frame = CGRectMake(51, screenHeight - 150, 218, 46);
//    fbLoginButton.frame = CGRectOffset(fbLoginButton.frame, (self.view.center.x - (fbLoginButton.frame.size.width / 2)), [self computeRatio:740.0 forDimension:screenHeight]);
    
    
    
    // UITableview of results
    self.searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchResultsController.tableView.dataSource = self;
    self.searchResultsController.tableView.delegate = self;
    self.searchResultsController.tableView.backgroundColor = [UIColor clearColor];
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, screenWidth, screenHeight);
    self.searchResultsController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.searchResultsController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchResultsController.tableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];

    
    
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
    
    // Uitableview of user selection (what user likes)
    UITableViewController *userSelectionTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    userSelectionTableViewController.tableView.frame = CGRectMake(0, 0, screenWidth, screenHeight); //[self computeRatio:800.0 forDimension:screenHeight] + 44
    userSelectionTableViewController.tableView.dataSource = self;
    userSelectionTableViewController.tableView.delegate = self;
    userSelectionTableViewController.tableView.backgroundColor = [UIColor clearColor];
    userSelectionTableViewController.tableView.tag = 4;
    userSelectionTableViewController.tableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
//    userSelectionTableViewController.refreshControl = userSelectRefresh;
    userSelectionTableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableViewController.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:userSelectionTableViewController.tableView];
    


    APIdatas = [[NSArray alloc] initWithArray:[self fetchDatas]];
//    NSLog(@"APIdatas : %@", APIdatas);
    categoryList = [[[self fetchDatas] valueForKeyPath:@"@distinctUnionOfObjects.type"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    filteredTableDatas = [[NSMutableDictionary alloc] init];
    
     [self.view addSubview:fbLoginButton];
    // Detect if user not is connected
    if (!FBSession.activeSession.isOpen) {
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
    
//    NSArray *fooArray = @[@"I am Charlotte Simmons",
//                           @"I am Charlotte Simmons",
//                           @"I am Charlotte Simmons",
//                           @"I am Charlotte Simmons",
//                          @"I am Charlotte Simmons"];
//    NSDictionary *productManagers = @{@"serie": fooArray, @"movie": fooArray, @"book": fooArray};
//    
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//    
//    } completion:nil];
//        UserTaste *userTaste = [UserTaste  MR_createEntity];
//        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:productManagers];
//        userTaste.taste = arrayData;
//        userTaste.fbid = [NSNumber numberWithLong:1387984218159370];
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

//    
//    self.userTaste = [UserTaste MR_findFirstByAttribute:@"fbid"
//                                                 withValue:[NSNumber numberWithLong:1387984218159370]]; //1387984218159370
//    
//    userTasteDict = [NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]];
//    NSLog(@"userTasteDict : %@, %lu", userTasteDict , (unsigned long)userTasteDict.count);
    
//    NSMutableDictionary *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[people objectAtIndex:0] taste]];
    

}

- (void) fetchUserDatas {
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
        
    } else {
        [self getServerDatasForFbID:[userPreferences objectForKey:@"fbUserID"]];
    }
    
    [self.view addSubview: self.searchController.searchBar];
    
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    userSelectionTableView.hidden = NO;
    [userSelectionTableView reloadData];
}


- (void) userLoggedOutOffb
{
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
    userSelectionTableView.hidden = YES;
    
    UIView *strokeUnderSearchController = (UIView*)[self.view viewWithTag:5];
    strokeUnderSearchController.hidden = YES;
    
    [self.searchController.searchBar removeFromSuperview];
    [userTasteDict removeAllObjects];
    
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

    UILabel *appMottoText = (UILabel*)[self.view viewWithTag:2];
    CGFloat endTransitionY = appMottoText.frame.origin.y;
    endTransitionY = endTransitionY - (endTransitionY/2);
    
    [UIView animateWithDuration:0.5 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         appMottoText.frame = CGRectMake(0, endTransitionY, appMottoText.frame.size.width, appMottoText.frame.size.height);
                         
                         [UIView animateWithDuration:0.4 delay:0.2
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              appMottoText.alpha = 0;
                                          }
                                          completion:^(BOOL finished){
//                                              NSLog(@"Done!");
                                          }];
                     }
                     completion:^(BOOL finished){
//                         NSLog(@"Done!");
                     }];
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
        NSString *sectionTitle = [ [[userTasteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
        NSArray *sectionElements = [userTasteDict objectForKey:sectionTitle];
        if ([sectionElements isKindOfClass:[NSNull class]]) {
            return 0;
        }
        return sectionElements.count;
    }
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [categoryList count];
    } else {
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
    
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil ) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        
        NSString *sectionTitle = [categoryList objectAtIndex:indexPath.section];
        NSString *title, *description, *year;
//        NSString *sectionTitle = [categoryList objectAtIndex:indexPath.section];
        if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
            NSArray *rowsOfSection = [filteredTableDatas objectForKey:sectionTitle];
            
            title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
            year = [NSString stringWithFormat:@"%@", [[rowsOfSection objectAtIndex:indexPath.row] valueForKey:@"year"]];
            
//            [cell setModel:[rowsOfSection objectAtIndex:indexPath.row]];
            
            cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.text = title;
//            cell.rightUtilityButtons = [self rightButtonsForUserFavs];
            
        } else {
            
            NSArray *rowsOfSection = [userTasteDict objectForKey:sectionTitle];
            
            // For "Classic mode" we want a cell's background more opaque
            
            cell.backgroundColor = [UIColor colorWithRed:(246.0/255.0) green:(246.0/255.0) blue:(246.0/255.0) alpha:0.87];
            
            title = [rowsOfSection objectAtIndex:indexPath.row];
            
            CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
            
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = cellFrame;
            [gradientLayer setStartPoint:CGPointMake(-0.05, 0.5)];
            [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
            gradientLayer.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]];
            
//            UIImageView *imgBackground = [[UIImageView alloc] initWithFrame:cellFrame];
//            imgBackground.image = [UIImage imageNamed:@"bb"];
//            imgBackground.contentMode = UIViewContentModeScaleAspectFill;
//            imgBackground.clipsToBounds = YES;
//            [imgBackground.layer insertSublayer:gradientLayer atIndex:0];
//            [cell addSubview:imgBackground];
            
            CALayer *imgLayer = [CALayer layer];
            imgLayer.contents = (id)[UIImage imageNamed:@"bb"].CGImage;
            imgLayer.masksToBounds = YES;
            imgLayer.contentsGravity = @"resizeAspectFill";
            imgLayer.frame = cellFrame;
            [imgLayer addSublayer:gradientLayer];
            [cell.layer insertSublayer:imgLayer atIndex:0];
           
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 18, tableView.frame.size.width, cell.frame.size.height)];
            label.font = [UIFont fontWithName:@"Helvetica-Neue" size:16.0f];
            label.text = title;
            label.layer.shadowColor = [UIColor blackColor].CGColor;
            label.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
            label.layer.shadowOpacity = .75f;
            label.textColor = [UIColor whiteColor];
            
            cell.rightUtilityButtons = [self rightButtonsForSearch];
            
            
            
            [cell addSubview:label];
            
            
//            NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", sectionTitle];
//            NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name == %@", title];
            
            
//             NSLog(@"row :%ld, section : %ld, %@", (long)indexPath.row, (long)indexPath.section, [[[APIdatas filteredArrayUsingPredicate:typePredicate] filteredArrayUsingPredicate:namePredicate] valueForKey:@"year"]);
        }
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell.detailTextLabel.text = year;
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.9f]];
    [cell setSelectedBackgroundView:bgColorView];

    return cell;
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

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL) swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    DetailsMediaViewController *detailsMediaViewController = [[DetailsMediaViewController alloc] init];
    
    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
    [self.searchController setActive:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.alpha = .5f;
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


// Title of categories
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CGFloat fontSize = 18.0f;
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height)];
    labelView.backgroundColor =[UIColor clearColor];
    labelView.opaque = YES;
    
    NSString *string = [[categoryList objectAtIndex:section] uppercaseString];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
            cell.backgroundColor = [UIColor colorWithWhite:.95 alpha:.80f];
            cell.indentationLevel = 20;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 18, tableView.frame.size.width, cell.frame.size.height)];
            label.font = [UIFont fontWithName:@"Avenir" size:fontSize];
            label.text = string;
            label.textColor = [UIColor blackColor];
            [labelView addSubview:label];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:.9f];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 18, tableView.frame.size.width, cell.frame.size.height)];
            label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
            label.text = string;
            label.textColor = [UIColor whiteColor];
            [labelView addSubview:label];
        }
        
        [cell addSubview:labelView];
    }
    
    return cell;
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


- (void) updateTasteToServer
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userTasteDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonString : %@", jsonString);
    }
}

- (void) getServerDatasForFbID:(NSNumber*)userfbID
{
    NSURL *aUrl= [NSURL URLWithString:@"http://192.168.1.55:8888/Share/connexion.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];

    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@", userfbID];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Getting your response string
    if (self.responseData != nil) {
        // This solved a weird issue with php
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        responseString = [responseString substringToIndex:[responseString length] - 1];
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        userTasteDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        
        UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:4];
        userSelectionTableView.hidden = NO;
        [userSelectionTableView reloadData];
 
        UserTaste *userTaste = [UserTaste MR_createEntity];
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
        userTaste.taste = arrayData;
        userTaste.fbid = [userPreferences objectForKey:@"fbUserID"];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        self.responseData = nil;
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
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
        NSArray *datasToSort = [[NSArray alloc] initWithArray:[[filteredDatas filteredArrayUsingPredicate:nameForTypePredicate] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
        NSArray *sortedDatas = [[NSArray alloc] initWithArray:[datasToSort copy]];
        
        [filteredTableDatas setValue:sortedDatas forKey:[[filteredDatas valueForKey:@"type"] objectAtIndex:i]];
    }
    
    [self.searchResultsController.tableView reloadData];
    
    // Blurred background
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage: [self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = .95f;
    [bluredImageView setFrame:self.searchResultsController.tableView.frame];
    bluredImageView.alpha = 15.50f;
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = bluredImageView.bounds;
    [bluredImageView addSubview:visualEffectView];
    
    self.searchResultsController.tableView.backgroundView = bluredImageView;
//    self.searchController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.05f];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchController.searchBar resignFirstResponder];
}

# pragma mark - Delegate methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
