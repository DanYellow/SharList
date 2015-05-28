//
//  DetailsMeetingViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 26/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "DetailsMeetingViewController.h"

@interface DetailsMeetingViewController ()

@property (nonatomic, copy) NSMutableDictionary *metUserTasteDict;

@end


// Tag list
// 1 : userSelectionTableView
// 2 : addMeetingToFavoriteBtnItem
// 3 : TutorialView
// 4 : metUserFBView
// 5 : metUserFBImgView
// 6 : refreshBtn
// 7 : UIRefreshControl
// 8 : statCount

@implementation DetailsMeetingViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];

    self.navigationController.navigationBar.translucent = NO;
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.name = @"bottomBorderLayer";
    bottomBorder.frame = CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 1.0f);
    
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    
    userMet = [UserTaste MR_findFirstByAttribute:@"fbid"
                                                  withValue:self.metUserId];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeStyle = kCFDateFormatterShortStyle; //self.meetingDatas[@"userModel"]
    
    
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[[userMet fbid] stringValue]]) {
        NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [[userMet fbid] stringValue]]];
        self.title = [[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
    } else {
        self.title = [formatter stringFromDate:[userMet lastMeeting]];
    }
    
    // We get the datas of current user to compare it to the current list
    UserTaste *currentUser = [UserTaste MR_findFirstByAttribute:@"fbid"
                                                      withValue:[userPreferences objectForKey:@"currentUserfbID"]];
    currentUserTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUser taste]] mutableCopy];
    
    self.metUserTasteDict = [NSMutableDictionary new];
    self.metUserTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[userMet taste]] mutableCopy];
   
//    self.metUserTasteDict = [[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"list-tab-icon"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"discover-tab-icon"];

    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    
    // View init
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
//    CGFloat verticalOffset = -4;
//    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];
    
    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
    gradientBGView.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradientBGView atIndex:0];
    
    
    
    UIBarButtonItem *addMeetingToFavoriteBtnItem;
    // This list is not among user's favorites
    if (![userMet isFavorite]) {
        addMeetingToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavorite:)];
    } else {
        addMeetingToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavorite:)];
    }
    addMeetingToFavoriteBtnItem.tag = 2;
    addMeetingToFavoriteBtnItem.enabled = YES;
    
    
    UIView *meetingInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 42)];
    meetingInfoView.backgroundColor = [UIColor redColor];

    
//    UILabel *text = [[UILabel alloc] initWithFrame:meetingInfoView.frame];
//    text.text = @"GENTOO";
//    text.bounds = CGRectInset(meetingInfoView.frame, 10.0f, 10.0f);
//    [meetingInfoView addSubview:text];
    
  
    UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.0, screenWidth, 25)];
    tableFooter.textColor = [UIColor whiteColor];
    tableFooter.textAlignment = NSTextAlignmentCenter;
    tableFooter.opaque = YES;
    tableFooter.font = [UIFont boldSystemFontOfSize:15];
    tableFooter.text = [NSString sentenceCapitalizedString:[NSString stringWithFormat:NSLocalizedString(@"met %@ times", nil), [userMet numberOfMeetings]]];
    
    UIButton *shareShoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareShoundBtn setFrame:CGRectMake(0, 60, screenWidth, 44)];
    [shareShoundBtn setTitle:NSLocalizedString(@"Talk about this discover", nil) forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor colorWithRed:(1/255) green:(76/255) blue:(119/255) alpha:1.0] forState:UIControlStateSelected];
    [shareShoundBtn addTarget:self action:@selector(shareFb) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    tableFooter.opaque = YES;
    tableFooter.backgroundColor = [UIColor clearColor];
    

    // If the user is a facebook friend so we display the button to take about this meeting on facebook
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[[userMet fbid] stringValue]]) {
        [tableFooterView addSubview:shareShoundBtn];
    }
    
    [tableFooterView addSubview:tableFooter];
    
    UIView *tableFooterViewLastView = [tableFooterView.subviews objectAtIndex:0];
    CGFloat tableFooterViewLastViewPos =  tableFooterViewLastView.frame.size.height + tableFooterViewLastView.frame.origin.y + 15.0f;
    
    CGRect tableFooterViewFrame = tableFooterView.frame;
    tableFooterViewFrame.size.height = tableFooterViewLastViewPos;
    
    tableFooterView.frame = tableFooterViewFrame;
    
    //___________________
    // Uitableview of user selection (what user likes) initWithStyle:UITableViewStylePlain
    UITableView *userSelectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
//    userSelectionTableView.frame = CGRectMake(0, 0, screenWidth, screenHeight + self.tabBarController.tabBar.frame.size.height);
    userSelectionTableView.dataSource = self;
    userSelectionTableView.delegate = self;
    userSelectionTableView.backgroundColor = [UIColor clearColor];
    userSelectionTableView.tag = 1;
    userSelectionTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    userSelectionTableView.tableFooterView = tableFooterView; //[[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:userSelectionTableView];
    
    if ([userSelectionTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [userSelectionTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    UIActivityIndicatorView *loadingIndicator = [UIActivityIndicatorView new];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tag = 7;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.view addSubview:loadingIndicator];
//    UIRefreshControl *userSelectRefresh = [UIRefreshControl new];
//    userSelectRefresh.backgroundColor = [UIColor colorWithRed:(5.0f/255.0f) green:(37.0f/255.0f) blue:(72.0f/255.0f) alpha:.9f];
//    userSelectRefresh.tintColor = [UIColor whiteColor];
//    userSelectRefresh.tag = 2;
//    [userSelectRefresh addTarget:self
//                          action:@selector(fetchUserDatas)
//                forControlEvents:UIControlEventValueChanged];
    
    // If the current user list is among user's favorites and the meeting have been made one hour ago
    // He can fetch his update to follow him
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    NSDateComponents *conversionInfo = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[self.meetingDatas lastMeeting] toDate:[NSDate date] options:0];
//    NSInteger hours = [conversionInfo hour];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    // Display the percent match between current user and the user met
    [self displayMatchRateList];
    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"anonModeEnabled"]) {
//
//    } else {
//        // If the current user is anonymous. He still show his facebook profile photo to his friends
//        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[[userMet fbid] stringValue]])
//            [self displayMetUserfbImgProfile];
//    }
    
    NSString *urlAPI = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user"];
    NSDictionary *apiParams = @{@"fbiduser" : [self.metUserId stringValue]};
    // NSDictionary *apiParams = @{@"fbiduser" : [[userMet fbid] stringValue], @"isspecificuser" : @"yes"};
    
    [manager GET:urlAPI
       parameters:apiParams
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if (!responseObject[@"error"]) {
                  [self displayMetUserfbImgProfileForDatas:responseObject[@"response"]];
              }
              // The user met accepts to be public (default behaviour)
              // Or met user is among current user facebook friends' list
//              if (![responseObject[@"isAnonymous"] boolValue] || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[[userMet fbid] stringValue]] ) {
//              NSLog(@"doo : %@", responseObject);
//
//              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
    
    
    NSMutableArray *rightBarButtonItemsArray = [NSMutableArray new];
    [rightBarButtonItemsArray addObject:addMeetingToFavoriteBtnItem];

    if ([userMet isFavorite]) {
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateCurrentUser)];
        
        [rightBarButtonItemsArray addObject:refreshBtn];
        
        if (![self connected]) {
            refreshBtn.enabled = NO;
        }
        
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"detailsMeetingFavTutorial"]) {
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"detailsMeetingFavTutorial"];
//            [self showTutorial];
//        }
    }
    
    self.navigationItem.rightBarButtonItems = rightBarButtonItemsArray;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"] containsObject:self.metUserId]) {
        [self updateCurrentUser];
    }
}

- (void) scrollToSectionWithNumber:(UIButton*)sender {
    
    NSInteger aSectionNumber = sender.tag;

    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:aSectionNumber];

    [userSelectionTableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
}

- (void) displayUserFollowersForNumber:(NSNumber*)numberOfFollowers
{
    float widthViews = 99.0f;
    UIView *metUserFBView = (UIView*)[self.view viewWithTag:4];
    
    UIButton *followersLabelContainerBtn = [[UIButton alloc] initWithFrame:CGRectMake(metUserFBView.frame.size.width - widthViews,
                                                                                      metUserFBView.frame.size.height - 75,
                                                                                      widthViews, 70)];
    
    UILabel *followersTitle = [[UILabel alloc] initWithFrame:CGRectMake(-12, -5, widthViews, 30)];
    followersTitle.textColor = [UIColor whiteColor];
    followersTitle.backgroundColor = [UIColor clearColor];
    followersTitle.text = [NSLocalizedString(@"followers", nil) uppercaseString];
    
    followersTitle.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0f];
    followersTitle.textAlignment = NSTextAlignmentRight;
    if (![followersTitle isDescendantOfView:followersLabelContainerBtn]) {
        [followersLabelContainerBtn addSubview:followersTitle];
    }
    
    UILabel *statCount = [[UILabel alloc] initWithFrame:CGRectMake(-22, followersLabelContainerBtn.frame.size.height - 34, widthViews + 10, 35.0)];
    statCount.textColor = [UIColor whiteColor];
    statCount.backgroundColor = [UIColor clearColor];
    statCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45.0f];
    statCount.text = [NSString stringWithFormat:@"%@", numberOfFollowers];
    statCount.tag = 8;
    statCount.backgroundColor = [UIColor clearColor];
    statCount.textAlignment = NSTextAlignmentRight;
    [followersLabelContainerBtn addSubview:statCount];
    if (![followersLabelContainerBtn isDescendantOfView:metUserFBView]) {
        [metUserFBView addSubview:followersLabelContainerBtn];
    }
    
    
    if ([numberOfFollowers integerValue] > 1) {
        followersTitle.text = [NSLocalizedString(@"followers", nil) uppercaseString];
    } else {
        followersTitle.text = [NSLocalizedString(@"follower", nil) uppercaseString];
    }
}

- (BOOL) connected
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void) displayMetUserfbImgProfileForDatas:(NSDictionary*)datas
{
    UIView *metUserFBView = (UIView*)[self.view viewWithTag:4];

    [self displayUserFollowersForNumber: datas[@"followersCount"]];
    
    if ([datas[@"isAnonymous"] boolValue] == YES) {
        return;
    }
    int intWidthScreen = screenWidth;
    int heightImg = ceilf(intWidthScreen / GOLDENRATIO);
    
    NSString *fbMetUserString = [self.metUserId stringValue];
    NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", fbMetUserString, intWidthScreen, heightImg];
    
    UIImageView *metUserFBImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, heightImg)];
    [metUserFBImgView setImageWithURL:[NSURL URLWithString:metUserFBImgURL] placeholderImage:[UIImage animatedImageNamed:@"list-tab-icon2" duration:.1f]];
    metUserFBImgView.contentMode = UIViewContentModeScaleAspectFit;
    metUserFBImgView.tag = 5;
    [metUserFBView insertSubview:metUserFBImgView atIndex:0];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = metUserFBImgView.frame;
    [gradientLayer setStartPoint:CGPointMake(-0.05, 0.5)];
    [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
    UIColor *topGradientView = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.80];
    UIColor *bottomGradientView = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.80];
    gradientLayer.colors = @[(id)[topGradientView CGColor], (id)[bottomGradientView CGColor]];
    [metUserFBImgView.layer insertSublayer:gradientLayer atIndex:0];
}

- (void) displayMatchRateList
{
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:1];
    
    UIView *metUserFBView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ceilf(screenWidth / GOLDENRATIO))];
    metUserFBView.backgroundColor = [UIColor clearColor];
    metUserFBView.tag = 4;

    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    UILabel *commonTasteCountPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 24.0, 150.0, 48.0)];
    commonTasteCountPercentLabel.textColor = [UIColor whiteColor];
    commonTasteCountPercentLabel.backgroundColor = [UIColor clearColor];
    commonTasteCountPercentLabel.text = [self calcUserMetPercentMatch];
    commonTasteCountPercentLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:52.0f];
//    commonTasteCountPercentLabel.layer.shadowColor = (__bridge CGColorRef)((id)[UIColor blackColor].CGColor);
//    commonTasteCountPercentLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
//    commonTasteCountPercentLabel.layer.shadowOpacity = .75f;
    
    [metUserFBView addSubview:commonTasteCountPercentLabel];
    
    
    
    CGRect tasteMetUserMessageLabelFrame = CGRectMake(16.0,
                                                      commonTasteCountPercentLabel.frame.size.height + commonTasteCountPercentLabel.frame.origin.y,
                                                      190.0f,
                                                      20.0);
    
    UILabel *tasteMetUserMessageLabel = [[UILabel alloc] initWithFrame:tasteMetUserMessageLabelFrame];
    tasteMetUserMessageLabel.textColor = [UIColor whiteColor];
    tasteMetUserMessageLabel.backgroundColor = [UIColor clearColor];
    tasteMetUserMessageLabel.text = NSLocalizedString(@"in common", nil);
    tasteMetUserMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
//    tasteMetUserMessageLabel.layer.shadowColor = (__bridge CGColorRef)((id)[UIColor blackColor].CGColor);
//    tasteMetUserMessageLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
//    tasteMetUserMessageLabel.layer.shadowOpacity = .75f;
    [metUserFBView addSubview:tasteMetUserMessageLabel];
    
    userSelectionTableView.tableHeaderView = metUserFBView;
    [self displayMetUserStats];
    [userSelectionTableView setContentOffset:CGPointMake(0, 0)]; //metUserFBView.bounds.size.height
}

/*
 * This method display the details about user met
 * number of movies and films
 *
 */

- (void) displayMetUserStats
{
    UIView *metUserFBView = (UIView*)[self.view viewWithTag:4];
    
    float widthViews = 99.0f;
    for (int i = 0; i < [[self.metUserTasteDict filterKeysForNullObj] count]; i++) {
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(widthViews, 0.0f, 1.0, 75.0f);
        rightBorder.backgroundColor = [UIColor whiteColor].CGColor;
        
        NSString *title = [NSLocalizedString([[[self.metUserTasteDict filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:i], nil) uppercaseString];
        
        
        CGRect statContainerFrame = CGRectMake(0 + (95 * i),
                                               metUserFBView.frame.size.height - 75,
                                               widthViews, 70);
        
        
        UIButton *statContainer = [[UIButton alloc] initWithFrame:statContainerFrame];
        statContainer.backgroundColor = [UIColor clearColor];
        statContainer.tag = i + 1; // We add one because the first section of a tableview is the header
        
        [statContainer addTarget:self action:@selector(scrollToSectionWithNumber:) forControlEvents:UIControlEventTouchUpInside];

        
        [metUserFBView addSubview:statContainer];
        if ( i != ([[self.metUserTasteDict filterKeysForNullObj] count] - 1)) {
            [statContainer.layer addSublayer:rightBorder];
        }
        
        UILabel *statTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, -5, widthViews, 30)];
        statTitle.textColor = [UIColor whiteColor];
        statTitle.backgroundColor = [UIColor clearColor];
        statTitle.text = title;
        statTitle.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0f];
//        statTitle.layer.shadowColor = [[UIColor blackColor] CGColor];
//        statTitle.layer.shadowOffset = CGSizeMake(0.0, 0.0);
//        statTitle.layer.shadowRadius = 2.5;
//        statTitle.layer.shadowOpacity = 0.75;
        [statContainer addSubview:statTitle];
        
        
        
        UILabel *statCount = [[UILabel alloc] initWithFrame:CGRectMake(12, statContainer.frame.size.height - 34, widthViews, 35.0)];
        statCount.textColor = [UIColor whiteColor];
        statCount.backgroundColor = [UIColor clearColor];
        statCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45.0f];
//        statCount.layer.shadowColor = [[UIColor blackColor] CGColor];
//        statCount.layer.shadowOffset = CGSizeMake(0.0, 0.0);
//        statCount.layer.shadowRadius = 2.5;
//        statCount.layer.shadowOpacity = 0.75;
        
        NSString *statCountNumber = [[NSNumber numberWithInteger:[[self.metUserTasteDict objectForKey:[[[self.metUserTasteDict filterKeysForNullObj]  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]objectAtIndex:i]] count]] stringValue];
        statCount.text = statCountNumber;
        [statContainer insertSubview:statCount atIndex:10];
    }
}

- (void) updateCurrentUser
{
    // Should contain raw data from the server
    self.responseData = [NSMutableData new];
    
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:7];
    [loadingIndicator startAnimating];
    
    UIBarButtonItem *refreshBtn = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
    refreshBtn.enabled = NO;

    [self getServerDatasForFbID:self.metUserId];
}

#pragma mark - server communication
// This methods allows to retrieve and send (?) user datas from the server
- (void) getServerDatasForFbID:(NSNumber*)userfbID
{
    NSURL *aUrl= [NSURL URLWithString:[[settingsDict valueForKey:@"apiPath"] stringByAppendingString:@"getusertaste.php"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@&isspecificuser=%@", userfbID, @"true"];
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
            NSDictionary *allDatasFromServerDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSData *stringData = [[allDatasFromServerDict objectForKey:@"user_favs"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *randomUserTaste = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
            
            
            // This user has really updated is data we udpdate locals datas
            if (![self.metUserTasteDict isEqualToDictionary: [randomUserTaste mutableCopy] ]) {
                // We update the current data from the server
                self.metUserTasteDict = [randomUserTaste mutableCopy];
                NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:randomUserTaste];
                
                NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", self.metUserId];
                UserTaste *oldUserTaste = [UserTaste MR_findFirstWithPredicate:userPredicate];
                oldUserTaste.taste = arrayData;
                [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
                
                [self displayMatchRateList];
                
                UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
                [tableView reloadData];
            } else {
                // We show the alert of "no update list" only if the current user does manually an update
                if (self.isDisplayedFromPush != YES) {
                    UIAlertView *noNewDatasAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No results", nil) message:NSLocalizedString(@"no datas updated for this user", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [noNewDatasAlert show];
                }
            }
        } else {
            UIAlertView *noNewDatasAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No results", nil) message:NSLocalizedString(@"no datas updated for this user", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNewDatasAlert show];
        }
        
        self.responseData = nil;
        self.responseData = [NSMutableData new];
        
        UIBarButtonItem *refreshBtn = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        refreshBtn.enabled = YES;
        
        UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:7];
        [loadingIndicator stopAnimating];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"] containsObject:self.metUserId]) {
            NSMutableArray *favsIDUpdatedList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"] mutableCopy];
            [favsIDUpdatedList removeObject:self.metUserId];
            [[NSUserDefaults standardUserDefaults] setObject:favsIDUpdatedList forKey:@"favsIDUpdatedList"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"seenFavUpdated" object:nil userInfo:nil];
        }
    }
}

- (NSString*) calcUserMetPercentMatch
{
    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
    int commonTasteCount = 0;
    int currentUserNumberItems = 0;

    for (int i = 0; i < [[self.metUserTasteDict filterKeysForNullObj] count]; i++) {
        NSString *key = [[self.metUserTasteDict filterKeysForNullObj] objectAtIndex:i];

        if (![[currentUserTaste objectForKey:key] isEqual:[NSNull null]]) {
            currentUserTasteSet = [NSMutableSet setWithArray:[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"]];
            
            currentUserNumberItems += [[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"] count];
        }
        
        if (![[self.metUserTasteDict objectForKey:key] isEqual:[NSNull null]]) {
            currentUserMetTasteSet = [NSMutableSet setWithArray:[[self.metUserTasteDict objectForKey:key] valueForKey:@"imdbID"]];
        }
        
        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the obejcts that are in both sets
        
        NSArray* result = [currentUserMetTasteSet allObjects];
        
        commonTasteCount += result.count;
    }
    
    CGFloat commonTasteCountPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
    
    if (isnan(commonTasteCountPercent) || isinf(commonTasteCountPercent)) {
        commonTasteCountPercent = 0.0f;
    }
    
    
    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *strNumber = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:commonTasteCountPercent]];
    
    return strNumber;
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
    
    
    CALayer *imgLayer = [CALayer layer];
    imgLayer.frame = cellFrame;
    [imgLayer addSublayer:gradientLayer];
    
    
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
            if ([model[@"type"] isEqualToString:@"serie"]) {
                imgURL = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
            } else {
                imgURL = responseObject[@"poster_path"];
            }
            
            imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w396%@", imgURL];
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


#pragma mark - tableview definition

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [[[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    NSArray *sectionElements = [self.metUserTasteDict objectForKey:sectionTitle];
    
//    NSLog(@"sectionElements : %@, %@, %@", sectionTitle, sectionElements, NSStringFromClass(sectionElements.class));
    // If the category is empty so the section not appears
    if ([sectionElements isKindOfClass:[NSNull class]]) {
        return 0;
    }

    return sectionElements.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    // User have no list of taste
    UILabel *emptyUserTasteLabel = (UILabel*)[self.view viewWithTag:8];
    BOOL IsTableViewEmpty = YES;
    // This loop is here to check the value of all keys
    for (int i = 0; i < [[self.metUserTasteDict allKeys] count]; i++) {
        if (![[self.metUserTasteDict objectForKey:[[self.metUserTasteDict allKeys] objectAtIndex:i]] isKindOfClass:[NSNull class]]) {
            if ([[self.metUserTasteDict objectForKey:[[self.metUserTasteDict allKeys] objectAtIndex:i]] count] != 0) {
                IsTableViewEmpty = NO;
            }
        }
    }
    
    if (IsTableViewEmpty == YES && FBSession.activeSession.isOpen) {
        emptyUserTasteLabel.hidden = NO;
        
        return 0;
    }
    emptyUserTasteLabel.hidden = YES;
//    NSLog(@"foo : %@", [self.metUserTasteDict filterKeysForNullObj]);
    return [self.metUserTasteDict count];
}

// Title of categories
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 16.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 69.0)];
    headerView.opaque = YES;
    
    NSString *sectionTitleRaw = [[[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    NSString *title = [NSLocalizedString(sectionTitleRaw, nil) uppercaseString];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 69.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    
    headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.9f];
    label.textColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1];
    
    [headerView addSubview:label];
    
    return headerView;
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
    
    // Keys from NSDict is sorted alphabetically
    NSString *sectionTitle = [[[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]
                                                                          objectAtIndex:indexPath.section];
    NSString *title, *imdbID; // year
    ShareListMediaTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *rowsOfSection = [self.metUserTasteDict objectForKey:sectionTitle];
    CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);

    title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
    imdbID = [rowsOfSection objectAtIndex:indexPath.row][@"imdbID"];
    
    if (cell == nil) {
        cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.frame = cellFrame;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        cell.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.textLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
        cell.textLabel.layer.shadowOpacity = .75f;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.indentationLevel = 1;
    }
    
    if (![currentUserTaste[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] isEqual:[NSNull null]]) {
        if ([[currentUserTaste[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] valueForKey:@"imdbID"] containsObject:[[rowsOfSection objectAtIndex:indexPath.row] objectForKey:@"imdbID"]]) {
            cell.imageView.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        } else {
            cell.imageView.image = nil;
        }
    }
    
    cell.alpha = .3f;

    cell.model = [rowsOfSection objectAtIndex:indexPath.row];
    
    if (imdbID != nil) {
        [self getImageCellForData:cell.model aCell:cell];
    }
    
    if ([[rowsOfSection objectAtIndex:indexPath.row][@"type"] isEqualToString:@"serie"]) {
        [self getLastNextReleaseSerieEpisodeForCell:cell];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.7f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    cell.textLabel.text = title;
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.detailTextLabel.text = @"year";
//    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    
    return cell;
}

- (void) getLastNextReleaseSerieEpisodeForCell:(ShareListMediaTableViewCell*)aCell
{

    NSDictionary *queryParams =  @{@"id": [aCell.model objectForKey:@"imdbID"], @"external_source": @"imdb_id"};
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbFind withParameters:queryParams andResponseBlock:^(id responseObject, NSError *error) {
        if(!error){
            
            NSDictionary *tvQueryParams = @{@"id": [responseObject valueForKeyPath: @"tv_results.id"][0]};
            
            [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbTV withParameters:tvQueryParams andResponseBlock:^(id responseObject, NSError *error) {
                if(!error){
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
                        [self displayLastNextReleaseSerieEpisodeForCell:aCell
                                                                   date:dateForEpisode
                                                    andSeasonForEpisode:[NSString stringWithFormat:@"S%02iE%02i", [tvSeasonQueryParams[@"season_number"] intValue], episodeNumber]];
                    }];
                }
            }];
            
        }
    }];
}


- (void) displayLastNextReleaseSerieEpisodeForCell:(ShareListMediaTableViewCell*)aCell date:(NSDate*)aDate andSeasonForEpisode:(NSString*)aEpisodeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSString *lastAirEpisodeDateString = [dateFormatter stringFromDate:aDate];
    
    aCell.detailTextLabel.text = ([aDate timeIntervalSinceNow] > 0) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil), lastAirEpisodeDateString] : @"";
    // If an episode of this serie is release today we notify the user
    aCell.detailTextLabel.text = ([[NSCalendar currentCalendar] isDateInToday:aDate]) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil), NSLocalizedString(@"release today", @"aujourd'hui !")] : aCell.detailTextLabel.text;
    // If an episode of this serie is release tomorrow we notify the user
    aCell.detailTextLabel.text = ([[NSCalendar currentCalendar] isDateInTomorrow:aDate]) ? [NSString stringWithFormat:NSLocalizedString(@"next episode %@", nil),  NSLocalizedString(@"release tomorrow", @"demain !")] : aCell.detailTextLabel.text;
    
    if ([aDate timeIntervalSinceNow] > 0 || [[NSCalendar currentCalendar] isDateInToday:aDate] || [[NSCalendar currentCalendar] isDateInTomorrow:aDate]) {
        aCell.detailTextLabel.text = [aCell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" • %@", aEpisodeString]];
    }
    
    
    aCell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    aCell.detailTextLabel.textColor = [UIColor whiteColor];
    aCell.detailTextLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    aCell.detailTextLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
    aCell.detailTextLabel.layer.shadowOpacity = .85f;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    //    NSString *titleForHeader = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    
    ShareListMediaTableViewCell *selectedCell = (ShareListMediaTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    DetailsMediaViewController *detailsMediaViewController = [[DetailsMediaViewController alloc] init];
    detailsMediaViewController.mediaDatas = selectedCell.model;
    detailsMediaViewController.userDiscoverId = self.metUserId;
    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
}


- (void) addAsFavorite:(UIBarButtonItem*)sender
{
    NSString *currentUserPFChannelName = @"sh_channel_";
    currentUserPFChannelName = [currentUserPFChannelName stringByAppendingString:[self.metUserId stringValue]];


    NSMutableArray *rightBarButtonItemsArray = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    
    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    // Current list seen is added to user favs discovers
    if ([sender.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
        sender.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        [userMet setIsFavorite:YES];
        
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateCurrentUser)];
        
        if (![self connected]) {
            refreshBtn.enabled = NO;
        }
        
        [rightBarButtonItemsArray addObject:refreshBtn];
        
        [self updateFollowingStatusWithUserForState:Follow];
        
        // If the user add this discover among his favorites.
        // He listen to his channel on Parse
//        if (![[currentInstallation objectForKey:@"channels"] containsObject:currentUserPFChannelName]) {
//            [PFPush subscribeToChannelInBackground:currentUserPFChannelName];
//        }
    } else {
        sender.image = [UIImage imageNamed:@"meetingFavoriteUnselected"];
        [userMet setIsFavorite:NO];
        
        
        UIBarButtonItem *refreshBtn = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        [rightBarButtonItemsArray removeObject:refreshBtn];
        
        [self updateFollowingStatusWithUserForState:Unfollow];
        // If the user withdraw this discover among his favorites.
        // He doesn't listen to his channel on Parse anymore
//        if ([[currentInstallation objectForKey:@"channels"] containsObject:currentUserPFChannelName]) {
//            [PFPush unsubscribeFromChannelInBackground:currentUserPFChannelName];
//        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    if ([self.delegate respondsToSelector:@selector(meetingsListHaveBeenUpdate)]) {
        [self.delegate meetingsListHaveBeenUpdate];
    }
    
    // We update the rightBarButtonItems
    self.navigationItem.rightBarButtonItems = rightBarButtonItemsArray;
}

- (void) updateFollowingStatusWithUserForState:(FollowingStatus)aStatus
{
    UILabel *statCount = (UILabel*)[self.view viewWithTag:8];
    
    AFHTTPRequestOperationManager *HTTPManager = [AFHTTPRequestOperationManager manager];
    [HTTPManager.requestSerializer setValue:@"install" forHTTPHeaderField:@"X-Shound"];
    NSDictionary *params = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"],
                             @"fbiduserfollowing": self.metUserId};
    
     NSString *urlLinkString = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user/follow"];
    
    if (aStatus == Unfollow) {
        [HTTPManager DELETE:urlLinkString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            statCount.text = [[NSNumber numberWithInt:([statCount.text intValue]-1)] stringValue];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else {
        [HTTPManager POST:urlLinkString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            statCount.text = [[NSNumber numberWithInt:([statCount.text intValue]+1)] stringValue];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

#pragma mark - tutorial's methods
- (void) showTutorial
{
    UIView *tutorialView = [[UIView alloc] initWithFrame:self.view.bounds];
    tutorialView.backgroundColor = [UIColor colorWithRed:(18.0/255.0f) green:(33.0f/255.0f) blue:(49.0f/255.0f) alpha:.989f];
    tutorialView.tag = 3;
    tutorialView.alpha = 1;
    tutorialView.opaque = NO;
    [[[UIApplication sharedApplication] keyWindow] addSubview:tutorialView];
    
    // TUTORIAL VIEW
    UITextView *tutFavsMessageTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 26, 90)];
    tutFavsMessageTV.text = NSLocalizedString(@"pull to refresh fav", nil);
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

- (void) hideTutorial
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *tutorialView = (UIView*)[[[UIApplication sharedApplication] keyWindow] viewWithTag:3];
    [UIView animateWithDuration:0.25 delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tutorialView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [tutorialView removeFromSuperview];
                     }];
}

#pragma mark - facebook

- (void) shareFb
{
    FBLinkShareParams *params = [FBLinkShareParams new];
    params.link = [NSURL URLWithString:@"https://appsto.re/us/sYAB4.i"];
    params.name = NSLocalizedString(@"FBLinkShareParams_metfriend_name", nil);
    params.caption = [NSString stringWithFormat:NSLocalizedString(@"FBLinkShareParams_metfriend_desc %@", nil), self.navigationController.title];
    params.picture = [NSURL URLWithString:@"http://www.shound.fr/shound_logo_fb.jpg"];
    
    // [NSString stringWithFormat:NSLocalizedString(@"FBLinkShareParams_metfriend_desc %@", nil), self.title]
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:nil
                                  description:NSLocalizedString(@"FBLinkShareParams_metfriend_desc_alt", nil)
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                                                          message:NSLocalizedString(@"FBLinkShareParams_posterror", nil)
                                                                         delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
                                          } else if (![results[@"completionGesture"] isEqualToString:@"cancel"]) {
                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FBLinkShareParams_postsuccess_title", nil)
                                                                          message:NSLocalizedString(@"FBLinkShareParams_postsuccess", nil)
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
                                          }
                                      }];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                    message:NSLocalizedString(@"FBLinkShareParams_noapp", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
    }
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
