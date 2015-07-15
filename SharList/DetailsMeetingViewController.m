//
//  DetailsMeetingViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 26/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "DetailsMeetingViewController.h"

@interface DetailsMeetingViewController ()


// We have to create two NSArray one to keep a reference of likes and a another one
@property (nonatomic, copy) NSMutableDictionary *metUserLikesDictRef;
@property (nonatomic, strong) NSMutableDictionary *metUserLikesDict;

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
// 9 : filterUserMetListSC
// 10 : emptyUserLikeLabel

@implementation DetailsMeetingViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
//        
//    }
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
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // We create an offset to manage uisplitview
    NSUInteger offsetWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? self.splitViewController.primaryColumnWidth : 0;
    // We create an offset on height to manage the presence of uitabbar on tablet
    NSUInteger offsetHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 49 : 0;

    screenWidth = screenRect.size.width - offsetWidth;
    screenHeight = screenRect.size.height - offsetHeight;
    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    // View init
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];

    
    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
    gradientBGView.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradientBGView atIndex:0];
    


    
    if (self.metUserId == nil) {
        NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbId != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
        Discovery *lastDiscovery = [Discovery MR_findFirstWithPredicate:meetingsFilter
                                                      sortedBy:@"lastDiscovery" ascending:NO];

        // By default we load the last discovery made
        if (lastDiscovery != nil) {
            self.metUserId = lastDiscovery.fbId;
        } else {
            return;
        }
    }
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    
    
    
    
    
//    if ([self isModal]) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];
//    }
    
    // User discovered is a facebook friend not discovered yet
    if ([Discovery MR_findFirstByAttribute:@"fbId"
                                 withValue:self.metUserId] == nil) {
        self.userDiscovered = [Discovery MR_createEntityInContext:[NSManagedObjectContext MR_context]];
        self.userDiscovered.fbId = [[self getFacebookFriendForFbId:self.metUserId] fbId];
        self.userDiscovered.likes = [[self getFacebookFriendForFbId:self.metUserId] likes];
        self.userDiscovered.numberOfDiscoveries = [[self getFacebookFriendForFbId:self.metUserId] numberOfDiscoveries];
    } else {
        self.userDiscovered = [Discovery MR_findFirstByAttribute:@"fbId"
                                           withValue:self.metUserId];
    }   
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeStyle = kCFDateFormatterShortStyle; //self.meetingDatas[@"userModel"]
    
    
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[self.userDiscovered fbId]]) {
        
        NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [self.userDiscovered fbId]]];
        self.title = [[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
    } else {
        self.title = [formatter stringFromDate:[self.userDiscovered lastDiscovery]];
    }

    // We get the datas of current user to compare it to the current list
    Discovery *currentUser = [Discovery MR_findFirstByAttribute:@"fbId"
                                                      withValue:[userPreferences objectForKey:@"currentUserfbID"]];
    // Xcode cannot throw a NSLog if [currentUser likes] is nil
    if ([currentUser likes]) {
        currentUserTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUser likes]] mutableCopy];
    }
    
    self.metUserLikesDictRef = [NSMutableDictionary new];
    self.metUserLikesDictRef = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
    
    self.metUserLikesDict = [NSMutableDictionary new];
    self.metUserLikesDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
   
//    self.metUserTasteDict = [[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"list-tab-icon"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"discover-tab-icon"];

    

    

    UIBarButtonItem *addMeetingToFavoriteBtnItem;
    // This discovery is not among user's favorites
    if (![self.userDiscovered isFavorite]) {
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
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
  
    UILabel *nbDiscoveriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.0, screenWidth, 25)];
    nbDiscoveriesLabel.textColor = [UIColor whiteColor];
    nbDiscoveriesLabel.textAlignment = NSTextAlignmentCenter;
    nbDiscoveriesLabel.opaque = YES;
    nbDiscoveriesLabel.backgroundColor = [UIColor clearColor];
    nbDiscoveriesLabel.font = [UIFont boldSystemFontOfSize:15];
    nbDiscoveriesLabel.text = [NSString sentenceCapitalizedString:[NSString stringWithFormat:NSLocalizedString(@"met %@ times", nil), [self.userDiscovered numberOfDiscoveries]]];
    [tableFooterView addSubview:nbDiscoveriesLabel];
    
    UIView *tableFooterLastView = [[tableFooterView subviews] lastObject];
    
    UIButton *showToDiscoverTabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showToDiscoverTabBtn.frame = CGRectMake(0, CGRectGetMaxY(tableFooterLastView.frame) + 12, screenWidth, 30);
    
    [showToDiscoverTabBtn setTitle:NSLocalizedString(@"not in common but much discover", nil)
                       forState:UIControlStateNormal];
    [showToDiscoverTabBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showToDiscoverTabBtn setTitleColor:[UIColor colorWithWhite:1 alpha:.6] forState:UIControlStateHighlighted];
    
    showToDiscoverTabBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [showToDiscoverTabBtn sizeToFit];
    showToDiscoverTabBtn.tag = 10;
    [showToDiscoverTabBtn addTarget:self action:@selector(displayDiscoverTabTV:) forControlEvents:UIControlEventTouchUpInside];
//    showToDiscoverTabBtn.frame = CGRectMake(CGRectGetMinX(showToDiscoverTabBtn.frame), CGRectGetMinY(showToDiscoverTabBtn.frame), screenWidth, CGRectGetHeight(showToDiscoverTabBtn.frame));
    showToDiscoverTabBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    showToDiscoverTabBtn.center = CGPointMake(screenWidth / 2, showToDiscoverTabBtn.center.y);
    showToDiscoverTabBtn.backgroundColor = [UIColor clearColor];
    [tableFooterView addSubview:showToDiscoverTabBtn];
    
    
    tableFooterLastView = [[tableFooterView subviews] lastObject];
    
    UIButton *shareShoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareShoundBtn setFrame:CGRectMake(0, CGRectGetMaxY(tableFooterLastView.frame) + 12, screenWidth - 24, 54)];
    [shareShoundBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]] forState:UIControlStateHighlighted];
    [shareShoundBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.1 alpha:.5]] forState:UIControlStateDisabled];
    [shareShoundBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    shareShoundBtn.backgroundColor = [UIColor clearColor];
    shareShoundBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    shareShoundBtn.layer.borderWidth = 2.0f;
    shareShoundBtn.center = CGPointMake(self.view.center.x, shareShoundBtn.center.y);
    [shareShoundBtn setTitle:NSLocalizedString(@"Talk about this discover", nil) forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor colorWithRed:(1/255) green:(76/255) blue:(119/255) alpha:1.0] forState:UIControlStateSelected];
    [shareShoundBtn addTarget:self action:@selector(shareFb) forControlEvents:UIControlEventTouchUpInside];
    

    // If the user is a facebook friend so we display the button to take about this meeting on facebook
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[self.userDiscovered fbId]]) {
        [tableFooterView addSubview:shareShoundBtn];
    }
    
    tableFooterLastView = [[tableFooterView subviews] lastObject];
    tableFooterView.frame = CGRectMake(0, 0, screenWidth, CGRectGetMaxY(tableFooterLastView.frame) + 30);
    tableFooterView.backgroundColor = [UIColor clearColor];
    
    //___________________
    // Uitableview of user selection (what user likes) initWithStyle:UITableViewStylePlain
    UITableView *userMetLikesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
//    userSelectionTableView.frame = CGRectMake(0, 0, screenWidth, screenHeight + self.tabBarController.tabBar.frame.size.height);
    userMetLikesTableView.dataSource = self;
    userMetLikesTableView.delegate = self;
    userMetLikesTableView.backgroundColor = [UIColor clearColor];
    userMetLikesTableView.tag = 1;
    userMetLikesTableView.alpha = 0;
    userMetLikesTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    userMetLikesTableView.tableFooterView = tableFooterView; //[[UIView alloc] initWithFrame:CGRectZero];
    userMetLikesTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    userMetLikesTableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:userMetLikesTableView];

    if ([userMetLikesTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [userMetLikesTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    
    UIActivityIndicatorView *loadingIndicator = [UIActivityIndicatorView new];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tag = 7;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.view addSubview:loadingIndicator];


    
    
    // Display the percent match between current user and the user met
    [self displayMatchRateList];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
    
    NSString *urlAPI = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user"];
    NSDictionary *apiParams = @{@"fbiduser" : self.metUserId};
    
    [manager GET:urlAPI
      parameters:apiParams
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if (!responseObject[@"error"]) {
                 // gentoo
                 [self displayMetUserfbImgProfileForDatas:responseObject[@"response"]];
             }

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];


    NSMutableArray *rightBarButtonItemsArray = [NSMutableArray new];
    [rightBarButtonItemsArray addObject:addMeetingToFavoriteBtnItem];

    if ([self.userDiscovered isFavorite]) {
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
    
    if ([self isModal]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];
        
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barBtn, NSUInteger index, BOOL *stop){
            barBtn.enabled = NO;
        }];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"] containsObject:self.metUserId]) {
        [self updateCurrentUser];
    }
}

- (void) scrollToSectionWithNumber:(UIButton*)sender {
    
    NSInteger aSectionNumber = sender.tag;

    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:1];
    
    // If the category selected (movie, serie, what ever) doesn't exist nothing happen
    if ([self.metUserLikesDict[[[self.metUserLikesDict filterKeysForNullObj] objectAtIndex:aSectionNumber]] count] == 0) {
        return;
    }
    
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
                                                                                      metUserFBView.frame.size.height - (75 + 45),
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
    
    UILabel *numberFollowersLabel = [[UILabel alloc] initWithFrame:CGRectMake(-22, followersLabelContainerBtn.frame.size.height - 34, widthViews + 10, 35.0)];
    numberFollowersLabel.textColor = [UIColor whiteColor];
    numberFollowersLabel.backgroundColor = [UIColor redColor];
    numberFollowersLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45.0f];
    numberFollowersLabel.text = [NSString stringWithFormat:@"%@", numberOfFollowers];
    numberFollowersLabel.tag = 8;
    numberFollowersLabel.backgroundColor = [UIColor clearColor];
    numberFollowersLabel.textAlignment = NSTextAlignmentRight;
    
    [followersLabelContainerBtn addSubview:numberFollowersLabel];
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
    
    
    // We don't display user picture for the following cases :
    // - Current user is anonymous AND user met is not his friend on facebook
    // - Current user is not anonymous, user met is anonymous AND not his friend on facebook
    if (([datas[@"isAnonymous"] boolValue] == YES && ![[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[self.userDiscovered fbId]]) ||
        ([[NSUserDefaults standardUserDefaults] boolForKey:@"anonModeEnabled"] && ![[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[self.userDiscovered fbId]])
    ) {
        return;
    }
    
    NSUInteger intWidthScreen = screenWidth;
    NSUInteger heightImg = ceilf(intWidthScreen / GOLDENRATIO) + 50;
    
    NSString *fbMetUserString = self.metUserId;
    NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%li&height=%li", fbMetUserString,(unsigned long)intWidthScreen, (unsigned long)heightImg];
    
    UIImageView *metUserFBImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, heightImg)];
    [metUserFBImgView setImageWithURL:[NSURL URLWithString:metUserFBImgURL] placeholderImage:nil];
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
    UITableView *userMetLikesTableView = (UITableView*)[self.view viewWithTag:1];
    
    UIView *metUserFBView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ceilf(screenWidth / GOLDENRATIO) + 50)];
    metUserFBView.backgroundColor = [UIColor clearColor];
    metUserFBView.tag = 4;

    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    UILabel *commonTasteCountPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 10.0, 155.0, 48.0)];
    commonTasteCountPercentLabel.textColor = [UIColor whiteColor];
    commonTasteCountPercentLabel.backgroundColor = [UIColor clearColor];
    commonTasteCountPercentLabel.text = [self calcUserMetPercentMatch];
    commonTasteCountPercentLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:52.0f];

    [metUserFBView addSubview:commonTasteCountPercentLabel];

    
    CGRect tasteMetUserMessageLabelFrame = CGRectMake(CGRectGetMinX(commonTasteCountPercentLabel.frame),
                                                      CGRectGetMaxY(commonTasteCountPercentLabel.frame),
                                                      190.0f,
                                                      20.0);
    
    UILabel *tasteMetUserMessageLabel = [[UILabel alloc] initWithFrame:tasteMetUserMessageLabelFrame];
    tasteMetUserMessageLabel.textColor = [UIColor whiteColor];
    tasteMetUserMessageLabel.backgroundColor = [UIColor clearColor];
    tasteMetUserMessageLabel.text = NSLocalizedString(@"not in common", nil);
    tasteMetUserMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];

    [metUserFBView addSubview:tasteMetUserMessageLabel];
    
//    userSelectionTableView.tableHeaderView = metUserFBView;
    
    
    UIView *statsContainer = [self displayMetUserStats];
    statsContainer.frame = CGRectMake(0, metUserFBView.frame.size.height - (75 + 45),
                                      CGRectGetWidth(statsContainer.frame), CGRectGetHeight(statsContainer.frame));
    [metUserFBView addSubview:statsContainer];
    
    UISegmentedControl *filterUserMetListSC = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Alls", nil), NSLocalizedString(@"to discover", nil), NSLocalizedString(@"in common", nil)]];
    filterUserMetListSC.frame = CGRectMake(10, 5, screenWidth - 20, 30);
    [filterUserMetListSC addTarget:self action:@selector(filterTableview:) forControlEvents: UIControlEventValueChanged];
    filterUserMetListSC.selectedSegmentIndex = 0;
    filterUserMetListSC.tag = 9;
    filterUserMetListSC.tintColor = [UIColor whiteColor];
    filterUserMetListSC.backgroundColor = [UIColor clearColor];
    
    UIView *metUserFBViewLastView = [[userMetLikesTableView subviews] lastObject];

    filterUserMetListSC.frame = CGRectMake(10, CGRectGetMaxY(statsContainer.frame) + 10, screenWidth - 20, 30);
    
    [metUserFBView addSubview:filterUserMetListSC];
    
    metUserFBViewLastView = [[userMetLikesTableView subviews] lastObject];
    
//    userMetLikesTableView.backgroundView = emptyUserLikesBtn;
    
    
    [userMetLikesTableView setContentOffset:CGPointMake(0, 0)]; //metUserFBView.bounds.size.height
    
    userMetLikesTableView.tableHeaderView = metUserFBView;
}

/*
 * This method display the details about user met
 * number of movies and films
 *
 */

- (UIView*) displayMetUserStats
{
//    UIView *metUserFBView = (UIView*)[self.view viewWithTag:4];
    
    UIView *statsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    statsContainer.backgroundColor = [UIColor clearColor];
//    [metUserFBView addSubview:statsContainer];
    
    float widthViews = 99.0f;
    for (int i = 0; i < [[self.metUserLikesDictRef filterKeysForNullObj] count]; i++) {
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(widthViews, 0.0f, 1.0, 75.0f);
        rightBorder.backgroundColor = [UIColor whiteColor].CGColor;
        
        NSString *title = [NSLocalizedString([[[self.metUserLikesDictRef filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:i], nil) uppercaseString];
        
        
        CGRect statContainerFrame = CGRectMake(0 + (95 * i),
                                               0,
                                               widthViews, 70);
        
        
        UIButton *statContainer = [[UIButton alloc] initWithFrame:statContainerFrame];
        statContainer.backgroundColor = [UIColor clearColor];
        statContainer.tag = i;
        
        [statContainer addTarget:self action:@selector(scrollToSectionWithNumber:) forControlEvents:UIControlEventTouchUpInside];

        
        [statsContainer addSubview:statContainer];
        if ( i != ([[self.metUserLikesDictRef filterKeysForNullObj] count] - 1)) {
            [statContainer.layer addSublayer:rightBorder];
        }
        
        UILabel *statTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, -5, widthViews, 30)];
        statTitle.textColor = [UIColor whiteColor];
        statTitle.backgroundColor = [UIColor clearColor];
        statTitle.text = title;
        statTitle.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0f];

        [statContainer addSubview:statTitle];
        
        
        
        UILabel *statCount = [[UILabel alloc] initWithFrame:CGRectMake(12, statContainer.frame.size.height - 34, widthViews, 35.0)];
        statCount.textColor = [UIColor whiteColor];
        statCount.backgroundColor = [UIColor clearColor];
        statCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45.0f];

        NSString *statCountNumber = [[NSNumber numberWithInteger:[[self.metUserLikesDictRef objectForKey:[[[self.metUserLikesDictRef filterKeysForNullObj]  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]objectAtIndex:i]] count]] stringValue];
        statCount.text = statCountNumber;
        [statContainer insertSubview:statCount atIndex:10];
    }
    
    return statsContainer;
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
- (void) getServerDatasForFbID:(NSString*)userfbID
{
    NSString *aURLString = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user"];
    aURLString = [aURLString stringByAppendingString:[NSString stringWithFormat:@"?fbiduser=%@", userfbID]];
    
    NSURL *aUrl = [NSURL URLWithString:aURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    
    [request addValue:@"getServerDatasForFbID" forHTTPHeaderField:@"X-Shound"];
    [request setHTTPMethod:@"GET"];
    
//    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@&isspecificuser=%@", userfbID, @"true"];
//    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
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
            NSDictionary *allDatasFromServerDict = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] objectForKey:@"response"];

            // This user has really updated is data we udpdate locals datas
            if (![self.metUserLikesDictRef isEqualToDictionary:[[allDatasFromServerDict objectForKey:@"list"] mutableCopy] ]) {
                // We update the current data from the server
                self.metUserLikesDictRef = [[allDatasFromServerDict objectForKey:@"list"] mutableCopy];
                NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[allDatasFromServerDict objectForKey:@"list"]];
                
                NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbId == %@", self.metUserId];
                Discovery *oldDiscovery = [Discovery MR_findFirstWithPredicate:userPredicate];
                oldDiscovery.likes = arrayData;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
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
            [[NSUserDefaults standardUserDefaults] setObject:favsIDUpdatedList
                                                      forKey:@"favsIDUpdatedList"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"seenFavUpdated"
                                                                object:nil userInfo:nil];
        }
    }
}

- (NSString*) calcUserMetPercentMatch
{
    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
    int commonTasteCount = 0;
    int currentUserNumberItems = 0;

    for (int i = 0; i < [[self.metUserLikesDictRef filterKeysForNullObj] count]; i++) {
        NSString *key = [[self.metUserLikesDictRef filterKeysForNullObj] objectAtIndex:i];

        if (![[currentUserTaste objectForKey:key] isEqual:[NSNull null]]) {
            currentUserTasteSet = [NSMutableSet setWithArray:[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"]];
            
            currentUserNumberItems += [[self.metUserLikesDictRef objectForKey:key] count];
        }
        
        if (![[self.metUserLikesDictRef objectForKey:key] isEqual:[NSNull null]]) {
            currentUserMetTasteSet = [NSMutableSet setWithArray:[[self.metUserLikesDictRef objectForKey:key] valueForKey:@"imdbID"]];
        }
        
        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the obejcts that are in both sets
        
        NSArray* result = [currentUserMetTasteSet allObjects];
        
        commonTasteCount += result.count;
        
        
    }
    
    CGFloat commonTasteCountPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
    
    if (isnan(commonTasteCountPercent)) {
        commonTasteCountPercent = 0.0f;
    }
    

    // If the user has only 100% in common
    if (commonTasteCountPercent == (float)1) {
        commonTasteCountPercent = 1.0;
    }
    
    // substract 1 cause NSNumberFormatter for percent waits a value between (0 and 1)
    commonTasteCountPercent = 1 - commonTasteCountPercent;
    
    
    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *strNumber = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:commonTasteCountPercent]];
    
    return strNumber;
}

// - (Discovery*) getFacebookFriendForFbId:(NSString*)userfbID

//- (void) getFacebookFriendForModel
// - (Discovery*) getFacebookFriendForFbId:(NSString*)userfbID

- (Discovery*) getFacebookFriendForFbId:(NSString*)userfbID
{
    
    NSString *aURLString = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user"];
    aURLString = [aURLString stringByAppendingString:[NSString stringWithFormat:@"?fbiduser=%@", userfbID]];
    
    NSURL *aUrl = [NSURL URLWithString:aURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    
    [request addValue:@"getServerDatasForFbID" forHTTPHeaderField:@"X-Shound"];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
   
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    
    if (error == nil) {
        NSMutableDictionary *serverResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"response"];
        
        NSData *likesRawData = [NSKeyedArchiver archivedDataWithRootObject:[serverResponse objectForKey:@"list"]];
        
        Discovery *facebookFriendNotDiscoveredYet = [Discovery MR_createEntityInContext:[NSManagedObjectContext MR_context]];
        facebookFriendNotDiscoveredYet.isFavorite = NO;
        facebookFriendNotDiscoveredYet.likes = likesRawData;
        facebookFriendNotDiscoveredYet.fbId = serverResponse[@"fbId"];
        facebookFriendNotDiscoveredYet.numberOfDiscoveries = [NSNumber numberWithInt:1];
        
        return facebookFriendNotDiscoveredYet;

    } else {
        NSLog(@"error : %@", error);
        return nil;
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
    
    
    CALayer *imgLayer = [CALayer layer];
    imgLayer.frame = cellFrame;
    [imgLayer addSublayer:gradientLayer];
    
    
    NSString *apiLink;
    
    __block NSString *imgName;
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
                imgName = [responseObject valueForKeyPath:@"tv_results.poster_path"][0];
            } else {
                imgName = responseObject[@"poster_path"];
            }
            
            NSString *imgSize = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) ? @"w396" : @"w780";
            imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/%@%@", imgSize, imgName];
            
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
    NSString *sectionTitle = [[[self.metUserLikesDictRef filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];

    UISegmentedControl *segmentedControl = (UISegmentedControl*)[self.view viewWithTag:9];

    NSMutableArray *metUserLikesIdsForIndex = [[[self.metUserLikesDict objectsForKeys:[self.metUserLikesDict allKeys] notFoundMarker:[NSNull null]] valueForKey:@"imdbID"] mutableCopy];
        [metUserLikesIdsForIndex removeObjectIdenticalTo:[NSNull null]];
    // Linearise the array
    NSArray *flatArray = [metUserLikesIdsForIndex valueForKeyPath: @"@unionOfArrays.self"];
    
    NSArray *sectionElements;
    
    NSArray *currentUserImdbID = [currentUserTaste[sectionTitle] valueForKey:@"imdbID"];
    NSArray *metUserLikesForKey = self.metUserLikesDictRef[sectionTitle];

    switch (segmentedControl.selectedSegmentIndex) {
            // Everything
        case 0:
            sectionElements = metUserLikesForKey;
            break;
            // to discover
        case 1:
            sectionElements = [metUserLikesForKey filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT imdbID IN %@", currentUserImdbID]];
            break;
            // in common
        case 2:
            sectionElements = [metUserLikesForKey filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imdbID IN %@", currentUserImdbID]];
            break;
        
        default:
            break;
    }
    
    [self.metUserLikesDict setObject:sectionElements
                         forKey:sectionTitle];
    
    
    // If the category is empty so the section not appears
    if ([sectionElements isKindOfClass:[NSNull class]]) {
        return 0;
    }
    
    UIButton *emptyUserLikesBtn = (UIButton*)[self.view viewWithTag:10];
    if (flatArray.count == 0 && segmentedControl.selectedSegmentIndex == 2) {
        emptyUserLikesBtn.hidden = NO;
    } else {
        emptyUserLikesBtn.hidden = YES;
    }
    

    return sectionElements.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.metUserLikesDict filterKeysForNullObj] count];
}

// Title of categories
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 16.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 52.0)];
    headerView.opaque = YES;
    
    //    headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.85f];
    //    headerView.backgroundColor = [UIColor clearColor];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = headerView.frame;
    
    [headerView addSubview:visualEffectView];
    
    NSString *sectionTitleRaw = [[[self.metUserLikesDict filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    NSString *title = [NSLocalizedString(sectionTitleRaw, nil) uppercaseString];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 52.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    label.textColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1];
    [label sizeToFit];
    label.frame = CGRectMake(15.0, CGRectGetHeight(headerView.frame) - CGRectGetHeight(label.frame) - 10,
                             screenWidth, CGRectGetHeight(label.frame));
    
    
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
    NSString *sectionTitle = [[[self.metUserLikesDict filterKeysForNullObj] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]
                                                                          objectAtIndex:indexPath.section];
    NSString *title, *imdbID; // year
    ShareListMediaTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *rowsOfSection = [self.metUserLikesDict objectForKey:sectionTitle];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bgColorView = [UIView new];
        [bgColorView setBackgroundColor:[UIColor colorWithWhite:1 alpha:.09]];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.alpha = .3f;
    }
    
    if (![currentUserTaste[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] isEqual:[NSNull null]]) {
        if ([[currentUserTaste[[rowsOfSection objectAtIndex:indexPath.row][@"type"]] valueForKey:@"imdbID"] containsObject:[[rowsOfSection objectAtIndex:indexPath.row] objectForKey:@"imdbID"]]) {
            cell.imageView.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        } else {
            cell.imageView.image = nil;
        }
    }
    
    cell.model = [rowsOfSection objectAtIndex:indexPath.row];
    
    if (imdbID != nil) {
        [self getImageCellForData:cell.model aCell:cell];
    }
    
    if ([[rowsOfSection objectAtIndex:indexPath.row][@"type"] isEqualToString:@"serie"]) {
        [self getLastNextReleaseSerieEpisodeForCell:cell];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    cell.textLabel.text = title;
    
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
    
    DetailsMediaViewController *detailsMediaViewController = [DetailsMediaViewController new];
    detailsMediaViewController.mediaDatas = selectedCell.model;
    detailsMediaViewController.userDiscoverId = self.metUserId;
    detailsMediaViewController.title = [selectedCell.model objectForKey:@"name"];

    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Called when the last cell is displayed
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [UIView animateWithDuration:0.45 delay:0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             tableView.alpha = 1;
                         }
                         completion:nil];
    }
}


- (void) filterTableview:(id)sender
{
    [self reloadTableview];
}

- (void) reloadTableview
{    
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    [userMeetingsListTableView reloadData];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [[userMeetingsListTableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
}


- (void) addAsFavorite:(UIBarButtonItem*)sender
{
    NSString *currentUserPFChannelName = @"sh_channel_";
    currentUserPFChannelName = [currentUserPFChannelName stringByAppendingString:self.metUserId];


    NSMutableArray *rightBarButtonItemsArray = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    
    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    // Current list seen is added to user favs discovers
    if ([sender.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
        sender.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        [self.userDiscovered setIsFavorite:YES];
        
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
        [self.userDiscovered setIsFavorite:NO];
        
        
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
    self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
    AFHTTPRequestOperationManager *HTTPManager = [AFHTTPRequestOperationManager manager];
    [HTTPManager.requestSerializer setValue:@"install" forHTTPHeaderField:@"X-Shound"];
    NSDictionary *params = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"],
                             @"fbiduserfollowing": self.metUserId};
    
     NSString *urlLinkString = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user/follow"];
    
    if (aStatus == Unfollow) {
        [HTTPManager DELETE:urlLinkString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSInteger nbFollowers = (([statCount.text intValue] - 1) > 0) ? ([statCount.text intValue]-1) : 0;
            statCount.text = [[NSNumber numberWithInteger:nbFollowers] stringValue];
            self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    } else {
        [HTTPManager POST:urlLinkString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            statCount.text = [[NSNumber numberWithInt:([statCount.text intValue]+1)] stringValue];
            self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
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

#pragma mark - custom methods

- (void) displayDiscoverTabTV:(UIButton*)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*)[self.view viewWithTag:9];
    
    [segmentedControl setSelectedSegmentIndex:1];
    [segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
}

// Indicate if the current view is a modal
- (BOOL) isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (void) dismissModal {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - facebook sharing

- (void) shareFb
{
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
    content.contentURL = [NSURL URLWithString:@"http://www.shound.fr"];
    content.contentTitle = [NSString stringWithFormat:NSLocalizedString(@"FBLinkShareParams_metfriend_name %@", nil), self.title];
    content.contentDescription = NSLocalizedString(@"FBLinkShareParams_metfriend_desc", nil);
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
