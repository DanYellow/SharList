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
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [[self navigationController] tabBarItem].badgeValue = nil;
    
    if (!FBSession.activeSession.isOpen) {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Reset the badge notification number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[self navigationController] tabBarItem].badgeValue = nil;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
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
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(canIGetRandomUser)];
    
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

    [self.view addSubview:userMeetingsListTableView];
    
    // Message for empty list taste
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Tap on  in a meeting to add it among your favorites", nil)];
    UIImage *lensIcon = [UIImage imageNamed:@"favorite-icon-message-alt"];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = lensIcon;
    textAttachment.bounds = CGRectMake(0, -10, lensIcon.size.width, lensIcon.size.height);
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSRange r = [[attributedString string] rangeOfString:NSLocalizedString(@"Tap on  ", nil)];
    [attributedString insertAttributedString:attrStringWithImage atIndex:(r.location + r.length)];
    
    CGFloat emptyUserTasteLabelPosY = 45; // [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:343 forDimension:screenHeight];
    
    UILabel *emptyFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
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
    UILabel *emptyMeetingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyUserTasteLabelPosY, screenWidth, 90)];
    emptyMeetingsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyMeetingsLabel.text = NSLocalizedString(@"You haven't met a person yet", nil);
    emptyMeetingsLabel.textColor = [UIColor whiteColor];
    emptyMeetingsLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyMeetingsLabel.numberOfLines = 0;
    emptyMeetingsLabel.textAlignment = NSTextAlignmentCenter;
    emptyMeetingsLabel.tag = 4;
    emptyMeetingsLabel.hidden = YES;
    emptyMeetingsLabel.bounds = CGRectInset(emptyFavoritesLabel.frame, 0.0f, 20.0f);
    [userMeetingsListTableView addSubview:emptyMeetingsLabel];
    
    
    daysList = [[NSMutableArray alloc] initWithArray:[self fetchDatas]];//[[NSMutableArray alloc] initWithArray:[[foo reverseObjectEnumerator] allObjects]]; //foo
    
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [loadingIndicator startAnimating];
    [self.view addSubview:loadingIndicator];
    

    // This method is called when user quit the app
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appEnteredBackground) name: @"didEnterBackground" object: nil];
    // This method is called when user go back to app
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(meetingsListHaveBeenUpdate) name: @"didEnterForeground" object: nil];
    
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"]) {
//        
//    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    theLastLocation = [locations lastObject];
}

- (NSArray*) fetchDatas
{
    // Fetching datas
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbid != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]]
;

    NSPredicate *favoritesMeetingsFilter = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    
    NSCompoundPredicate *filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter]];
    if (self.isFilterEnabled) {
        filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter, favoritesMeetingsFilter]];
    }
    
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:filterPredicates]; // Order by date of meeting
    
    NSMutableArray *listOfDistinctDays = [NSMutableArray new];
    NSMutableArray *foo = [NSMutableArray new];
    
    //    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    for (UserTaste *userTaste in meetings) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
//        NSDateFormatter *dateFormatter = [NSDateFormatter new];
//        dateFormatter.dateFormat = @"MM/dd/yy";
        
        NSString *dateString = [dateFormatter stringFromDate:[userTaste lastMeeting]];
        
        if (dateString != nil) {
            [listOfDistinctDays addObject: dateString];
            [foo addObject:[userTaste lastMeeting]];
        }
        
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
    
    daysList = [[NSMutableArray alloc] initWithArray:[self fetchDatas]];
    UITableView *userMeetingsListTableView = (UITableView*)[self.view viewWithTag:1];
    [userMeetingsListTableView reloadData];
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
            [loadingIndicator stopAnimating];
        } else {
            emptyFavoritesLabel.hidden = NO;
        }
    }
//    NSLog(@"title : %@, %li", distinctDays, [distinctDays count]);
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
    
    NSCompoundPredicate *filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter]];
    if (self.isFilterEnabled) {
        filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter, favoritesMeetingsFilter]];
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
        NSDateComponents *componentsForSecondDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[[meetings objectAtIndex:i] lastMeeting]];
        
        if (([componentsForFirstDate year] == [componentsForSecondDate year]) && ([componentsForFirstDate month] == [componentsForSecondDate month]) && ([componentsForFirstDate day] == [componentsForSecondDate day])) {
            j++;
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
    formatter.timeStyle = kCFDateFormatterShortStyle;
    detailsMeetingViewController.title = [formatter stringFromDate:[selectedCell.model lastMeeting]];
    
    [self.navigationController pushViewController:detailsMeetingViewController animated:YES];
}

- (void) meetingsListHaveBeenUpdate
{
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
    
    UserTaste *currentUserTaste = [UserTaste MR_findFirstByAttribute:@"lastMeeting"
                                                           withValue:[meetingsOfDay objectAtIndex:(([meetingsOfDay count] - indexPath.row) - 1)]];
    
    NSDateFormatter *cellDateFormatter = [NSDateFormatter new];
    cellDateFormatter.timeStyle = kCFDateFormatterShortStyle; // HH:MM:SS
  
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Met at %@", nil), [cellDateFormatter stringFromDate:[meetingsOfDay objectAtIndex:(([meetingsOfDay count] - indexPath.row) - 1)]]];
    cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.model = currentUserTaste;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.indentationLevel = 1;

    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.9f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [loadingIndicator stopAnimating];
    }
}


#pragma mark - Fetch Datas in background

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{    
    NSURL *aUrl= [NSURL URLWithString:@"http://192.168.1.55:8888/Share/getusertaste.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    NSInteger randomUserFacebookID = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentUserfbID"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        //      self.locationManager.purpose = @"Location needed to show zombies that are nearby.";
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
    
    NSString *postString = [NSString stringWithFormat:@"fbiduser=%li&geolocenabled=%@", (long)randomUserFacebookID, [[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] ? @"YES" : @"NO"];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"]) {
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"latitude=%f&longitude=%f", theLastLocation.coordinate.latitude, theLastLocation.coordinate.longitude]];
    }
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
            NSLog(@"%@", error);
        } else {
            [self saveRandomUserDatas:data];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
    
//    completionHandler(UIBackgroundFetchResultNewData);
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
        // An Notification is displayed to indicate user to talk about the app
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
        }
        
        return;
    }
    
    NSNumberFormatter *formatNumber = [[NSNumberFormatter alloc] init];
    [formatNumber setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *randomUserfbID = [formatNumber numberFromString:[randomUserDatas objectForKey:@"fbiduser"]];
    
    
    // this var contains string raw of user taste. It should be converted to a NSDictionnary
    NSData *stringData = [[randomUserDatas objectForKey:@"user_favs"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *randomUserTaste = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:randomUserTaste];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", randomUserfbID];
    UserTaste *oldUserTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    

    // If user exists we just update his value like streetpass in 3ds
    if (oldUserTaste != nil) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *conversionInfo = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[oldUserTaste lastMeeting] toDate:[NSDate date] options:0];
        
//        NSInteger days = [conversionInfo day];
        NSInteger hours = [conversionInfo hour];
//        NSInteger minutes = [conversionInfo minute];
        
        
        // If the meeting have been made less than one hour ago we do nothing
        if ((long)hours < 1) {
            NSLog(@"Does nothing");
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


    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    [self.locationManager stopUpdatingLocation];
}




- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
