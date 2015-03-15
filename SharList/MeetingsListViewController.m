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
// 1 : Tableview of meeting list
// 2 : segmentedControl
// 3 : emptyFavoritesLabel
// 4 : emptyMeetingsLabel
// 5 : segmentedControlView
// 6 : emptyFacebookFriendsLabelView
// 7 : allowFriendsBtn
// 8 : emptyFacebookFriendsLabel

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
    
    if (!FBSession.activeSession.isOpen || ![userPreferences objectForKey:@"currentUserfbID"]) {
        //        ConnectViewController *connectViewController = [ConnectViewController new];
        
        ConnectView *connectView = [[ConnectView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        connectView.viewController = self;
        UIView *foo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 900, 900)];
        foo.backgroundColor = [UIColor redColor];
        
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:connectView];
    }
    
    [self navigationItemRightButtonEnablingManagement];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Reset the badge notification number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[self navigationController] tabBarItem].badgeValue = nil;
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
    numberOfJSONErrors = 0;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    self.FilterEnabled = NO;
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    if ([userPreferences objectForKey:@"noresultsgeoloc"] == nil) {
        [userPreferences setInteger:0 forKey:@"noresultsgeoloc"];
    }

    // View init
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    
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
    } else {
        
    }
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    
    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
    gradientBGView.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradientBGView.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradientBGView atIndex:0];
    
    
    UIView *segmentedControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    segmentedControlView.backgroundColor = [UIColor colorWithWhite:1 alpha:.9f];
    segmentedControlView.opaque = NO;
    segmentedControlView.tag = 2;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All", nil), NSLocalizedString(@"Favorites", nil), @"Facebook"]];
    
    segmentedControl.frame = CGRectMake(10, 5, screenWidth - 20, 30);
    [segmentedControl addTarget:self action:@selector(diplayFavoritesMeetings:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tag = 5;
    segmentedControl.tintColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1.0f];
    [segmentedControlView addSubview:segmentedControl];
    
    UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.0, screenWidth, 60)];
    tableFooter.textColor = [UIColor whiteColor];
    tableFooter.textAlignment = NSTextAlignmentCenter;
    tableFooter.opaque = YES;
    tableFooter.font = [UIFont boldSystemFontOfSize:15];
    NSNumber *countMeetings = [NSNumber numberWithInt:[[UserTaste MR_numberOfEntities] intValue] - 1]; // We remove current user
    tableFooter.text = [NSString sentenceCapitalizedString:[NSString stringWithFormat:NSLocalizedString(@"%@ meetings", nil), countMeetings]];
    
    // Uitableview of user selection (what user likes)
    UITableView *userMeetingsListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 47) style:UITableViewStylePlain];
    userMeetingsListTableView.dataSource = self;
    userMeetingsListTableView.delegate = self;
    userMeetingsListTableView.backgroundColor = [UIColor clearColor];
    userMeetingsListTableView.tag = 1;
    userMeetingsListTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    userMeetingsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userMeetingsListTableView.tableHeaderView = segmentedControlView;
    userMeetingsListTableView.contentInset = UIEdgeInsetsMake(0, 0, 18, 0);
    
//    [userMeetingsListTableView scrollToRowAtIndexPath:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];

    [self.view addSubview:userMeetingsListTableView];
    
    // Message for empty list meetings
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Tap on  in a meeting to add it among your favorites", nil)];
    UIImage *lensIcon = [UIImage imageNamed:@"favorite-icon-message-alt"];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = lensIcon;
    textAttachment.bounds = CGRectMake(0, -10, lensIcon.size.width, lensIcon.size.height);
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSRange r = [[attributedString string] rangeOfString:NSLocalizedString(@"Tap on ", nil)];
    [attributedString insertAttributedString:attrStringWithImage atIndex:(r.location + r.length)];
    
    CGFloat emptyUserTasteLabelPosY = 45; // [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:343 forDimension:screenHeight];
    
    UILabel *emptyFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 24, 90)];
    emptyFavoritesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    emptyFavoritesLabel.attributedText = attributedString; //Appuyez {sur l'étoile} pour ajouter aux favoris
    emptyFavoritesLabel.textColor = [UIColor whiteColor];
    emptyFavoritesLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyFavoritesLabel.numberOfLines = 0;
    emptyFavoritesLabel.bounds = CGRectInset(emptyFavoritesLabel.frame, 0.0f, -10.0f);
    emptyFavoritesLabel.textAlignment = NSTextAlignmentCenter;
    emptyFavoritesLabel.tag = 3;
    emptyFavoritesLabel.hidden = YES;
    [userMeetingsListTableView addSubview:emptyFavoritesLabel];
    
    // Message for no meetings /:
    UILabel *emptyMeetingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, emptyUserTasteLabelPosY, screenWidth - 24, 110)];
    emptyMeetingsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyMeetingsLabel.text = NSLocalizedString(@"You haven't met a person yet", nil);
    emptyMeetingsLabel.textColor = [UIColor whiteColor];
    emptyMeetingsLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyMeetingsLabel.numberOfLines = 0;
    emptyMeetingsLabel.textAlignment = NSTextAlignmentCenter;
    emptyMeetingsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emptyMeetingsLabel.backgroundColor = [UIColor clearColor];
    emptyMeetingsLabel.tag = 4;
    emptyMeetingsLabel.hidden = YES;
    [userMeetingsListTableView addSubview:emptyMeetingsLabel];
    
    
    // Message for no fb friends /:
    UIView *emptyFacebookFriendsLabelView = [[UIView alloc] initWithFrame:CGRectMake(0.0, emptyUserTasteLabelPosY, screenWidth - 24, 99.0)];
    emptyFacebookFriendsLabelView.tag = 6;
    emptyFacebookFriendsLabelView.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyFacebookFriendsLabelView.userInteractionEnabled = YES;
    emptyFacebookFriendsLabelView.backgroundColor = [UIColor clearColor];
    [userMeetingsListTableView addSubview:emptyFacebookFriendsLabelView];
    
    UILabel *emptyFacebookFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth - 24, 50)];
    emptyFacebookFriendsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyFacebookFriendsLabel.text = NSLocalizedString(@"no facebook friends", nil);
    emptyFacebookFriendsLabel.textColor = [UIColor whiteColor];
    emptyFacebookFriendsLabel.numberOfLines = 0;
    emptyFacebookFriendsLabel.tag = 8;
    emptyFacebookFriendsLabel.textAlignment = NSTextAlignmentCenter;
    emptyFacebookFriendsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emptyFacebookFriendsLabel.backgroundColor = [UIColor clearColor];
    
    // If the user refuse the user_friends permission we don't show this part
    if (![[FBSession.activeSession permissions] containsObject:@"user_friends"]) {
        emptyFacebookFriendsLabel.hidden = YES;
    } else {
        emptyFacebookFriendsLabel.hidden = NO;
    }
    
    [emptyFacebookFriendsLabelView addSubview:emptyFacebookFriendsLabel];
    
    UIButton *shareShoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareShoundBtn setFrame:CGRectMake(0, 55, emptyFacebookFriendsLabel.frame.size.width, 44)];
    if (![[FBSession.activeSession permissions] containsObject:@"user_friends"]) {
        shareShoundBtn.frame = CGRectMake(0.0, 0.0, screenWidth - 24, 50);
    }
    [shareShoundBtn setTitle:NSLocalizedString(@"Talk about shound", nil) forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor colorWithRed:(1/255) green:(76/255) blue:(119/255) alpha:1.0] forState:UIControlStateSelected];
    [shareShoundBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    shareShoundBtn.highlighted = YES;
    shareShoundBtn.backgroundColor = [UIColor whiteColor];
//    [self.button setBackgroundImage:image forState:UIControlStateHighlighted];
    [shareShoundBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
    [shareShoundBtn addTarget:self action:@selector(shareFb) forControlEvents:UIControlEventTouchUpInside];
    [emptyFacebookFriendsLabelView addSubview:shareShoundBtn];
    
    if (![[FBSession.activeSession permissions] containsObject:@"user_friends"]) {
        UIButton *allowFriendsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [allowFriendsBtn setFrame:CGRectMake(0, shareShoundBtn.frame.origin.y + shareShoundBtn.frame.size.height + 25, emptyFacebookFriendsLabel.frame.size.width, 44)];
        [allowFriendsBtn setTitle:NSLocalizedString(@"authorize fb friends", nil) forState:UIControlStateNormal];
        [allowFriendsBtn setTitleColor:[UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
        [allowFriendsBtn setTitleColor:[UIColor colorWithRed:(1/255) green:(76/255) blue:(119/255) alpha:1.0] forState:UIControlStateSelected];
        [allowFriendsBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
        allowFriendsBtn.highlighted = YES;
        allowFriendsBtn.tag = 7;
        allowFriendsBtn.backgroundColor = [UIColor whiteColor];
        [allowFriendsBtn addTarget:self action:@selector(allowFacebookFriendsPermission) forControlEvents:UIControlEventTouchUpInside];
        [emptyFacebookFriendsLabelView addSubview:allowFriendsBtn];
    }
    
    
    UIView *emptyFacebookFriendsLabelLastView = [emptyFacebookFriendsLabelView.subviews lastObject];
    CGRect frameRect = emptyFacebookFriendsLabelView.frame;
    frameRect.size.height = emptyFacebookFriendsLabelLastView.frame.size.height + emptyFacebookFriendsLabelLastView.frame.origin.y;
    emptyFacebookFriendsLabelView.frame = frameRect;
//    emptyFacebookFriendsLabelView.center = CGPointMake(self.view.center.x, self.view.center.y - 60);

    
    daysList = [[NSMutableArray alloc] initWithArray:[self fetchDatas]];
    
    loadingIndicator = [UIActivityIndicatorView new];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.view addSubview:loadingIndicator];
    
    
    UserTaste *currentUser = [UserTaste MR_findFirstByAttribute:@"fbid"
                             withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    currentUserTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUser taste]] mutableCopy];
    

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
    [self.navigationController pushViewController:detailsMeetingViewController animated:NO];
}

// This function manage the enable state of refresh button
- (void) navigationItemRightButtonEnablingManagement
{
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchUsersDatas)];
    self.navigationItem.rightBarButtonItem = refreshBtn;

    if ([userPreferences objectForKey:@"lastManualUpdate"]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *lastDataFetchingInterval = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[userPreferences objectForKey:@"lastManualUpdate"] toDate:[NSDate date] options:0];
        
        NSInteger hours = [lastDataFetchingInterval hour];
        NSInteger minutes = [lastDataFetchingInterval minute];
        NSInteger seconds = [lastDataFetchingInterval second];

        // If the meeting have been made less than one hour ago we do nothing
        NSInteger delayLastMeetingUser = (hours * 60 * 60) + (minutes * 60) + seconds;
        if (delayLastMeetingUser > BGFETCHDELAY) { //BGFETCHDELAY
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (NSArray*) fetchDatas
{
    
    // Fetching datas
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbid != %@",
                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    
    NSPredicate *favoritesMeetingsFilter = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    NSPredicate *facebookFriendsFilter = [NSPredicate predicateWithFormat:@"fbid IN %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] ];
    
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
    
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:filterPredicates]; // Order by date of meeting

    NSMutableArray *listOfDistinctDays = [NSMutableArray new];
    NSMutableArray *foo = [NSMutableArray new];
    
    //    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    int i = 0;
    int fetchLimit = 42; // We display only the 42 last results
    
//    NSMutableArray *uniqueDateTimes = [[NSMutableArray alloc] initWithCapacity:fetchLimit];
//    uniqueDateTimes = [meetings valueForKeyPath:@"@distinctUnionOfObjects.lastMeeting.dateWithoutTime"];
//    NSLog(@"uniqueDateTimes : %@", uniqueDateTimes);
    
    for (UserTaste *userTaste in meetings) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        if ([userTaste lastMeeting] != nil) {
            NSString *dateString = [[dateFormatter stringFromDate:[userTaste lastMeeting]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (i < fetchLimit) {
                [listOfDistinctDays addObject: dateString];
                [foo addObject:[userTaste lastMeeting]];
            }
        }
        
        i++;
    }
    
    [listOfDistinctDays sortedArrayUsingSelector:@selector(compare:)]; // sortUsingDescriptors [NSArray arrayWithObject:sortDescriptor]
    distinctDays = [[NSArray alloc] initWithArray:[[NSOrderedSet orderedSetWithArray:listOfDistinctDays] array]];

    return [[foo reverseObjectEnumerator] allObjects];
}

- (void) appEnteredBackground
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void) diplayFavoritesMeetings:(id)sender
{
    [self reloadTableview];
}

- (void) reloadTableview
{
    [loadingIndicator startAnimating];
    daysList = [[NSMutableArray alloc] initWithArray:[self fetchDatas]];
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    [userMeetingsListTableView reloadData];
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
    UIView *segmentedControlView = (UIView*)[self.view viewWithTag:2];
    segmentedControlView.hidden = NO;
    
    // Vous n'avez pas rencontré de personnes
    UILabel *emptyMeetingsLabel = (UILabel*)[tableView viewWithTag:4];
    emptyMeetingsLabel.hidden = YES;
    
    // Vous n'avez pas de favoris user
    UILabel *emptyFavoritesLabel = (UILabel*)[tableView viewWithTag:3];
    emptyFavoritesLabel.hidden = YES;
    
    // Vous avez pas d'amis facebook sur Shound
    UIView *emptyFacebookFriendsLabelView = (UIView*)[tableView viewWithTag:6];
    emptyFacebookFriendsLabelView.hidden = YES;
    
    
    UILabel *emptyFacebookFriendsLabel = (UILabel*)[emptyFacebookFriendsLabelView viewWithTag:8];
    emptyFacebookFriendsLabel.hidden = YES;
    
    // User have made no meetings
    if ([distinctDays count] == 0) {
        // We hide the segmented control on page load
        // only if there is nothing among ALL meetings
        // so user can have no favorites but he still has the segmentedControl
        
        UISegmentedControl *segmentedControl = (UISegmentedControl*)[self.view viewWithTag:5];
        switch (segmentedControl.selectedSegmentIndex) {
            // Filter disabled
            case 0:
            {
                emptyMeetingsLabel.hidden = NO;
            }
                break;
            
            // Favorites
            case 1:
            {
                emptyFavoritesLabel.hidden = NO;
                UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
                userMeetingsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            }
                break;
                
            case 2:
            {
                emptyFacebookFriendsLabelView.hidden = NO;
                if (![[FBSession.activeSession permissions] containsObject:@"user_friends"]) {
                    emptyFacebookFriendsLabel.hidden = YES;
                } else {
                    emptyFacebookFriendsLabel.hidden = NO;
                }
                UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
                userMeetingsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            }
                break;
            default:
                break;
        }
        
//        if (!self.FilterEnabled) {
//            segmentedControlView.hidden = YES;
//            emptyMeetingsLabel.hidden = NO;
//        } else {
//            emptyFavoritesLabel.hidden = NO;
//            UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
//            userMeetingsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//        }
        [loadingIndicator stopAnimating];
    }

    return [distinctDays count];
}

// Title of categories
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 18.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 69.0)];
    headerView.opaque = YES;
    headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.9f];
    
    NSString *title = [distinctDays objectAtIndex:section];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 69.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    label.textColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:1];
    

    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69.0;
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
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbid != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];

    
    NSPredicate *favoritesMeetingsFilter = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    NSPredicate *facebookFriendsFilter = [NSPredicate predicateWithFormat:@"fbid IN %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"]];
    
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
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:filterPredicates];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];

    NSDate *currentDate = [NSDate new];
    currentDate = [dateFormatter dateFromString:[distinctDays objectAtIndex:section]];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsForFirstDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[dateFormatter dateFromString:[distinctDays objectAtIndex:section]]];
    
    int j = 0;
    for (int i = 0; i < [meetings count]; i++) {
        if ([[meetings objectAtIndex:i] lastMeeting] != nil) {
            NSDateComponents *componentsForSecondDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[[meetings objectAtIndex:i] lastMeeting]];
            
            if (([componentsForFirstDate year] == [componentsForSecondDate year]) && ([componentsForFirstDate month] == [componentsForSecondDate month]) && ([componentsForFirstDate day] == [componentsForSecondDate day])) {
                j++;
            }
        }
        
    }
    
    return j;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    ShareListMediaTableViewCell *selectedCell = (ShareListMediaTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    DetailsMeetingViewController *detailsMeetingViewController = [DetailsMeetingViewController new];
    detailsMeetingViewController.metUserId = selectedCell.model;
    detailsMeetingViewController.delegate = self;
   
    [self.navigationController pushViewController:detailsMeetingViewController animated:YES];
}

- (void) meetingsListHaveBeenUpdate
{
//    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted || [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
//        return;
//    }

    daysList = [[NSMutableArray alloc] initWithArray:[self fetchDatas]];
    // We update the view behind the user like this when he comes back the view is updated
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:1];
    [userSelectionTableView reloadData];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    
    ShareListMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDate *currentDate = [NSDate new];
    currentDate = [dateFormatter dateFromString:[distinctDays objectAtIndex:indexPath.section]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsForFirstDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
    // Contains all meetings of the day
    NSMutableArray *meetingsOfDay = [NSMutableArray new];
    for (int i = 0; i < [daysList count]; i++) {
        
        NSDateComponents *componentsForSecondDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[daysList objectAtIndex:i] ];
        
        if (([componentsForFirstDate year] == [componentsForSecondDate year]) && ([componentsForFirstDate month] == [componentsForSecondDate month]) && ([componentsForFirstDate day] == [componentsForSecondDate day])) {
            [meetingsOfDay addObject:[daysList objectAtIndex:i]];
        }
    }


    // Calc of the stats
    UserTaste *currentUserMet = [UserTaste MR_findFirstByAttribute:@"lastMeeting"
                                                         withValue:[[meetingsOfDay reversedArray] objectAtIndex:indexPath.row]];
    
    NSDictionary *currentUserMetTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUserMet taste]] mutableCopy];
    

    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
    int commonTasteCount = 0;
    int currentUserNumberItems = 0;
    for (int i = 0; i < [[currentUserMetTaste filterKeysForNullObj] count]; i++) {
        NSString *key = [[currentUserMetTaste filterKeysForNullObj] objectAtIndex:i];
        if (![[currentUserTaste objectForKey:key] isEqual:[NSNull null]]) {
            currentUserTasteSet = [NSMutableSet setWithArray:[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"]];
            
            currentUserNumberItems += [[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"] count];
        }
        
        if (![[currentUserMetTaste objectForKey:key] isEqual:[NSNull null]]) {
            currentUserMetTasteSet = [NSMutableSet setWithArray:[[currentUserMetTaste objectForKey:key] valueForKey:@"imdbID"]];
        }
        
        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the obejcts that are in both sets
        
        NSArray* result = [currentUserMetTasteSet allObjects];
        
        commonTasteCount += result.count;
    }
    
    NSString *textLabelString = @"";
    
    CGFloat commonTasteCountPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
    if (isnan(commonTasteCountPercent)) {
        commonTasteCountPercent = 0.0f;
    }
    
    // If the user has only 1% in common
    if (commonTasteCountPercent == (float)1) {
        commonTasteCountPercent = 0.01;
    }
    
    if (commonTasteCount == 0) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:(228.0/255.0) green:(207.0/255.0) blue:(186.0/255.0) alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:(228.0/255.0) green:(207.0/255.0) blue:(186.0/255.0) alpha:1.0];
        textLabelString = NSLocalizedString(@"nothing common", nil);
    } else {
        NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
        [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        NSString *strNumber = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:commonTasteCountPercent]];
        
        textLabelString = [NSString stringWithFormat:NSLocalizedString(@"%@ in common", nil), strNumber];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    

    NSDateFormatter *cellDateFormatter = [NSDateFormatter new];
    cellDateFormatter.timeStyle = kCFDateFormatterShortStyle; // HH:MM:SS
  
    cell.textLabel.text = textLabelString;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];

    cell.model = [currentUserMet fbid];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.indentationLevel = 1;
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [cellDateFormatter stringFromDate:[[meetingsOfDay reversedArray] objectAtIndex:indexPath.row]]]; //[[NSNumber numberWithInteger:commonTasteCount] stringValue];
    
    cell.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"favsIDUpdatedList"] containsObject:[currentUserMet fbid]]) {
        NSString *indicateFavUpdatedString = @" - ";
        indicateFavUpdatedString = [indicateFavUpdatedString stringByAppendingString:NSLocalizedString(@"updated", nil)];
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:indicateFavUpdatedString];
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    }
    
    // If the user is a facebook friend so we display his facebook profile image
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[[currentUserMet fbid] stringValue]]) {
        [self getImageCellForData:[[currentUserMet fbid] stringValue] aCell:cell];
        
        cell.imageView.image = [MeetingsListViewController imageFromFacebookFriendInitialForId:[currentUserMet fbid] forDarkBG:NO];
        cell.imageView.highlightedImage = [MeetingsListViewController imageFromFacebookFriendInitialForId:[currentUserMet fbid] forDarkBG:YES];
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.imageView.opaque = YES;
        
        cell.imageView.tag = indexPath.row;
    } else {
        cell.backgroundView = nil;
        cell.imageView.image = nil;
    }

    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.9f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

+ (UIImage *) imageFromFacebookFriendInitialForId:(NSNumber*) fbid forDarkBG:(BOOL)isDarkBG
{
    NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [fbid stringValue]]];
    NSString *firstNameFirstLetter = [[[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""] substringToIndex:1];
    NSString *lastNameFirstLetter = [[[facebookFriendDatas valueForKey:@"last_name"] componentsJoinedByString:@""] substringToIndex:1];
    
    UILabel *initialPatronymFacebookFriendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    initialPatronymFacebookFriendLabel.text = [firstNameFirstLetter stringByAppendingString:lastNameFirstLetter];
    initialPatronymFacebookFriendLabel.textAlignment = NSTextAlignmentCenter;
    initialPatronymFacebookFriendLabel.backgroundColor =  (isDarkBG) ? [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0] : [UIColor whiteColor];
    initialPatronymFacebookFriendLabel.textColor = (isDarkBG) ? [UIColor whiteColor] : [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:1.0];
    initialPatronymFacebookFriendLabel.clipsToBounds = YES;
    initialPatronymFacebookFriendLabel.layer.cornerRadius = 20.0f;

    return [MeetingsListViewController imageWithView:initialPatronymFacebookFriendLabel];
}


+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Called when the last cell is displayed
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
      [loadingIndicator stopAnimating];
    }
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


#pragma mark - Fetch Datas in background

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastManualUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQuery] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
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

- (void) fetchUsersDatas
{
    if ([self connected] == NO) {
        [self noInternetAlert];
        return;
    }
    
    [loadingIndicator startAnimating];
    
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    [userMeetingsListTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQuery] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [loadingIndicator stopAnimating];
            [self noInternetAlert];
        } else {
            [userPreferences setObject:[NSDate date] forKey:@"lastManualUpdate"];
            [self saveRandomUserDatas:data];
        }
    }];
}


- (NSMutableURLRequest*) fetchUsersDatasQuery
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    NSURL *aUrl = [NSURL URLWithString:[[settingsDict objectForKey:@"apiPath"] stringByAppendingString:@"getusertaste.php"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    
    NSInteger currentUserfbID = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentUserfbID"];
    
    NSString *postString = [NSString stringWithFormat:@"fbiduser=%li&geolocenabled=%@", (long)currentUserfbID, [[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] ? @"YES" : @"NO"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
    ) {
        
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
    
    // If user is accepts geoloc we update his location BEFORE fetch new users
    // That's way the meeting is more relevant
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] == YES) {
        
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"&latitude=%f&longitude=%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude]];
    }
    
    [[[UIAlertView alloc] initWithTitle:@"foof" message:[NSString stringWithFormat:@"&latitude=%f&longitude=%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude] delegate:nil cancelButtonTitle:@"Gentoo" otherButtonTitles: nil] show];
//    [self.locationManager stopUpdatingLocation];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    
//    self.locationManager.location.coordinate.latitude = currentLocation.coordinate.latitude;
//    self.locationManager.location.coordinate.latitude = currentLocation.coordinate.latitude;
}

- (void) saveRandomUserDatas:(NSData *)datas
{
    NSString *responseString = [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    // datas from random user "met"
    NSMutableDictionary *randomUserDatas = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    // No datas retrieve from server
    // Maybe for geoloc
    if (randomUserDatas == nil) {
        NSInteger numberOfNoResults = [[NSUserDefaults standardUserDefaults] integerForKey:@"noresultsgeoloc"];
        
        // User have fetch 5 times empty json (no data so)
        // A Notification is displayed to indicate user to talk about the app
        // Thx Carlos
        if (numberOfNoResults >= 5) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"noresultsgeoloc"];
            numberOfNoResults = 0;
            
            UILocalNotification *localNotif = [UILocalNotification new];
            localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval: 300];
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.alertBody = NSLocalizedString(@"nomeetings", nil);
            localNotif.soundName = nil;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        } else {
            numberOfNoResults += 1;
            [[NSUserDefaults standardUserDefaults] setInteger:numberOfNoResults forKey:@"noresultsgeoloc"];
            
           if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
               UIAlertView *noNewDatasAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No results", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
               [noNewDatasAlert show];
            }
        }
        [loadingIndicator stopAnimating];
        return;
    }
    
    NSNumberFormatter *formatNumber = [[NSNumberFormatter alloc] init];
    [formatNumber setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *randomUserfbID = [formatNumber numberFromString:[randomUserDatas objectForKey:@"fbiduser"]];
    
    
    // this var contains string raw of user taste. It should be converted to a NSDictionnary
    NSData *stringData = [[randomUserDatas objectForKey:@"user_favs"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *randomUserTaste = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
    
    // The server send bad json
    if([NSJSONSerialization JSONObjectWithData:stringData options:kNilOptions error:nil] == nil) {
        // We try to get new meeting from server with good json
        if (numberOfJSONErrors > 2) {
            UIAlertView *numberOfJSONErrorsMaxReachedAlert = [[UIAlertView alloc] initWithTitle:@"Oops" message:NSLocalizedString(@"numberOfJSONErrorsMaxReached", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [numberOfJSONErrorsMaxReachedAlert show];
            numberOfJSONErrors = 0;
            [loadingIndicator stopAnimating];
            return;
        }
       [self fetchUsersDatas];
        numberOfJSONErrors++;
        return;
    }
    
    // The user's data is transform to nsdata to be putable in a CoreData model
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:randomUserTaste];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", randomUserfbID];
    UserTaste *oldUserTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    NSNumber *oldUserCount = [UserTaste MR_numberOfEntitiesWithPredicate:userPredicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];

    // If user exists we just update his value like streetpass in 3ds
    if (oldUserCount != 0 && randomUserfbID != nil && oldUserTaste != nil) {

        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *conversionInfo = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[oldUserTaste lastMeeting] toDate:[NSDate date] options:0];
        
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
        
        oldUserTaste.taste = arrayData;
        oldUserTaste.fbid = randomUserfbID;
        oldUserTaste.lastMeeting = [NSDate date];
        oldUserTaste.numberOfMeetings = [NSNumber numberWithInt:[oldUserTaste.numberOfMeetings intValue] + 1];
    } else {
        // It's a new user
        // So we create a entity in CD for him
        UserTaste *userTaste = [UserTaste MR_createEntity];
        userTaste.taste = arrayData;
        userTaste.fbid = randomUserfbID;
        userTaste.lastMeeting = [NSDate date];
        userTaste.isFavorite = NO;
        userTaste.numberOfMeetings = [NSNumber numberWithInt:1];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

    // We set to 0 the count of no results fetch location
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"noresultsgeoloc"];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] && [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedAlways
        ) {
        [self.locationManager stopUpdatingLocation];
    }
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self performSelectorOnMainThread:@selector(reloadTableview) withObject:nil waitUntilDone:YES];
    } else {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    }
    
    
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

- (void) allowFacebookFriendsPermission
{
    [FBSession.activeSession requestNewPublishPermissions:@[@"user_friends"]
                                          defaultAudience:FBSessionDefaultAudienceNone
                                        completionHandler:^(FBSession *session, NSError *error){
                                            UIButton *allowFriendsBtn = (UIButton*)[self.view viewWithTag:7];
                                            allowFriendsBtn.hidden = YES;
                                            
//                                            UILabel *emptyFacebookFriendsLabel = (UILabel*)[self.view viewWithTag:8];
//                                            emptyFacebookFriendsLabel.hidden = NO;
                                        }];
}

- (void) shareFb
{
    FBLinkShareParams *params = [FBLinkShareParams new];
    params.link = [NSURL URLWithString:@"https://appsto.re/us/sYAB4.i"];
    params.name = NSLocalizedString(@"FBLinkShareParams_name", nil);
    params.caption = NSLocalizedString(@"FBLinkShareParams_caption", nil);
    params.picture = [NSURL URLWithString:@"http://shound.fr/shound_logo_fb.jpg"];

    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:nil
                                  description:NSLocalizedString(@"FBLinkShareParams_caption", nil)
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


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
