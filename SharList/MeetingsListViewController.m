//
//  MeetingsListViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 24/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "MeetingsListViewController.h"



@interface MeetingsListViewController ()

@end

#pragma mark - tag list references
// Tag list
// 1  : Tableview of meeting list
// 2  : segmentedControl
// 3  : emptyFavoritesLabel
// 4  : emptyMeetingsLabel
// 5  : segmentedControlView
// 6  : emptyFacebookFriendsLabelView
// 7  : allowFriendsBtn
// 8  : emptyFacebookFriendsLabel
// 9  : tutorialView
// 10 : refreshBtnBar
// 11 : refreshControl
// 12 : fbSegCtrlBtn

@implementation MeetingsListViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.tabBarController.tabBar setHidden:NO];
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [[self navigationController] tabBarItem].badgeValue = nil;
    
    if (![FBSDKAccessToken currentAccessToken] && ![userPreferences objectForKey:@"currentUserfbID"]) {
        ConnectView *connectView = [[ConnectView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        connectView.viewController = self;
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:connectView];
    }
    
    // Manage disconnect case
    if ([userPreferences objectForKey:@"currentUserfbID"] && ![[userPreferences objectForKey:@"currentUserfbID"] isEqual:[userPreferences objectForKey:@"lastUserfbID"]] && [userPreferences objectForKey:@"lastUserfbID"] != nil) {
        [userPreferences setObject:[userPreferences objectForKey:@"currentUserfbID"]
                            forKey:@"lastUserfbID"];
        [tableView reloadData];
    }
    
    [self navigationItemRightButtonEnablingManagement];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (grantedSettings.types != UIUserNotificationTypeNone) {
            // Reset the badge notification number
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[self navigationController] tabBarItem].badgeValue = nil;
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    // Split mode only
//    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [userMeetingsListTableView selectRowAtIndexPath:indexPath animated:NO
//                     scrollPosition:UITableViewScrollPositionBottom];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // We create an offset to manage uisplitview we user the width of the masterview because this view is the masterviewcontroller
//    NSUInteger realWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? self.splitViewController.primaryColumnWidth : screenRect.size.width;
    
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    self.FilterEnabled = NO;
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    if ([userPreferences objectForKey:@"noresultsgeoloc"] == nil) {
        [userPreferences setInteger:0 forKey:@"noresultsgeoloc"];
    }
    
    if (([FBSDKAccessToken currentAccessToken] || [userPreferences objectForKey:@"currentUserfbID"]) && [userPreferences objectForKey:@"installationDate"]) {
        if (![userPreferences objectForKey:@"warningDisconnectMessageHaveBeenDisplayV1"]) {
            [self showWarningMessage];
            [userPreferences setObject:@1 forKey:@"warningDisconnectMessageHaveBeenDisplayV1"];
        }
    }
    
    // TODO : REMOVE BEFORE SOUMISSION
//    [UserTaste MR_truncateAll];

    // View init
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.tableViewAdded = NO;
    
    
    
    //Main screen display
//    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
//    
//    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
//    gradientBGView.frame = self.view.bounds;
//    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
//    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
//    gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
//    [self.view.layer insertSublayer:gradientBGView atIndex:0];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    
    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
    gradientBGView.frame = self.view.frame;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradientBGView atIndex:0];
    
    CALayer *bgLayer = [CALayer layer];
    bgLayer.frame = self.view.bounds;
    bgLayer.opacity = .7f;
    bgLayer.name = @"TrianglesBG";
    bgLayer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"TrianglesBG"]].CGColor;
    [self.view.layer insertSublayer:bgLayer atIndex:1];
    
    // Called when the user is connected to facebook
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializer) name:@"mainViewIsReady" object:nil];
    
    // This method is called when user quit the app
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(appEnteredBackground) name: @"didEnterBackground" object: nil];
    // This method is called when user go back to app
    // User not enable bgfetch
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(navigationItemRightButtonEnablingManagement) name: @"didEnterForeground" object: nil];
    // User enable bgfetch
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(meetingsListHaveBeenUpdate) name: @"didEnterForeground" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotificationFavorite" object:nil];
    
    // Called when user see a fav discover
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableview) name:@"seenFavUpdated" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(manageDisplayOfFacebookFriendsButton) name: @"userConnectedToFacebook" object: nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
//    [self maskTest];

    
    if ([FBSDKAccessToken currentAccessToken] || [userPreferences objectForKey:@"currentUserfbID"]) {
        [self fetchUserFacebookFriendsReloadAfter:NO];
        [self initializer];
    }
}



// Because of the facebook login we can't load the ui directly
- (void) initializer
{
    // Design on the view
    UIAlertView *alertBGF;
    alertBGF.delegate = self;
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied && ![userPreferences boolForKey:@"seenAlertForBGF"]) { //
        alertBGF = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"disabledBGF", nil) delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
        [alertBGF show];
        // We display only once the alert for no bgf enabled
        [userPreferences setBool:YES forKey:@"seenAlertForBGF"];
    } else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted && ![userPreferences boolForKey:@"seenAlertForBGF"]) {
        alertBGF = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"restrictedBGF", nil) delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
        [alertBGF show];
        [userPreferences setBool:YES forKey:@"seenAlertForBGF"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MeetingsListTutorialV2"] && [FBSDKAccessToken currentAccessToken]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MeetingsListTutorialV2"];
        [self showTutorial];
    }
    
    self.discoveries = [NSMutableDictionary new];
    
    UIView *tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 366)]; //284
    tableViewHeader.backgroundColor = [UIColor clearColor];
    
    UIView *segmentedControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
//    segmentedControlView.backgroundColor = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f];
    segmentedControlView.backgroundColor = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.35f];
    segmentedControlView.opaque = NO;
    segmentedControlView.tag = 2;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All", nil), NSLocalizedString(@"Favorites", nil), @"Facebook"]];
    
    segmentedControl.frame = CGRectMake(10, 5, screenWidth - 20, 30);
    [segmentedControl addTarget:self action:@selector(filterTableview:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tag = 5;
    segmentedControl.backgroundColor = [UIColor redColor];
    segmentedControl.center = CGPointMake(screenWidth/2, CGRectGetHeight(segmentedControlView.frame)/2);
    segmentedControl.tintColor = [UIColor whiteColor];
    
    [segmentedControlView addSubview:segmentedControl];
    
    UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.0, screenWidth, 60)];
    tableFooter.textColor = [UIColor whiteColor];
    tableFooter.textAlignment = NSTextAlignmentCenter;
    tableFooter.opaque = YES;
    tableFooter.font = [UIFont boldSystemFontOfSize:15];
    
    NSNumber *countMeetings = [NSNumber numberWithInt:[[Discovery MR_numberOfEntities] intValue] - 1]; // We remove current user
    tableFooter.text = [NSString sentenceCapitalizedString:[NSString stringWithFormat:NSLocalizedString(@"%@ meetings", nil), countMeetings]];
    
    UITableView *discoveriesListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 49) style:UITableViewStylePlain];
    discoveriesListTableView.dataSource = self;
    discoveriesListTableView.delegate = self;
    discoveriesListTableView.backgroundColor = [UIColor clearColor];
//    userMeetingsListTableView.backgroundColor = [UIColor colorWithWhite:1 alpha:.5];
    discoveriesListTableView.tag = 1;
    discoveriesListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    discoveriesListTableView.estimatedRowHeight = 200.0;
    discoveriesListTableView.tableFooterView = tableFooter;
    discoveriesListTableView.tableHeaderView = segmentedControlView;
    discoveriesListTableView.contentInset = UIEdgeInsetsMake(0, 0, 18, 0);
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.tag = 11;
    refreshControl.tintColor = [UIColor whiteColor];
//    refreshControl.backgroundColor = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.35f];
    refreshControl.backgroundColor = [UIColor clearColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [discoveriesListTableView addSubview:refreshControl];
    
    //    [userMeetingsListTableView scrollToRowAtIndexPath:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];

    if (!self.isTableViewAdded) {
        [self.view addSubview:discoveriesListTableView];
        self.tableViewAdded = YES;
    }
    
    
    // Message for empty list meetings
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Tap on  in a meeting to add it among your favorites", nil)];
    UIImage *lensIcon = [UIImage imageNamed:@"favorite-icon-message-alt"];
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = lensIcon;
    textAttachment.bounds = CGRectMake(0, -10, lensIcon.size.width, lensIcon.size.height);
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSRange r = [[attributedString string] rangeOfString:NSLocalizedString(@"Tap on ", nil)];
    [attributedString insertAttributedString:attrStringWithImage atIndex:(r.location + r.length)];
    
    CGFloat emptyUserTasteLabelPosY = 45;
    UILabel *emptyFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, screenWidth - 24, 90)];
    emptyFavoritesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyFavoritesLabel.attributedText = attributedString; //Appuyez {sur l'étoile} pour ajouter aux favoris
    emptyFavoritesLabel.textColor = [UIColor whiteColor];
    emptyFavoritesLabel.numberOfLines = 0;
    emptyFavoritesLabel.bounds = CGRectInset(emptyFavoritesLabel.frame, 0.0f, -10.0f);
    emptyFavoritesLabel.textAlignment = NSTextAlignmentCenter;
    emptyFavoritesLabel.tag = 3;
    emptyFavoritesLabel.hidden = YES;
    emptyFavoritesLabel.backgroundColor = [UIColor clearColor];
    emptyFavoritesLabel.center = CGPointMake(screenWidth / 2, self.view.center.y - 60);
    [discoveriesListTableView addSubview:emptyFavoritesLabel];
    
    
    NSMutableAttributedString *emptyMeetingsLabelAttrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Tap on  to discover new things", nil)];
    UIImage *refreshIcon = [[UIImage imageNamed:@"refreshBarItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    NSTextAttachment *textAttachment2 = [NSTextAttachment new];
    textAttachment2.image = refreshIcon;
    textAttachment2.bounds = CGRectMake(0, -10, 38.0, 38.0);

    NSAttributedString *attrStringWithRefreshImage = [NSAttributedString attributedStringWithAttachment:textAttachment2];
    
    NSRange r2 = [[emptyMeetingsLabelAttrString string] rangeOfString:NSLocalizedString(@"Tap on ", nil)];
    [emptyMeetingsLabelAttrString insertAttributedString:attrStringWithRefreshImage atIndex:(r2.location + r2.length)];
    
    // Message for no meetings
    UILabel *emptyMeetingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, emptyUserTasteLabelPosY, screenWidth - 24, 110)];
    emptyMeetingsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyMeetingsLabel.attributedText = emptyMeetingsLabelAttrString;
    emptyMeetingsLabel.textColor = [UIColor whiteColor];
    emptyMeetingsLabel.center = CGPointMake(screenWidth / 2, self.view.center.y - 60);
    emptyMeetingsLabel.numberOfLines = 0;
    emptyMeetingsLabel.textAlignment = NSTextAlignmentCenter;
    emptyMeetingsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emptyMeetingsLabel.backgroundColor = [UIColor clearColor];
    emptyMeetingsLabel.tag = 4;
    emptyMeetingsLabel.hidden = NO;
    [discoveriesListTableView addSubview:emptyMeetingsLabel];
    
    
    // Message for no fb friends :(
    UIView *emptyFacebookFriendsLabelView = [[UIView alloc] initWithFrame:CGRectMake(0.0, emptyUserTasteLabelPosY, screenWidth - 24, 99.0)];
    emptyFacebookFriendsLabelView.tag = 6;
    emptyFacebookFriendsLabelView.center = CGPointMake(screenWidth / 2, self.view.center.y - 60);
    emptyFacebookFriendsLabelView.userInteractionEnabled = YES;
    emptyFacebookFriendsLabelView.hidden = YES;
    emptyFacebookFriendsLabelView.backgroundColor = [UIColor clearColor];
    [discoveriesListTableView addSubview:emptyFacebookFriendsLabelView];
    
    
    
    UILabel *emptyFacebookFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(emptyFacebookFriendsLabelView.frame), 50)];
    emptyFacebookFriendsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyFacebookFriendsLabel.textColor = [UIColor whiteColor];
    emptyFacebookFriendsLabel.numberOfLines = 0;
    emptyFacebookFriendsLabel.tag = 8;
    emptyFacebookFriendsLabel.textAlignment = NSTextAlignmentCenter;
    emptyFacebookFriendsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emptyFacebookFriendsLabel.backgroundColor = [UIColor clearColor];
    
    [emptyFacebookFriendsLabelView addSubview:emptyFacebookFriendsLabel];
    
    UIButton *fbSegCtrlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fbSegCtrlBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    [fbSegCtrlBtn setFrame:CGRectMake(0, emptyFacebookFriendsLabel.frame.size.height + emptyFacebookFriendsLabel.frame.origin.y + 15.0f, emptyFacebookFriendsLabelView.frame.size.width, 54)];
    [fbSegCtrlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [fbSegCtrlBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.5 alpha:.15]] forState:UIControlStateHighlighted];
    [fbSegCtrlBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:.1 alpha:.5]] forState:UIControlStateDisabled];
    
    [fbSegCtrlBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    fbSegCtrlBtn.backgroundColor = [UIColor clearColor];
    fbSegCtrlBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    fbSegCtrlBtn.layer.borderWidth = 2.0f;
    fbSegCtrlBtn.tag = 12;
    [emptyFacebookFriendsLabelView addSubview:fbSegCtrlBtn];
    
    
    
    [self manageDisplayTabFacebookContent];
    
    
    loadingIndicator = [UIActivityIndicatorView new];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.view addSubview:loadingIndicator];
    
    [self getCurrentUserLikes];
    

}

- (NSString*) displayTimeWithSecond:(NSInteger)seconds
{
    NSInteger remindMinute = seconds / 60;
    NSInteger remindHours = remindMinute / 60;
    
    NSInteger remindMinutes = seconds - (remindHours * 3600);
    NSInteger remindMinuteNew = remindMinutes / 60;
    
    NSInteger remindSecond = seconds - (remindMinuteNew * 60) - (remindHours * 3600);

    NSString *remainingTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)remindHours, (long)remindMinuteNew, (long)remindSecond];

    return remainingTime;
}

- (void)refresh:(id)sender
{
    UIRefreshControl *refreshControl = (UIRefreshControl*)sender;
    dispatch_async(dispatch_get_main_queue(), ^{
        [sender beginRefreshing];
    });
    
    if ([userPreferences objectForKey:@"lastManualUpdate"]) {
        // User can make a new discovery
        if ([self timeBeforeNextDiscovery] > BGFETCHDELAY) {
            [self fetchNewDiscovery];
        } else {
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%@ time remaining before next", nil), [self displayTimeWithSecond:(BGFETCHDELAY - [self timeBeforeNextDiscovery])]];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                        forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
            refreshControl.attributedTitle = attributedTitle;
        }
    } else {
        [self fetchNewDiscovery];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [sender endRefreshing];
    });
}

/*
 * Retrieve the current user's list / likes
 *
 */

- (void) getCurrentUserLikes
{
    Discovery *currentUser = [Discovery MR_findFirstByAttribute:@"fbId"
                                                      withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    if ([currentUser likes]) {
        currentUserTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUser likes]] mutableCopy];
    }
}

//- (void) maskTest {
//    UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(25, 150, 50, 50)];
//    mask.layer.cornerRadius = 25.0f;
//    mask.backgroundColor = [UIColor redColor];
//    [self.view addSubview:mask];
//    
//    CGFloat startAngle = 0;
//    CGPoint center = CGPointMake(25, 25);
//    CGFloat radius = 25.0;
//    
//    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
//    [maskWithHole setPath:[self createPieSliceWithCenter:center radius:radius startAngle:startAngle endAngle:69.632653]];
//    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
//    
//    mask.layer.mask = maskWithHole;
//}

- (CGPathRef) createPieSliceWithCenter:(CGPoint)center
                                radius:(CGFloat)radius
                            startAngle:(CGFloat)degStartAngle
                              endAngle:(CGFloat)degEndAngle
{
    
    UIBezierPath *piePath = [UIBezierPath bezierPath];
    [piePath moveToPoint:center];
    [piePath addLineToPoint:CGPointMake(center.x + radius * cosf(DegreesToRadians(degStartAngle)), center.y + radius * sinf(DegreesToRadians(degStartAngle)))];
    [piePath addArcWithCenter:center radius:radius startAngle:DegreesToRadians(degStartAngle) endAngle:DegreesToRadians(degEndAngle) clockwise:YES];

    [piePath closePath]; // this will automatically add a straight line to the center
    return piePath.CGPath;
}

- (CGFloat) mappingValue:(CGFloat)valueIn {
    CGFloat const inMin = 0;
    CGFloat const inMax = BGFETCHDELAY;
    
    CGFloat const outMin = 0;
    CGFloat const outMax = 320.0;
    
    CGFloat valueOut = outMin + (outMax - outMin) * (valueIn - inMin) / (inMax - inMin);
    
    return valueOut;
}


#pragma mark - tutorial's methods
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
    tutorialView.tag = 9;
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
    tutFavsMessageTV.text = NSLocalizedString(@"refreshmeetingType", "text to introduce the three types of meetings");
    tutFavsMessageTV.textColor = [UIColor whiteColor];
    tutFavsMessageTV.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    tutFavsMessageTV.editable = NO;
    tutFavsMessageTV.textAlignment = NSTextAlignmentCenter;
    tutFavsMessageTV.backgroundColor = [UIColor clearColor];
    [tutFavsMessageTV sizeToFit];
    
    CGFloat tutFavsMessageTVYPercentage = 35.0;
    CGFloat tutFavsMessageTVY = roundf((screenHeight * tutFavsMessageTVYPercentage) / 100);
    tutFavsMessageTV.center = CGPointMake(self.view.center.x, tutFavsMessageTVY);
    [tutorialView addSubview:tutFavsMessageTV];


    CGFloat imgIndicatorWidthPercentage = 14.30;
    float typeMeetingLabelXSpacePercentage = 4.35;
    CGFloat typeMeetingLabelWidthPercentage = 81.0;
    
    float typeMeetingY = tutFavsMessageTV.frame.origin.y + tutFavsMessageTV.frame.size.height + 15;
    CGFloat typeMeetingLabelXSpace = roundf((tutFavsMessageTV.frame.size.width * typeMeetingLabelXSpacePercentage) / 100);
    CGFloat typeMeetingLabelWidth = roundf((tutFavsMessageTV.frame.size.width * typeMeetingLabelWidthPercentage) / 100);
    CGFloat imgIndicatorWidth = roundf((tutFavsMessageTV.frame.size.width * imgIndicatorWidthPercentage) / 100);

    NSArray *meetingTypesArr = @[@{@"imgName" : @"locationMeetingIcon", @"name" : NSLocalizedString(@"geolocated", nil), @"desc" : NSLocalizedString(@"geolocatedMeetingExplained", nil)},
                                 @{@"imgName" : @"randomMeetingIcon", @"name" : NSLocalizedString(@"random", nil), @"desc" : NSLocalizedString(@"randomMeetingExplained", nil)}
                                ];
    
    for (int i = 0; i < meetingTypesArr.count; i++) {
        UIImageView *imgIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(tutFavsMessageTV.frame.origin.x,
                                                                                  typeMeetingY + ((i * 20) + (i * imgIndicatorWidth)),
                                                                                  imgIndicatorWidth, imgIndicatorWidth)];
        NSString *imgName = [meetingTypesArr objectAtIndex:i][@"imgName"];
        imgIndicator.image = [[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imgIndicator.backgroundColor = [UIColor clearColor];
        imgIndicator.tintColor = [UIColor whiteColor];
        [tutorialView addSubview:imgIndicator];
        
        
        UILabel *typeMeetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgIndicator.frame.origin.x + imgIndicator.frame.size.width + typeMeetingLabelXSpace, typeMeetingY + ((i * 20) + (i * imgIndicatorWidth)), typeMeetingLabelWidth, 40)];
        
        typeMeetingLabel.textColor = [UIColor whiteColor];
        typeMeetingLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        
        NSString *description = [meetingTypesArr objectAtIndex:i][@"desc"];
        NSMutableAttributedString *typeMeetingAttrString = [[NSMutableAttributedString alloc] initWithString:description attributes: nil];
        NSString *stringToHighlight = [meetingTypesArr objectAtIndex:i][@"name"];
        NSRange r = [[typeMeetingAttrString string] rangeOfString:stringToHighlight];
        [typeMeetingAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0] range:NSMakeRange(r.location, r.length)];
        
        typeMeetingLabel.attributedText = typeMeetingAttrString;
        typeMeetingLabel.backgroundColor = [UIColor clearColor];
        typeMeetingLabel.numberOfLines = 0;
        [tutorialView addSubview:typeMeetingLabel];
    }
    
    UILabel *notaBene = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tutFavsMessageTV.frame.size.width, 36) ];
    notaBene.text = NSLocalizedString(@"notefacebook", nil);
    notaBene.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    notaBene.backgroundColor = [UIColor clearColor];
    notaBene.textAlignment = NSTextAlignmentCenter;
    notaBene.numberOfLines = 0;
    [notaBene heightToFit];
    notaBene.center = CGPointMake(self.view.center.x, typeMeetingY + 30 + ((meetingTypesArr.count * 20) + (meetingTypesArr.count * imgIndicatorWidth)));
    notaBene.textColor = [UIColor whiteColor];
    [tutorialView addSubview:notaBene];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(0, -5.0f, notaBene.frame.size.width, 1.0f);
    rightBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [notaBene.layer addSublayer:rightBorder];
    
    
    UIButton *closeTutorialBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeTutorialBtn addTarget:self action:@selector(hideTutorial) forControlEvents:UIControlEventTouchUpInside];
    [closeTutorialBtn setTitle:[NSLocalizedString(@"gotit", nil) uppercaseString] forState:UIControlStateNormal];
    
    closeTutorialBtn.frame = CGRectMake(20, notaBene.frame.size.height + notaBene.frame.origin.y + 35, screenWidth - 40, 30);
    closeTutorialBtn.tintColor = [UIColor whiteColor];
    closeTutorialBtn.backgroundColor = [UIColor clearColor];
    [closeTutorialBtn setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [closeTutorialBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:.50] forState:UIControlStateHighlighted];
    closeTutorialBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    [tutorialView addSubview:closeTutorialBtn];
}

- (void) hideTutorial
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *tutorialView = (UIView*)[[[UIApplication sharedApplication] keyWindow] viewWithTag:9];
    [UIView animateWithDuration:0.25 delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tutorialView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [tutorialView removeFromSuperview];
                     }];
}

- (void) pushNotificationReceived:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    DetailsMeetingViewController *detailsMeetingViewController = [DetailsMeetingViewController new];
    detailsMeetingViewController.metUserId = [userInfo objectForKey:@"userfbid"];
    detailsMeetingViewController.delegate = self;
    detailsMeetingViewController.isDisplayedFromPush = YES;
    [detailsMeetingViewController updateCurrentUser];
//    [self.navigationController pushViewController:detailsMeetingViewController animated:NO];
}

- (NSInteger) timeBeforeNextDiscovery
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *lastDataFetchingInterval = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[userPreferences objectForKey:@"lastManualUpdate"] toDate:[NSDate date] options:0];
    
    NSInteger hours = [lastDataFetchingInterval hour];
    NSInteger minutes = [lastDataFetchingInterval minute];
    NSInteger seconds = [lastDataFetchingInterval second];
    
    // If the meeting have been made less than one hour ago we do nothing
    NSInteger delayLastMeetingUser = (hours * 60 * 60) + (minutes * 60) + seconds;
    
    return delayLastMeetingUser;
}

// This function manage the enable state of refresh button
- (void) navigationItemRightButtonEnablingManagement
{
    UIButton *refreshBtnBarDisabledBG = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtnBarDisabledBG.frame = CGRectMake(0, 0, 24, 24);
    refreshBtnBarDisabledBG.enabled = NO;
    refreshBtnBarDisabledBG.tintColor = [UIColor blackColor];
    refreshBtnBarDisabledBG.userInteractionEnabled = NO;
    
    
    UIButton *refreshBtnBar = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtnBar.frame = CGRectMake(0, 0, 24, 24);
    [refreshBtnBar addTarget:self action:@selector(fetchNewDiscovery) forControlEvents:UIControlEventTouchUpInside];
    refreshBtnBar.showsTouchWhenHighlighted = NO;
    refreshBtnBar.alpha = 1.0;
    refreshBtnBar.enabled = NO;
    refreshBtnBar.tag = 10;
    refreshBtnBar.userInteractionEnabled = YES;
    refreshBtnBar.tintColor = [UIColor whiteColor];
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"refreshBarItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [refreshBtnBar setImage:backButtonImage forState:UIControlStateNormal];
    [refreshBtnBarDisabledBG setImage:backButtonImage forState:UIControlStateNormal];
    
    UIView *btnsRefreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    btnsRefreshView.backgroundColor = [UIColor clearColor];
    [btnsRefreshView addSubview:refreshBtnBarDisabledBG];
    [btnsRefreshView addSubview:refreshBtnBar];
    
    CGFloat startAngle = 0.0;
    CGPoint center = CGPointMake(12, 12);
    CGFloat radius = 24.0;
    
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithCustomView:btnsRefreshView];
    
    
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
    if ([userPreferences objectForKey:@"lastManualUpdate"]) {
        // If the meeting have been made less than one hour ago we do nothing
        NSInteger delayLastMeetingUser = [self timeBeforeNextDiscovery];
        
        if (delayLastMeetingUser > BGFETCHDELAY) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            refreshBtnBar.enabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.timerRefreshBtn invalidate];
                self.timerRefreshBtn = nil;
            });
        } else {
            CAShapeLayer *maskWithHole = [CAShapeLayer layer];
            [maskWithHole setPath:[self createPieSliceWithCenter:center
                                                          radius:radius
                                                      startAngle:startAngle
                                                        endAngle:[self mappingValue:delayLastMeetingUser]]];
            [maskWithHole setFillRule:kCAFillRuleEvenOdd];
            refreshBtnBar.layer.mask = maskWithHole;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!self.timerRefreshBtn.isValid) {
                    self.timerRefreshBtn = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                            target:self
                                                                          selector:@selector(updateRefreshBtnMask)
                                                                          userInfo:nil
                                                                           repeats:YES];
                }
            });
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        refreshBtnBar.enabled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.timerRefreshBtn invalidate];
            self.timerRefreshBtn = nil;
        });
    }
}

// "Watcher" for the btn refresh. The timer is invalidate if the user reach the limit
- (void) updateRefreshBtnMask {
    UIBarButtonItem *item = (UIBarButtonItem *)[self.navigationItem.rightBarButtonItems objectAtIndex:0];
    UIButton *refreshBtnBar = (UIButton *)[item.customView viewWithTag:10];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *lastDataFetchingInterval = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[userPreferences objectForKey:@"lastManualUpdate"] toDate:[NSDate date] options:0];
    
    NSInteger hours = [lastDataFetchingInterval hour];
    NSInteger minutes = [lastDataFetchingInterval minute];
    NSInteger seconds = [lastDataFetchingInterval second];
    
    // If the meeting have been made less than one hour ago we do nothing
    NSInteger delayLastMeetingUser = (hours * 60 * 60) + (minutes * 60) + seconds;
    
    CGFloat startAngle = 0.0;
    CGPoint center = CGPointMake(12, 12);
    CGFloat radius = 24.0;
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    [maskWithHole setPath:[self createPieSliceWithCenter:center
                                                  radius:radius
                                              startAngle:startAngle
                                                endAngle:[self mappingValue:delayLastMeetingUser]]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    refreshBtnBar.layer.mask = maskWithHole;
    
    if (delayLastMeetingUser > BGFETCHDELAY) {
        refreshBtnBar.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self invalidateTimer];
    }
}

- (void) invalidateTimer
{
    // We destroy the timer in the same thread in it was launched
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timerRefreshBtn invalidate];
        self.timerRefreshBtn = nil;
    });
}


- (void) appEnteredBackground
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void) filterTableview:(id)sender
{
    [self reloadTableview];
}

- (void) reloadTableview
{
    [loadingIndicator startAnimating];
    
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    [userMeetingsListTableView reloadData];

    [loadingIndicator stopAnimating];
}

- (void) reloadSections
{
    [loadingIndicator startAnimating];
    
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    
    NSIndexPath *selectedRowIndexPath = [userMeetingsListTableView indexPathForSelectedRow];

    [userMeetingsListTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [userMeetingsListTableView reloadData];
    
    [userMeetingsListTableView selectRowAtIndexPath:selectedRowIndexPath animated:NO
                     scrollPosition:UITableViewScrollPositionBottom];
    
    // http://stackoverflow.com/questions/7547934/animated-reloaddata-on-uitableview
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [[userMeetingsListTableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    
    
    [loadingIndicator stopAnimating];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"Settings", nil)])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


#pragma mark - Tableview configuration

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbId != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    
    // Count the number of distinct days
    NSArray *meetings = [[Discovery MR_findAllSortedBy:@"lastDiscovery"
                                             ascending:NO
                                         withPredicate:meetingsFilter] valueForKey:@"lastDiscovery"];

    // First loop get the unique days among meetings
    NSMutableSet *listUniqueDays = [NSMutableSet new];
    [meetings enumerateObjectsUsingBlock:^(NSDate *aDate, NSUInteger idx, BOOL *stop) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        if ([aDate isEqual:[NSNull null]]) {
            return;
        }
        [listUniqueDays addObject:[dateFormatter dateFromString:[dateFormatter stringFromDate:aDate]]];
    }];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self"
                                                               ascending:NO];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    // Transform to nsstring every date after ordering nsdate
    NSMutableArray *temp = [NSMutableArray new];
    [[[listUniqueDays allObjects] sortedArrayUsingDescriptors:@[descriptor]] enumerateObjectsUsingBlock:^(NSDate *aDate, NSUInteger idx, BOOL *stop) {
        [temp addObject:[dateFormatter stringFromDate:aDate]];
    }];

    self.listOfDistinctsDay = temp;
    
    if ([self.listOfDistinctsDay count] > 0) {
        // We show the uiSegmentedControl if there is some datas
        UIView *segmentedControlView = (UIView*)[self.view viewWithTag:2];
        segmentedControlView.hidden = NO;
    } else {
        [self manageEmptyViewForDatas:self.listOfDistinctsDay andAtableView:tableView];
    }
    
    // We create placeholder for future datas for the days
    for (NSString *dateString in listUniqueDays) {
        [self.discoveries setObject:@[] forKey:dateString];
    }
    
    return listUniqueDays.count;
}

// Title of categories
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 18.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 52.0)];
    headerView.opaque = YES;
    headerView.backgroundColor = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.35f];


    NSString *title = [self.listOfDistinctsDay objectAtIndex:section];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 52.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.frame = CGRectMake(15.0, CGRectGetHeight(headerView.frame) - CGRectGetHeight(label.frame) - 10,
                             screenWidth, CGRectGetHeight(label.frame));
    

    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 52.0;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbId != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    NSPredicate *favoritesMeetingsFilter = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    NSPredicate *facebookFriendsFilter = [NSPredicate predicateWithFormat:@"fbId IN %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"]];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl*)[self.view viewWithTag:5];
    
    NSCompoundPredicate *filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter]];
    
    switch (segmentedControl.selectedSegmentIndex) {
        // Favorites
        case 1:
        {
            filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter, favoritesMeetingsFilter]];
        }
            break;
            
        // Facebook friends
        case 2:
        {
            filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter, facebookFriendsFilter]];
        }
            break;
        default:
            break;
    }

    // We don't want the taste of the current user
    NSArray *meetings = [Discovery MR_findAllSortedBy:@"lastDiscovery" ascending:NO withPredicate:filterPredicates];
    
    [self manageEmptyViewForDatas:meetings andAtableView:tableView];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = NSLocalizedString(@"yyyy/MM/dd", nil);
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString *dateString = [self.listOfDistinctsDay objectAtIndex:section];
    
    
    NSDate *startDate = [[dateFormatter dateFromString:dateString] beginningOfDay];
    NSDate *endDate = [[dateFormatter dateFromString:dateString] endOfDay];
    
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(lastDiscovery >= %@) AND (lastDiscovery <= %@)", startDate, endDate];

    [self.discoveries setObject:[meetings filteredArrayUsingPredicate:datePredicate]
                         forKey:dateString];

    
    return [[self.discoveries objectForKey:[self.listOfDistinctsDay objectAtIndex:section]] count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    ShareListMediaTableViewCell *selectedCell = (ShareListMediaTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    DetailsMeetingViewController *detailsMeetingViewController = [DetailsMeetingViewController new];
    detailsMeetingViewController.metUserId = selectedCell.model;
    detailsMeetingViewController.delegate = self;
    
    [self.navigationController pushViewController:detailsMeetingViewController animated:YES];
}

- (void) setMediaThumbs:(NSDictionary*)userDiscoveredMedias
{
    NSLog(@"userDiscoveredMedias : %@", userDiscoveredMedias);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    
    ShareListMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Discovery *currentUserMet = [[self.discoveries objectForKey:[self.listOfDistinctsDay objectAtIndex: indexPath.section]] objectAtIndex:indexPath.row];
    
    SHDUserDiscovered *userDiscovered;
    

    
    UILabel *mainLabel;
    UIView *thumbsMediasView;
    UIImageView *profileImage;
    
    if (cell == nil) {
        cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                  reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        userDiscovered = [[SHDUserDiscovered alloc] initWithDatas:currentUserMet];
        
        userDiscovered.tag = 98;
       
//        userDiscovered.center = CGPointMake(cell.center.x, userDiscovered.center.y);
//        
//        mainLabel = userDiscovered.label;
//        [userDiscovered addSubview:mainLabel];
//        
//        thumbsMediasView = userDiscovered.mediaThumbsContainer;
//        [userDiscovered addSubview:thumbsMediasView];
//        
//        profileImage = userDiscovered.profileImage;
//        [userDiscovered insertSubview:profileImage atIndex:0];
//        
////        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 220.0, 15.0)];
////        
////        mainLabel.tag = 1;
////        [[omeUIView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
////        mainLabel.font = [UIFont systemFontOfSize:14.0];
////
////        NSLog(@"erere");
        
        SHDUserDiscoveredDatas *userDiscoveredDatas = [[SHDUserDiscoveredDatas alloc] initWithDiscoveredUser:currentUserMet];
        
        [userDiscovered mediaThumbs:userDiscoveredDatas.mediasIds];
        
        [cell.contentView addSubview:userDiscovered];
    } else {
//        mainLabel = (UILabel *) [cell viewWithTag:SHDDiscoverTimeLabelTag];
//        thumbsMediasView = (UIView *) [cell viewWithTag:SHDDiscoverMediaThumbsTag];
//        
//        profileImage = (UIImageView *) [cell viewWithTag:SHDDiscoverProfileImgTag];
        userDiscovered = (SHDUserDiscovered *)[cell.contentView viewWithTag:98];
    }
    
    
    
//    NSLog(@"userDiscoveredDatas : %@", userDiscoveredDatas.mediasIds);
    
//    NSDictionary *userMetLikes = [NSKeyedUnarchiver unarchiveObjectWithData:[currentUserMet likes]];
//    [self setMediaThumbs:userMetLikes];
//    
//    userDiscovered.userDiscovered = currentUserMet;
//    
//    [profileImage setImageWithURL:
//     [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", [currentUserMet fbId], (int)userDiscovered.frame.size.width, (int)userDiscovered.frame.size.height]]
//                               placeholderImage:[UIImage imageNamed:@"TrianglesBG"]];
//    
    
    
   
    
//    [userDiscovered setMediaThumbs:userMetLikes];
    
    
//    NSLog(@"%@, %@", @"rere", userMetLikes);
    

    mainLabel.text = currentUserMet.fbId;
    
    
    // http://stackoverflow.com/questions/3490433/how-should-i-addsubview-to-cell-contentview
    //https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/TableViewCells/TableViewCells.html

    
    
//    [Discovery MR_findFirstByAttribute:@"fbId"
//                                                      withValue:@10206263558692270]; // 10204552293319006 1387984218155378 1390483754598025 @529340940537761 10206263558692270
    

    
//    [self getCurrentUserLikes];
    // Calc of the stats

////        NSLog(@"%@", [currentUserMet fbId]);
//    NSDictionary *userMetLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUserMet likes]] mutableCopy];
//    
//
//    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
//    int commonTasteCount = 0;
//    int currentUserNumberItems = 0;
//    for (int i = 0; i < [[userMetLikes filterKeysForNullObj] count]; i++) {
//        NSString *key = [[userMetLikes filterKeysForNullObj] objectAtIndex:i];
//        if (![[currentUserTaste objectForKey:key] isEqual:[NSNull null]]) {
//            currentUserTasteSet = [NSMutableSet setWithArray:[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"]];
//            
//            currentUserNumberItems += [[userMetLikes objectForKey:key] count];
//        }
//        
//        if (![[userMetLikes objectForKey:key] isEqual:[NSNull null]]) {
//            currentUserMetTasteSet = [NSMutableSet setWithArray:[[userMetLikes objectForKey:key] valueForKey:@"imdbID"]];
//        }
//        
//        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the obejcts that are in both sets
//        
//        NSArray* result = [currentUserMetTasteSet allObjects];
//        
//        commonTasteCount += result.count;
//    }
//    
//    
//    
//    NSString *textLabelString = @"";
//    
//    CGFloat notCommonLikesPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
//    
//    if (isnan(notCommonLikesPercent)) {
//        notCommonLikesPercent = 0.0f;
//    }
//    
//    // If the user has only 1% in common
//    if (notCommonLikesPercent == (float)1) {
//        notCommonLikesPercent = 1.0;
//    }
//    
//    // substract 1 cause NSNumberFormatter for percent waits a value between (0 and 1)
//    notCommonLikesPercent = 1 - notCommonLikesPercent;
//    
//    if (notCommonLikesPercent == 1) {
//        UIColor *noLikeCommonColor = [UIColor colorWithRed:(228.0/255.0) green:(207.0/255.0) blue:(186.0/255.0) alpha:1.0];
//        cell.detailTextLabel.textColor = noLikeCommonColor;
//        cell.textLabel.textColor = noLikeCommonColor;
//        textLabelString = NSLocalizedString(@"nothing common", nil);
//    } else {
//        NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
//        [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
//        
//        if (notCommonLikesPercent == 0) {
//            textLabelString = NSLocalizedString(@"everything in common list", nil);
//            
//            UIColor *invisibleCellColor = [UIColor colorWithRed:(43.0/255.0)
//                                                     green:(97.0/255.0)
//                                                      blue:(122.0/255.0) alpha:1.0f];
//            
//            cell.textLabel.textColor = invisibleCellColor;
//            cell.detailTextLabel.textColor = invisibleCellColor;
//        } else {
//            NSString *strNumber = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:notCommonLikesPercent]];
//            textLabelString = [NSString stringWithFormat:NSLocalizedString(@"%@ not in common", nil), strNumber];
//            
//            cell.textLabel.textColor = [UIColor whiteColor];
//            cell.detailTextLabel.textColor = [UIColor whiteColor];
//        }
//    }
//    
//
//    NSDateFormatter *cellDateFormatter = [NSDateFormatter new];
//    cellDateFormatter.timeStyle = kCFDateFormatterShortStyle; // HH:MM:SS
//  
    cell.model = [currentUserMet fbId];
//
//    cell.textLabel.text = textLabelString;
//    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [cellDateFormatter stringFromDate:[currentUserMet lastDiscovery]]]; //[[NSNumber numberWithInteger:commonTasteCount] stringValue];
//    
//    // If this discovery is new the user is notified
//    if (!currentUserMet.isSeen) {
//        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:NSLocalizedString(@"new discovery" , nil)];
//    }
//    
//    
//    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"] containsObject:[currentUserMet fbId]]) {
//        NSString *indicateFavUpdatedString = @" - ";
//        indicateFavUpdatedString = [indicateFavUpdatedString stringByAppendingString:NSLocalizedString(@"updated", nil)];
//        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:indicateFavUpdatedString];
//        
//        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
//        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
//    }
//    
//
//    
//    // If the user is a facebook friend so we display his facebook profile image
//    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[currentUserMet fbId]]) {
//        [self getImageCellForData:[currentUserMet fbId]
//                            aCell:cell];
//        
//        cell.imageView.image = [MeetingsListViewController imageFromFacebookFriendInitialForId:[currentUserMet fbId]
//                                                                                     forDarkBG:NO];
////        cell.imageView.highlightedImage = [MeetingsListViewController imageFromFacebookFriendInitialForId:[currentUserMet fbId]
////                                                                                                forDarkBG:YES];
//        if ([currentUserMet isRandomDiscover]) {
//            cell.imageView.highlightedImage = [MeetingsListViewController imageForCellWithName:@"randomMeetingIcon"
//                                                                                     forDarkBG:YES
//                                                                                thingsInCommon:notCommonLikesPercent];
//        } else {
//            cell.imageView.highlightedImage = [MeetingsListViewController imageForCellWithName:@"locationMeetingIcon"
//                           forDarkBG:YES
//                      thingsInCommon:notCommonLikesPercent];
//        }
//        
//        cell.imageView.backgroundColor = [UIColor clearColor];
//        cell.imageView.opaque = YES;
//        cell.imageView.tag = indexPath.row;
//    } else {
//        if ([currentUserMet isRandomDiscover]) {
//            cell.imageView.image = [MeetingsListViewController imageForCellWithName:@"randomMeetingIcon"
//                                                                          forDarkBG:NO
//                                                                     thingsInCommon:notCommonLikesPercent];
//            cell.imageView.highlightedImage = [MeetingsListViewController imageForCellWithName:@"randomMeetingIcon"
//                                                                                     forDarkBG:YES
//                                                                                thingsInCommon:notCommonLikesPercent];
//        } else {
//            cell.imageView.image = [MeetingsListViewController imageForCellWithName:@"locationMeetingIcon" forDarkBG:NO thingsInCommon:notCommonLikesPercent];
//            cell.imageView.highlightedImage = [MeetingsListViewController imageForCellWithName:@"locationMeetingIcon" forDarkBG:YES thingsInCommon:notCommonLikesPercent];
//        }
//
//        cell.backgroundView = nil;
//        cell.imageView.backgroundColor = [UIColor clearColor];
//        cell.imageView.layer.cornerRadius = 20.0f;
//    }
    
    cell.imageView.tag = 1000;
    
    return cell;
}

// Scrolls but user keeps finger on the scrollview
- (void) scrollViewDidEndDragging:(UITableView *)tableView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadCellsMediasThumbsForTableView:tableView];
    }
}

// Big scrolling
- (void)scrollViewDidEndDecelerating:(UITableView *)tableView
{
    [self loadCellsMediasThumbsForTableView:tableView];
}

- (void) loadCellsMediasThumbsForTableView:(UITableView *) tableView
{
    for (UITableViewCell *aCell in [tableView visibleCells]) {
        NSIndexPath *aCellIndexPath = [tableView indexPathForCell:aCell];
        
        Discovery *currentUserMet = [[self.discoveries objectForKey:[self.listOfDistinctsDay objectAtIndex: aCellIndexPath.section]] objectAtIndex:aCellIndexPath.row];
        SHDUserDiscoveredDatas *userDiscoveredDatas = [[SHDUserDiscoveredDatas alloc] initWithDiscoveredUser:currentUserMet];
        
        SHDUserDiscovered *userDiscovered = (SHDUserDiscovered *)[aCell.contentView viewWithTag:98];
        userDiscovered.mediaThumbsContainer.hidden = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
            userDiscovered.mediaThumbsContainer.alpha = 1;
        }];
        
        [userDiscovered mediaThumbs:userDiscoveredDatas.mediasIds];
    }
}

- (void) unloadCellsMediasThumbsForTableView:(UITableView *) tableView andOpacity:(CGFloat)opacity
{
    for (UITableViewCell *aCell in [tableView visibleCells]) {
        SHDUserDiscovered *userDiscovered = (SHDUserDiscovered *)[aCell.contentView viewWithTag:98];
        userDiscovered.mediaThumbsContainer.alpha = opacity;
    }
}

- (void)scrollViewWillBeginDragging:(UITableView *)tableView
{
    [self unloadCellsMediasThumbsForTableView:tableView andOpacity:.15];
}

- (void)scrollViewWillBeginDecelerating:(UITableView *)tableView
{
    [self unloadCellsMediasThumbsForTableView:tableView andOpacity:.05];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Called when the last cell is displayed
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [loadingIndicator stopAnimating];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //use this for row u want to prevent to deSelect
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


+ (UIImage *) imageForCellWithName:(NSString*)imageName forDarkBG:(BOOL)isDarkBG thingsInCommon:(CGFloat)thingsInCommonCount
{
    UIImage *imageCell = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageCellView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageCellView.image = imageCell;
    
//    imageCellView.layer.borderColor = (isDarkBG) ? [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0].CGColor : [UIColor whiteColor].CGColor;
//    imageCellView.clipsToBounds = YES;
//    imageCellView.layer.cornerRadius = 20.0f;
//    imageCellView.layer.borderWidth = 1.0f;
    
    if (!isDarkBG && thingsInCommonCount == 1) {
        // Nothing in common
        imageCellView.tintColor = [UIColor colorWithRed:(228.0/255.0) green:(207.0/255.0) blue:(186.0/255.0) alpha:1.0];
    } else if (!isDarkBG && thingsInCommonCount == 0) {
        // Everything in common
        UIColor *invisibleCellColor = [UIColor colorWithRed:(43.0/255.0)
                                                      green:(97.0/255.0)
                                                       blue:(122.0/255.0) alpha:1.0f];
        imageCellView.tintColor = invisibleCellColor;
    } else {
        imageCellView.tintColor = (isDarkBG) ? [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0] : [UIColor whiteColor];
    }
    
    
    
    return [MeetingsListViewController imageWithView:imageCellView];
}

+ (UIImage *) imageFromFacebookFriendInitialForId:(NSString*)fbId forDarkBG:(BOOL)isDarkBG
{
    NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", fbId]];
    NSString *firstNameFirstLetter = [[[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""] substringToIndex:1];
    NSString *lastNameFirstLetter = [[[facebookFriendDatas valueForKey:@"last_name"] componentsJoinedByString:@""] substringToIndex:1];
    
    UILabel *initialPatronymFacebookFriendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    initialPatronymFacebookFriendLabel.text = [firstNameFirstLetter stringByAppendingString:lastNameFirstLetter];
    initialPatronymFacebookFriendLabel.textAlignment = NSTextAlignmentCenter;
    initialPatronymFacebookFriendLabel.backgroundColor = (isDarkBG) ? [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0] : [UIColor whiteColor];
    initialPatronymFacebookFriendLabel.textColor = (isDarkBG) ? [UIColor whiteColor] : [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0];
    initialPatronymFacebookFriendLabel.clipsToBounds = YES;
    initialPatronymFacebookFriendLabel.layer.cornerRadius = 20.0f;
    
    return [MeetingsListViewController imageWithView:initialPatronymFacebookFriendLabel];
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


- (void) meetingsListHaveBeenUpdate
{
    //    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted || [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
    //        return;
    //    }
    
    // We update the view behind the user like this when he comes back the view is updated
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:1];
    [userSelectionTableView reloadData];
}



- (void) getImageCellForData:(NSString*)fbFriendID aCell:(UITableViewCell*)cell
{
    CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = cellFrame;
    [gradientLayer setStartPoint:CGPointMake(-0.05, 0.5)];
    [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
    UIColor *topGradientView = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.80];
    UIColor *bottomGradientView = [UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:.80];
    gradientLayer.colors = @[(id)[topGradientView CGColor], (id)[bottomGradientView CGColor]];
    
    UIImageView *imgBackground = [[UIImageView alloc] initWithFrame:cellFrame];
    imgBackground.contentMode = UIViewContentModeScaleAspectFill;
    imgBackground.clipsToBounds = YES;
    
    cell.backgroundView = imgBackground;
    
    [imgBackground setImageWithURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", fbFriendID, (int)cellFrame.size.width, (int)cellFrame.size.height]]
                  placeholderImage:[UIImage imageNamed:@"TrianglesBG"]]; //10204498235807141
    [imgBackground.layer insertSublayer:gradientLayer atIndex:0];

}

- (void) manageEmptyViewForDatas:(NSArray*)datas andAtableView:(UITableView*)tableView
{
    // Vous avez pas d'amis facebook sur Shound
    UIView *emptyFacebookFriendsLabelView = (UIView*)[tableView viewWithTag:6];
    emptyFacebookFriendsLabelView.hidden = YES;
    
    // Vous n'avez pas de favoris user
    UILabel *emptyFavoritesLabel = (UILabel*)[tableView viewWithTag:3];
    emptyFavoritesLabel.hidden = YES;
    
    // Vous n'avez pas rencontré de personnes
    UILabel *emptyMeetingsLabel = (UILabel*)[tableView viewWithTag:4];
    emptyMeetingsLabel.hidden = YES;
    
    tableView.tableFooterView.hidden = NO;
    if ([datas count] == 0) {
        // We hide the segmented control on page load
        // only if there is nothing among ALL meetings
        // so user can have no favorites but he still has the segmentedControl
        
        UISegmentedControl *segmentedControl = (UISegmentedControl*)[self.view viewWithTag:5];
        switch (segmentedControl.selectedSegmentIndex) {
                // Filter disabled
            case 0:
            {
                emptyMeetingsLabel.hidden = NO;
                tableView.tableFooterView.hidden = YES;
            }
                break;
                
                // Favorites
            case 1:
            {
                emptyFavoritesLabel.hidden = NO;
                tableView.tableFooterView.hidden = YES;
            }
                break;
                
            case 2:
            {
                emptyFacebookFriendsLabelView.hidden = NO;
                tableView.tableFooterView.hidden = YES;
            }
                break;
            default:
                break;
        }
    }

}


#pragma mark - Fetch Datas in background

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastManualUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *currentUserfbID = [FBSDKAccessToken currentAccessToken].userID;
    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@", currentUserfbID];
    
    [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQueryWithUrlWithParams:postString] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
        } else {
            [self saveRandomUserDatas:data];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
}

- (BOOL) connected {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (void) fetchNewDiscovery
{
    if ([self connected] == NO) {
        [self noInternetAlert];
        return;
    }
    
    UIBarButtonItem *item = (UIBarButtonItem *)[self.navigationItem.rightBarButtonItems objectAtIndex:0];
    UIButton *refreshBtnBar = (UIButton *)[item.customView viewWithTag:10];
    refreshBtnBar.enabled = NO;
    
    [loadingIndicator startAnimating];
    
//    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
//    [userMeetingsListTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES]; @TODO
    
    [self startFetchingADiscovery];
}

- (void) startFetchingADiscovery
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] == NO) {
        NSString *currentUserfbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"];
        NSString *postString = [NSString stringWithFormat:@"fbiduser=%@&lastuserid=%@", currentUserfbID, [[Discovery MR_findFirstOrderedByAttribute:@"lastDiscovery" ascending:NO] fbId]];

        [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQueryWithUrlWithParams:postString] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                [loadingIndicator stopAnimating];
                [self noInternetAlert];
            } else {
                [self saveRandomUserDatas:data];
            }
        }];
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            if (!self.locationManager) {
                self.locationManager = [CLLocationManager new];
            }
            
            self.locationManager.delegate = self;
            self.locationManager.distanceFilter = distanceFilterLocalisation;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.pausesLocationUpdatesAutomatically = NO;
            self.locationManager.activityType = CLActivityTypeFitness;
            
            // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            
            [self.locationManager startUpdatingLocation];
        }
    }
}


- (NSMutableURLRequest*) fetchUsersDatasQueryWithUrlWithParams:(NSString*)params
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    NSString *urlString = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user/discover?"];
    urlString = [urlString stringByAppendingString:params];

    NSURL *aUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:9.0];
    [request setValue:@"discover" forHTTPHeaderField:@"X-Shound"];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

//- (NSMutableURLRequest*) fetchUsersDatasQueryWithUrlWithParams:(NSString*)anURL
//{
//    self.navigationItem.rightBarButtonItem.enabled = NO;
//    
//    // Contains globals datas of the project
//    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
//    // Build the array from the plist
//    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
//    
//    NSURL *aUrl = [NSURL URLWithString:[[settingsDict objectForKey:@"apiPath"] stringByAppendingString:@"getusertaste.php"]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                       timeoutInterval:15.0];
//    [request setHTTPMethod:@"POST"];
//    
//    
//    [request setHTTPBody:[anURL dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    return request;
//}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];

    NSString *currentUserfbID = [FBSDKAccessToken currentAccessToken].userID;
    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@&lastPosition_lat=%f&lastPosition_lng=%f&isGeolocEnabled", currentUserfbID, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    
    [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQueryWithUrlWithParams:postString] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [loadingIndicator stopAnimating];
            [self noInternetAlert];
        } else {
            [userPreferences setObject:[NSDate date] forKey:@"lastManualUpdate"];
            [self saveRandomUserDatas:data];
        }
    }];
}

- (void) saveRandomUserDatas:(NSData *)datas
{
    // name = "Bienvenue \U00c3\U00a0 Gattaca";
    // datas from random user "met" Naruto : Shipp\u00fbden Naruto : Shipp\U00fbden
    
    NSMutableDictionary *serverResponse = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"serverResponse : %@", serverResponse);
    if (serverResponse[@"error"]) {
        [loadingIndicator stopAnimating];
        return;
    }
    
    NSMutableDictionary *randomUserDatas = [serverResponse objectForKey:@"response"];
    

    // No datas retrieve from server
    // Maybe for geoloc
    if (randomUserDatas == nil || [randomUserDatas isEqual:(id)[NSNull null]]) {
        NSInteger numberOfNoResults = [[NSUserDefaults standardUserDefaults] integerForKey:@"noresultsgeoloc"];
        
        // User have fetch 5 times empty json (no data so)
        // A Notification is displayed to indicate user to talk about the app
        // Thx Carlos
        if (numberOfNoResults >= 2) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"noresultsgeoloc"];
            numberOfNoResults = 0;
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                UIAlertView *noNewDatasAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"nomeetingsalert", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [noNewDatasAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            } else {
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
                    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
                    if (grantedSettings.types != UIUserNotificationTypeNone) {                
                        UILocalNotification *localNotif = [UILocalNotification new];
                        localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:180]; // 180
                        localNotif.timeZone = [NSTimeZone defaultTimeZone];
                        localNotif.alertBody = NSLocalizedString(@"nomeetingsalert", nil);
                        localNotif.soundName = nil;
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                    }
                }
            }
        } else {
            numberOfNoResults += 1;
            [[NSUserDefaults standardUserDefaults] setInteger:numberOfNoResults forKey:@"noresultsgeoloc"];
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                UIAlertView *noNewDatasAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No results", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [noNewDatasAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
        }
        
        [loadingIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        return;
    }
    
    // If the user finds someone we postpone the query
    [userPreferences setObject:[NSDate date] forKey:@"lastManualUpdate"];
    
//    NSNumberFormatter *formatNumber = [NSNumberFormatter new];
//    [formatNumber setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *randomUserfbId = [randomUserDatas objectForKey:@"fbId"];
    NSNumber *randomUserdbId = [randomUserDatas objectForKey:@"id"];
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[randomUserDatas objectForKey:@"list"]];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbId == %@", randomUserfbId];
    Discovery *oldUserDiscovered = [Discovery MR_findFirstWithPredicate:userPredicate inContext:[NSManagedObjectContext MR_defaultContext]];
    NSNumber *oldUserCount = oldUserDiscovered.numberOfDiscoveries;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *discoveryDate;
    discoveryDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                             value:0
                                            toDate:[NSDate date]
                                           options:kNilOptions];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter stringFromDate:[NSDate date]];
    
    // If user exists we just update his value like streetpass on 3ds
    if (oldUserCount != 0 && randomUserfbId != nil && oldUserDiscovered != nil) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *conversionInfo = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[oldUserDiscovered lastDiscovery] toDate:[NSDate date] options:0];
        
        //        NSInteger days = [conversionInfo day];
        NSInteger hours = [conversionInfo hour];
        //        NSInteger minutes = [conversionInfo minute];
        
        
        // If the meeting have been made less than one hour ago we do nothing
        if ((long)hours < 1) {
            //            NSLog(@"already met");
            //            [loadingIndicator stopAnimating];
            //            [self fetchUsersDatasBtnAction];
            //            return;
        }
        
        oldUserDiscovered.dbId = randomUserdbId;
        oldUserDiscovered.likes = arrayData;
        oldUserDiscovered.fbId = randomUserfbId;
        oldUserDiscovered.lastDiscovery = discoveryDate; //[NSDate date];
        oldUserDiscovered.numberOfDiscoveries = [NSNumber numberWithInt:[oldUserDiscovered.numberOfDiscoveries intValue] + 1];
        oldUserDiscovered.isSeen = NO;
        
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] == YES)
            oldUserDiscovered.isRandomDiscover = NO;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

        
        [self endSavingNewEntry];
    } else {
        // It's a new user
        // So we create a entity in CoreData for him
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            Discovery *userTaste = [Discovery MR_createEntityInContext:localContext];
            userTaste.dbId = randomUserdbId;
            userTaste.likes = arrayData;
            userTaste.fbId = randomUserfbId;
            userTaste.lastDiscovery = discoveryDate;
            userTaste.isFavorite = NO;
            userTaste.numberOfDiscoveries = [NSNumber numberWithInt:1];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] == YES)
                userTaste.isRandomDiscover = NO;

        } completion:^(BOOL success, NSError *error) {
            [self endSavingNewEntry];
        }];
//        [self endSavingNewEntry];
    }
}


- (void) endSavingNewEntry
{
    // We set to 0 the count of no results fetch location
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"noresultsgeoloc"];
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self performSelectorOnMainThread:@selector(reloadSections) withObject:nil waitUntilDone:YES];
    } else {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (grantedSettings.types != UIUserNotificationTypeNone) {
            // Each time the user press the button refresh
            // To discover new things he creates a postpone
            [self cancelLocalNotificationWithValueForKey:@"discoverNew"];
            UILocalNotification *localNotification = [UILocalNotification new];
            localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:604800]; //604800 (One week)
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = 0;
            localNotification.alertAction = NSLocalizedString(@"localNotificationAlertActionRefresh", nil);
            localNotification.alertBody = NSLocalizedString(@"localNotificationAlertBodyRefresh", nil);
            localNotification.userInfo = @{@"locatificationName" : @"discoverNew"};
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
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


- (void) noInternetAlert
{
    UIAlertView *errConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"noconnection", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errConnectionAlertView show];
}


#pragma mark - facebook

// User want's to see friends
- (void) allowFacebookFriendsPermission
{
    FBSDKLoginManager *loginManager = [FBSDKLoginManager new];
    [loginManager logInWithReadPermissions:@[@"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        //TODO: process error or result.
        if (!error) {
            [self fetchUserFacebookFriendsReloadAfter:YES];
            
        }
    }];
}

- (void) fetchUserFacebookFriendsReloadAfter:(BOOL)haveToReloadViewAfter
{
    // We save the user's friends using application (and accepts this feature) for later
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends?fields=first_name,last_name" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSArray* facebookFriends;
                 
                 if ([[result valueForKeyPath:@"data"] isEqual:[NSNull null]]) {
                     facebookFriends = @[];
                 } else {
                     facebookFriends = [result valueForKeyPath:@"data"];
                 }
                 
                 [[NSUserDefaults standardUserDefaults] setObject:facebookFriends forKey:@"facebookFriendsList"];
                 [self manageDisplayTabFacebookContent];
                 if (haveToReloadViewAfter) {
                     [self performSelectorOnMainThread:@selector(reloadTableview) withObject:nil waitUntilDone:YES];
                 }
             }
         }];
    }
}

- (void) shareFb
{
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
    content.contentURL = [NSURL URLWithString:@"https://appsto.re/us/sYAB4.i"];
    content.contentTitle = NSLocalizedString(@"FBLinkShareParams_name", nil);
    content.imageURL = [NSURL URLWithString:@"http://shound.fr/shound_logo_fb.jpg"];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FBLinkShareParams_postsuccess_title", nil)
                                message:NSLocalizedString(@"FBLinkShareParams_postsuccess", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                message:NSLocalizedString(@"FBLinkShareParams_posterror", nil)
                               delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];

}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {}


- (void) manageDisplayTabFacebookContent
{
    UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
    UIView *emptyFacebookFriendsLabelView = (UIView*)[tableView viewWithTag:6];
    emptyFacebookFriendsLabelView.backgroundColor = [UIColor clearColor];
    
    UILabel *emptyFacebookFriendsLabel = (UILabel*)[emptyFacebookFriendsLabelView viewWithTag:8];
    UIButton *fbSegCtrlBtn = (UIButton*)[emptyFacebookFriendsLabelView viewWithTag:12];

    // User doesn't authorize shound to access his facebook friends who using the app
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
        emptyFacebookFriendsLabel.text = NSLocalizedString(@"facebook shound not granted", nil);
        
        [fbSegCtrlBtn setTitle:NSLocalizedString(@"authorize fb friends", nil) forState:UIControlStateNormal];
        [fbSegCtrlBtn addTarget:self action:@selector(allowFacebookFriendsPermission)
               forControlEvents:UIControlEventTouchUpInside];
    } else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] count] > 0) {
            NSMutableArray *friendsUsingAppArray = [NSMutableArray new];
            for (int i = 0; i < 3; i++) {
                if (i >= [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] count]) {
                    break;
                }
                
                [friendsUsingAppArray addObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] objectAtIndex:i] valueForKey:@"first_name"]];
            }
            
            NSString *friendsUsingApp = [friendsUsingAppArray componentsJoinedByString:@", "];
            emptyFacebookFriendsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has facebook friends", nil), friendsUsingApp];
        // No friends
        } else {
            emptyFacebookFriendsLabel.text = NSLocalizedString(@"no facebook friends", nil);
        }
        
        [fbSegCtrlBtn setTitle:NSLocalizedString(@"Talk about shound", nil) forState:UIControlStateNormal];
        [fbSegCtrlBtn addTarget:self action:@selector(shareFb) forControlEvents:UIControlEventTouchUpInside];
    }
    [emptyFacebookFriendsLabel heightToFit];
    
}

#pragma mark - custom methods

- (void) showWarningMessage
{
    UIView *warningMessageView = [[UIView alloc] initWithFrame:self.view.frame];
    warningMessageView.tag = 5678;
    warningMessageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.85];
    
    
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;
    
    [warningMessageView addSubview:visualEffectView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:warningMessageView];
    
    float percentHeight = (150*100)/screenHeight;
    UIView *warningMessageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, (percentHeight*screenHeight)/100, screenWidth, screenHeight-(percentHeight*screenHeight)/100)];
    warningMessageViewContainer.backgroundColor = [UIColor clearColor];
    
    UIImageView *warningPictoContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    warningPictoContainer.image = [[UIImage imageNamed:@"warning-picto"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    warningPictoContainer.center = CGPointMake(self.view.center.x, 0.0);
    warningPictoContainer.tintColor = [UIColor whiteColor];
    warningPictoContainer.backgroundColor = [UIColor clearColor];
    warningPictoContainer.contentMode = UIViewContentModeScaleAspectFill;
    [warningMessageViewContainer addSubview:warningPictoContainer];
    
    
    NSUInteger warningMessageY = warningPictoContainer.frame.size.height - 30;
    
    UITextView *warningMessage = [[UITextView alloc] initWithFrame:CGRectMake(0, warningMessageY, 225, 110)];
    warningMessage.text = [NSLocalizedString(@"warning message for update login issue", nil) uppercaseString];
    warningMessage.textColor = [UIColor whiteColor];
    warningMessage.center = CGPointMake(self.view.center.x, warningMessage.center.y);
    warningMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    warningMessage.textAlignment = NSTextAlignmentCenter;
    warningMessage.editable = NO;
    [warningMessage sizeToFit];
    warningMessage.backgroundColor = [UIColor clearColor];
    [warningMessageViewContainer addSubview:warningMessage];
    
    UIButton *endTutorial = [UIButton buttonWithType:UIButtonTypeCustom];
    [endTutorial addTarget:self action:@selector(hideWarning) forControlEvents:UIControlEventTouchUpInside];
    [endTutorial setTitle:[NSLocalizedString(@"gotit", nil) uppercaseString] forState:UIControlStateNormal];
    endTutorial.frame = CGRectMake(0, warningMessageViewContainer.frame.size.height - 150, screenWidth, 49);
    endTutorial.tintColor = [UIColor whiteColor];
    [endTutorial setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [endTutorial setTitleColor:[UIColor colorWithWhite:1.0 alpha:.50] forState:UIControlStateHighlighted];
    endTutorial.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    
    [warningMessageViewContainer addSubview:endTutorial];
    
    [warningMessageView addSubview:warningMessageViewContainer];
}

- (void) hideWarning
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *tutorialView = (UIView*)[[[UIApplication sharedApplication] keyWindow] viewWithTag:5678];
    [UIView animateWithDuration:0.25 delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tutorialView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [tutorialView removeFromSuperview];
                     }];
}

#pragma mark - misc

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
