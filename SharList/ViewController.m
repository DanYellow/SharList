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


@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGPoint centerOfView = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    imgView.image = [UIImage imageNamed:@"appBG"];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:imgView];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"appBG"]]];
    
    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
    
    UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                             target:self action:nil];
    btnEdit.enabled = YES;
    
    UIBarButtonItem *btnTrash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                              target:self action:nil];
    btnTrash.enabled = NO;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:btnEdit, btnTrash, nil];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    

    
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
    FBLoginView *fbLoginButton = [[FBLoginView alloc] init];
    fbLoginButton.delegate = self;
    fbLoginButton.tag = 1;
    fbLoginButton.frame = CGRectOffset(fbLoginButton.frame, (self.view.center.x - (fbLoginButton.frame.size.width / 2)), [self computeRatio:740.0 forDimension:screenHeight]);
    [self.view addSubview:fbLoginButton];
    
    
    // UITableview of results
    self.searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchResultsController.tableView.dataSource = self;
    self.searchResultsController.tableView.delegate = self;
    self.searchResultsController.tableView.backgroundColor = [UIColor colorWithRed:(127.0f/255.0f) green:(151.0f/255.0f) blue:(163.0f/255.0f) alpha:1.0f];
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, screenWidth, screenHeight);
    self.searchResultsController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.searchResultsController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchResultsController.tableView.separatorColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.1f];
    
    
    // Definition of uisearchcontroller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.placeholder = @"Ex. Breaking Bad";
    self.searchController.searchBar.frame = CGRectMake(0, 0.0, self.searchController.searchBar.frame.size.width, self.searchController.searchBar.frame.size.height);
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor redColor]];
    
    UIView *UISearchControllerBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
    UISearchControllerBG.tag = 3;
    UISearchControllerBG.backgroundColor = [UIColor colorWithRed:(230.0f/255.0f) green:(230.0f/255.0f) blue:(230.0f/255.0f) alpha:1.0f];
//    UISearchControllerBG.backgroundColor = [UIColor whiteColor];
    
    [self.searchController.view addSubview:UISearchControllerBG];
    
    CGFloat strokeUnderSearchControllerY = CGRectGetHeight(self.searchController.searchBar.frame) + CGRectGetMaxY(self.searchController.searchBar.frame) + 5 - 44.0;
    UIView *strokeUnderSearchController = [[UIView alloc] initWithFrame:CGRectMake(0, strokeUnderSearchControllerY, [self computeRatio:608.0 forDimension:screenWidth], 1.0)];
    strokeUnderSearchController.center = CGPointMake(self.view.center.x, strokeUnderSearchControllerY);
    strokeUnderSearchController.backgroundColor = [UIColor blackColor];
    strokeUnderSearchController.opaque = YES;
    strokeUnderSearchController.userInteractionEnabled = NO;
    [self.view addSubview:strokeUnderSearchController];
    
   
    // Uitableview of user selection (what user likes)
    UITableViewController *userSelectionTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    userSelectionTableViewController.tableView.frame = CGRectMake(0, strokeUnderSearchControllerY + 12, screenWidth, [self computeRatio:704.0 forDimension:screenHeight] + self.tabBarController.tabBar.frame.size.height + 44);
    userSelectionTableViewController.tableView.dataSource = self;
    userSelectionTableViewController.tableView.delegate = self;
    userSelectionTableViewController.tableView.backgroundColor = [UIColor brownColor];
    userSelectionTableViewController.tableView.separatorColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
    [self.view addSubview:userSelectionTableViewController.tableView];
    
    DetailsMediaViewController *modalVC = [[DetailsMediaViewController alloc] init];
//    modalVC.delegate = self;
    [self.navigationController pushViewController:modalVC animated:YES];


    APIdatas = [[NSArray alloc] initWithArray:[self fetchDatas]];
    
    categoryList = [[[self fetchDatas] valueForKeyPath:@"@distinctUnionOfObjects.type"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    filteredTableDatas = [[NSMutableDictionary alloc] init];
    
    // Detect if user is connected
    if (/* DISABLES CODE */ (YES)) { //FBSession.activeSession.isOpen
        [self.tabBarController.tabBar setHidden:NO];
        [self.view addSubview: self.searchController.searchBar];
    } else {
        [self.tabBarController.tabBar setHidden:YES];
    }
    
    for (UIView *subView in self.searchController.searchBar.subviews) {
        for(id field in subView.subviews){
            if ([field isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)field;
                [textField setBackgroundColor:[UIColor blueColor]];
            }
        }
    }
    
    NSArray *fooArray = @[@"I am Charlotte Simmons",
                           @"I am Charlotte Simmons",
                           @"I am Charlotte Simmons",
                           @"I am Charlotte Simmons",
                          @"I am Charlotte Simmons"];
    NSDictionary *productManagers = @{@"iPhone": fooArray, @"iPad": fooArray, @"Mobile Web": fooArray};
    
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//        UserTaste *userTaste = [UserTaste MR_createInContext:localContext];
//        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:productManagers];
//        userTaste.taste = arrayData;
////        userTaste.fbid = 
//    } completion:nil];
}


- (NSArray*) fetchDatas {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    return json;
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [self.searchController.searchBar becomeFirstResponder];
//}


#pragma mark - Facebook user connection

- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    FBLoginView *fbLoginButton = (FBLoginView*)[self.view viewWithTag:1];
//    [fbLoginButton performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    NSLog(@"user %@ | %@:", user, user.objectID);
    
    // Here we add userid (aka user.objectID) to the database
    
    [self.tabBarController.tabBar setHidden:NO];
    
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
}


// When user logged out
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"User logged out");
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
        NSArray *sectionCategories = [filteredTableDatas objectForKey:sectionTitle];
        
        return sectionCategories.count;
    } else {
        return 30;
    }
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [categoryList count];
    } else {
        return 1;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [categoryList objectAtIndex:section];
    } else {
        
        return nil;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0 || tableView != ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return 0;
    } else {
        return 42.0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ShareListMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSString *sectionTitle = [categoryList objectAtIndex:indexPath.section];
        NSArray *rowsOfSection = [filteredTableDatas objectForKey:sectionTitle];
        NSString *title = [rowsOfSection objectAtIndex:indexPath.row];
        
        cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.text = title;
    }
    
    return cell;
}


// Title of categories
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:(127.0f/255.0f) green:(151.0f/255.0f) blue:(163.0f/255.0f) alpha:.85f];
        cell.textLabel.text = [[categoryList objectAtIndex:section] uppercaseString];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    
    return cell;
}

#pragma mark - custom methods

- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension {
    CGFloat ratio = 0;
    ratio = ((aNumber*100)/aDimension);
    ratio = ((ratio*aDimension)/100);
    
    if ([UIScreen mainScreen].scale > 2.1) {
        
        ratio = ratio/3; // Because we are in retina HD
        
    } else {
        ratio = ratio/2; // Because we are in retina
    }
    
    return roundf(ratio);
}


#pragma mark - Content filtering

- (void) updateSearchResultsForSearchController:(UISearchController *) searchController {
    self.searchResultsController.tableView.frame = CGRectMake(0, 0.0, CGRectGetWidth(self.searchResultsController.tableView.frame), CGRectGetHeight(self.searchResultsController.tableView.frame) - (self.tabBarController.tabBar.frame.size.height / 2));
//    self.searchResultsController.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0);
    NSString *searchString = [searchController.searchBar text];
    
    NSMutableArray *filteredDatas = [[NSMutableArray alloc] init];
    [filteredTableDatas removeAllObjects];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", searchString];
    
    [filteredDatas setArray:[APIdatas filteredArrayUsingPredicate:searchPredicate]];
    
    for (int i = 0; i < [[filteredDatas valueForKey:@"type"] count]; i++) {
        
        // This predicate manage a media in several categories
        NSPredicate *nameForTypePredicate = [NSPredicate predicateWithFormat:@"type = %@", [[filteredDatas valueForKey:@"type"] objectAtIndex:i]];
        
        [filteredTableDatas setValue: [[filteredDatas filteredArrayUsingPredicate:nameForTypePredicate] valueForKey:@"name"] forKey: [[filteredDatas valueForKey:@"type"] objectAtIndex:i ]];
    }
    NSLog(@"%@", filteredTableDatas);
    [self.searchResultsController.tableView reloadData];
    
    // Blurred background
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage: [self takeSnapshotOfView:self.view]];
    [bluredImageView setFrame:self.searchResultsController.tableView.frame];
    bluredImageView.alpha = .50f;
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = bluredImageView.bounds;
    [bluredImageView addSubview:visualEffectView];
    
    self.searchResultsController.tableView.backgroundView = bluredImageView;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchController.searchBar resignFirstResponder];
}

- (UIImage *) takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
