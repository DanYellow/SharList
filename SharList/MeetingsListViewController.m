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
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All", nil), NSLocalizedString(@"Favorites", nil)]];
    
    segmentedControl.frame = CGRectMake(10, 5, screenWidth - 20, 30);
    [segmentedControl addTarget:self action:@selector(diplayFavoritesMeetings:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
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
    
    // Message for empty list taste
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
    
    // Message for no friends /:
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
//    [emptyMeetingsLabel sizeToFit];
//    emptyMeetingsLabel.bounds = CGRectInset(emptyFavoritesLabel.frame, 0.0f, 20.0f);
    [userMeetingsListTableView addSubview:emptyMeetingsLabel];
    
    
    daysList = [[NSMutableArray alloc] initWithArray:[self fetchDatas]];//[[NSMutableArray alloc] initWithArray:[[foo reverseObjectEnumerator] allObjects]]; //foo
    
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [loadingIndicator startAnimating];
    [self.view addSubview:loadingIndicator];
    
    
    UserTaste *currentUser = [UserTaste MR_findFirstByAttribute:@"fbid"
                             withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    currentUserTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUser taste]] mutableCopy];
    

    // This method is called when user quit the app
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appEnteredBackground) name: @"didEnterBackground" object: nil];
    // This method is called when user go back to app
    // User not enable bgfetch
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(navigationItemRightButtonEnablingManagement) name: @"didEnterForeground" object: nil];
    // User enable bgfetch
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(meetingsListHaveBeenUpdate) name: @"didEnterForeground" object: nil];
    
}

// This function manage the enable state of refresh button
- (void) navigationItemRightButtonEnablingManagement
{
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchUsersDatasBtnAction)];
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
    
    NSCompoundPredicate *filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter]];
    if (self.isFilterEnabled) {
        filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter, favoritesMeetingsFilter]];
    }

    
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:filterPredicates]; // Order by date of meeting
    
    NSMutableArray *listOfDistinctDays = [NSMutableArray new];
    NSMutableArray *foo = [NSMutableArray new];
    
    //    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    int i = 0;
    int fetchLimit = 42; // We display only the 42 last results
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
    self.FilterEnabled = !self.FilterEnabled;
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
    
    // Vous n'avez pas rencontré de favoris user
    UILabel *emptyFavoritesLabel = (UILabel*)[tableView viewWithTag:3];
    emptyFavoritesLabel.hidden = YES;
    
    // User have made no meetings
    if ([distinctDays count] == 0) {
        //We hide the segmented control on page load
        // only if there is nothing among ALL meetings
        // so user can have no favorites but he still has the segmentedControl
        if (!self.FilterEnabled) {
            segmentedControlView.hidden = YES;
            emptyMeetingsLabel.hidden = NO;
        } else {
            emptyFavoritesLabel.hidden = NO;
            UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
            userMeetingsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
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
    
    NSCompoundPredicate *filterPredicates;
    if (self.isFilterEnabled) {
        filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter, favoritesMeetingsFilter]];
    } else {
        filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter]];
    }

    // We don't want the taste of the current user
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:filterPredicates];
//    UILabel *emptyFavoritesLabel = (UILabel*)[tableView viewWithTag:3];
//    if ([meetings count] == 0) {
//        emptyFavoritesLabel.hidden = NO;
//        return 0;
//    } else {
//        emptyFavoritesLabel.hidden = YES;
//    }
    
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
    detailsMeetingViewController.meetingDatas = selectedCell.model;
    detailsMeetingViewController.delegate = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = kCFDateFormatterShortStyle; //self.meetingDatas[@"userModel"]
    detailsMeetingViewController.title = [formatter stringFromDate:[selectedCell.model[@"userModel"] lastMeeting]];
   
    [self.navigationController pushViewController:detailsMeetingViewController animated:YES];
}

- (void) meetingsListHaveBeenUpdate
{
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted || [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        return;
    }

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

    UserTaste *currentUserMet = [UserTaste MR_findFirstByAttribute:@"lastMeeting"
                                                           withValue:[[meetingsOfDay reversedArray] objectAtIndex:indexPath.row]];
    
    NSDictionary *currentUserMetTaste = [[NSKeyedUnarchiver unarchiveObjectWithData:[currentUserMet taste]] mutableCopy];
    

    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
    int commonTasteCount = 0;
    int currentUserNumberItems = 0;
    for (NSString* key in @[@"serie", @"movie"]) {
        if ([currentUserTaste objectForKey:key] != nil && [currentUserTaste objectForKey:key] != (id)[NSNull null]) {
            currentUserTasteSet = [NSMutableSet setWithArray:[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"]];
            
            currentUserNumberItems += [[[currentUserTaste objectForKey:key] valueForKey:@"imdbID"] count];
        }
        
        if ([currentUserMetTaste objectForKey:key] != nil && [currentUserMetTaste objectForKey:key] != (id)[NSNull null]) {
            currentUserMetTasteSet = [NSMutableSet setWithArray:[[currentUserMetTaste objectForKey:key] valueForKey:@"imdbID"]];
        }
        
        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the obejcts that are in both sets
        
        NSArray* result = [currentUserMetTasteSet allObjects];
        
        commonTasteCount += result.count;
    }
    
    NSString *detailTextLabelString = @"";
    
    CGFloat commonTasteCountPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
//    NSLog(@"commonTasteCountPercent : %i", commonTasteCountPercent);
    if (commonTasteCount == 0) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:(228.0/255.0) green:(207.0/255.0) blue:(186.0/255.0) alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:(228.0/255.0) green:(207.0/255.0) blue:(186.0/255.0) alpha:1.0];
        detailTextLabelString = NSLocalizedString(@"nothing common", nil);
    } else {
        NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
        [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        NSString *strNumber = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:commonTasteCountPercent]];
        
        detailTextLabelString = [NSString stringWithFormat:NSLocalizedString(@"%@ in common", nil), strNumber];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    
    NSDateFormatter *cellDateFormatter = [NSDateFormatter new];
    cellDateFormatter.timeStyle = kCFDateFormatterShortStyle; // HH:MM:SS
  
    cell.textLabel.text = detailTextLabelString;
    cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];
    
    NSDictionary *userMetDatas = @{@"userModel" : currentUserMet, @"commonTasteCountPercent" : [NSNumber numberWithFloat:commonTasteCountPercent]};
    
    cell.model = userMetDatas;
//    [cell.model setObject:[NSNumber numberWithFloat:commonTasteCountPercent] forKey:@"commonTasteCountPercent"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.indentationLevel = 1;
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [cellDateFormatter stringFromDate:[[meetingsOfDay reversedArray] objectAtIndex:indexPath.row]]];; //[[NSNumber numberWithInteger:commonTasteCount] stringValue];
    
    

    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.9f]];
    [cell setSelectedBackgroundView:bgColorView];
    
//    cell.alpha = .3;
//    [UIView transitionWithView:cell
//                      duration:.5f
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{cell.alpha = 1;}
//                    completion:NULL];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.alpha = 0;
//    [UIView animateWithDuration: 0.1
//                          delay: 0.0
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         cell.alpha = 1;
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];

    
    // Called when the last cell is displayed
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
      [loadingIndicator stopAnimating];
    }
}


#pragma mark - Fetch Datas in background

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastManualUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQuery] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
        } else {
            [self saveRandomUserDatas:data];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
    
//    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL) connected {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (void) fetchUsersDatasBtnAction
{
    if ([self connected] == NO) {
        [self noInternetAlert];
        return;
    }
    
    [loadingIndicator startAnimating];
    
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    [userMeetingsListTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [NSURLConnection sendAsynchronousRequest:[self fetchUsersDatasQuery] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [loadingIndicator stopAnimating];
            [self noInternetAlert];
        } else {
            [userPreferences setObject:[NSDate date] forKey:@"lastManualUpdate"];
            [self saveRandomUserDatas:data];
        }
    }];
}

- (void) noInternetAlert
{
    UIAlertView *errConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"noconnection", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errConnectionAlertView show];
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
//            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
        
        self.locationManager.distanceFilter = 1000;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    // If user is accepts geoloc we update his location BEFORE fetch new users
    // That's way the meeting is more relevant
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] == YES) {
        
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"&latitude=%f&longitude=%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"foo" message:[NSString stringWithFormat:@"latitude=%f | longitude=%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    

//    [self.locationManager stopUpdatingLocation];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    CLLocation *currentLocation = [locations lastObject];
//    
//    
////    self.locationManager.location.coordinate.latitude = currentLocation.coordinate.latitude;
//}

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
            
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            
            localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval: 60];
            
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
       [self fetchUsersDatasBtnAction];
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
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
