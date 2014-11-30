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
    
    if (!FBSession.activeSession.isOpen) {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getRandomUserDatas];
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    self.FilterEnabled = NO;
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];

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
    
    
    UIView *segmentedControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    segmentedControlView.backgroundColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:.9f];
    segmentedControlView.opaque = NO;
    segmentedControlView.tag = 2;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Favorites"]];
    
    segmentedControl.frame = CGRectMake(10, 5, screenWidth - 20, 30);
    [segmentedControl addTarget:self action:@selector(diplayFavoritesMeetings:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor whiteColor];
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Appuyez sur   dans une rencontre pour l'ajouter aux favoris"];
    UIImage *lensIcon = [UIImage imageNamed:@"favorite-icon-message-alt"];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = lensIcon;
    textAttachment.bounds = CGRectMake(0, -10, lensIcon.size.width, lensIcon.size.height);
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSRange r = [[attributedString string] rangeOfString:@"Appuyez sur  "];
    [attributedString insertAttributedString:attrStringWithImage atIndex:(r.location + r.length)];
    
    CGFloat emptyUserTasteLabelPosY = 45; // [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:343 forDimension:screenHeight];
    
    UILabel *emptyFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyUserTasteLabelPosY, screenWidth, 90)];
    emptyFavoritesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    emptyFavoritesLabel.attributedText = attributedString; //Appuyez {sur la loupe} pour rechercher
    emptyFavoritesLabel.textColor = [UIColor whiteColor];
    emptyFavoritesLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyFavoritesLabel.numberOfLines = 0;
    emptyFavoritesLabel.textAlignment = NSTextAlignmentCenter;
    emptyFavoritesLabel.tag = 3;
    emptyFavoritesLabel.hidden = YES;
    [userMeetingsListTableView addSubview:emptyFavoritesLabel];
    
    
    UILabel *emptyMeetingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyUserTasteLabelPosY, screenWidth, 90)];
    emptyMeetingsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    emptyMeetingsLabel.text = @"Vous n'avez pas encore rencontré de personnes.";
    emptyMeetingsLabel.textColor = [UIColor whiteColor];
    emptyMeetingsLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    emptyMeetingsLabel.numberOfLines = 0;
    emptyMeetingsLabel.textAlignment = NSTextAlignmentCenter;
    emptyMeetingsLabel.tag = 4;
    emptyMeetingsLabel.hidden = YES;
    [userMeetingsListTableView addSubview:emptyMeetingsLabel];
    
    
    // Fetching datas
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbid != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserID"]];
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:meetingsFilter]; // Order by date of meeting
    NSMutableArray *listOfDistinctDays = [NSMutableArray new];
    NSMutableArray *foo = [NSMutableArray new];
    
//    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSLog(@"user language: %@", language);
    for (UserTaste *userTaste in meetings) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        dateFormatter.dateFormat = @"MM/dd/yy";
        NSString *dateString = [dateFormatter stringFromDate: [userTaste lastMeeting]];

        [listOfDistinctDays addObject: dateString];
        [foo addObject:[userTaste lastMeeting]];
    }
    
    [listOfDistinctDays sortedArrayUsingSelector:@selector(compare:)]; // sortUsingDescriptors [NSArray arrayWithObject:sortDescriptor]

    daysList = [[NSMutableArray alloc] initWithArray:[[foo reverseObjectEnumerator] allObjects]]; //foo
    distinctDays = [[NSArray alloc] initWithArray:[[NSOrderedSet orderedSetWithArray:listOfDistinctDays] array]];
}

- (void) diplayFavoritesMeetings:(id)sender
{
    self.FilterEnabled = !self.FilterEnabled;
    
    UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
    [tableView reloadData];
}

#pragma mark - Tableview configuration

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    UIView *segmentedControlView = (UIView*)[self.view viewWithTag:2];
    segmentedControlView.hidden = NO;
    
    UILabel *emptyFavoritesLabel = (UILabel*)[tableView viewWithTag:4];
    emptyFavoritesLabel.hidden = YES;
    // User have made no meetings
    if ([tableView numberOfSections] == 0) {
        emptyFavoritesLabel.hidden = NO;
        
        //We hide the segmented control on page load
        // only if there is nothing among ALL meetings
        // so user can have no favorites but he still has the segmentedControl
        if (!self.FilterEnabled) {
            segmentedControlView.hidden = YES;
        }
    }
    return [distinctDays count];
}

// Title of categories
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 18.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 69.0)];
    headerView.opaque = YES;
    
    NSString *title = [distinctDays objectAtIndex:section];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 69.0)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
    label.text = title;
    

    headerView.backgroundColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:.9f];
    label.textColor = [UIColor whiteColor];
    
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
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbid != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserID"]];
    
    NSPredicate *favoritesMeetingsFilter = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    
    NSCompoundPredicate *filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[meetingsFilter]];
    if (self.isFilterEnabled) {
        filterPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[favoritesMeetingsFilter, meetingsFilter]];
    }

    // We don't want the taste of the current user
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:filterPredicates];
    
    UILabel *emptyFavoritesLabel = (UILabel*)[tableView viewWithTag:3];
    if ([meetings count] == 0) {
        emptyFavoritesLabel.hidden = NO;
        return 0;
    } else {
        emptyFavoritesLabel.hidden = YES;
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yy";

    NSDate *currentDate = [NSDate new];
    currentDate = [dateFormatter dateFromString:[distinctDays objectAtIndex:section]];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsForFirstDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
    
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
    [self.navigationController pushViewController:detailsMeetingViewController animated:YES];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    

    ShareListMediaTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yy";
    
    NSDate *currentDate = [NSDate new];
    currentDate = [dateFormatter dateFromString:[distinctDays objectAtIndex:indexPath.section]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsForFirstDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
    
    NSMutableArray *foo = [NSMutableArray new];
    for (int i = 0; i < [daysList count]; i++) {
        NSDateComponents *componentsForSecondDate = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[daysList objectAtIndex:i] ];
        
        
        if (([componentsForFirstDate year] == [componentsForSecondDate year]) && ([componentsForFirstDate month] == [componentsForSecondDate month]) && ([componentsForFirstDate day] == [componentsForSecondDate day])) {
            [foo addObject:[daysList objectAtIndex:i]];
        }
    }

    UserTaste *currentUserTaste = [UserTaste MR_findFirstByAttribute:@"lastMeeting"
                                                           withValue:[foo objectAtIndex:(([foo count] - indexPath.row) - 1)]];
    
    
    NSDateFormatter *cellDateFormatter = [NSDateFormatter new];
    cellDateFormatter.timeStyle = kCFDateFormatterMediumStyle; // HH:MM:SS
    
    cell.textLabel.text = [NSString stringWithFormat:@"Rencontré à %@", [cellDateFormatter stringFromDate:[foo objectAtIndex:(([foo count] - indexPath.row) - 1)]]];
    cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.model = currentUserTaste;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.9f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    
    return cell;
}


#pragma mark - Fetch Datas in background

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
   
    [self getRandomUserDatas];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void) getRandomUserDatas {
    NSURL *aUrl= [NSURL URLWithString:@"http://192.168.1.55:8888/Share/getusertaste.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    NSInteger myInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"fbUserID"];
    
    NSString *postString = [NSString stringWithFormat:@"fbiduser=%li", (long)myInt];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
//    [conn start];
//    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR");
        } else {
            [self datas:data];
        }
    }];
}

- (void) datas:(NSData *)objectNotation
{
    NSString *responseString = [[NSString alloc] initWithData:objectNotation encoding:NSUTF8StringEncoding];
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSMutableDictionary *foo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"newStr : %@", [foo objectForKey:@"user_favs"]);
}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.responseData appendData:data];
//}
//
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    
//    NSLog(@"myint %@", self.responseData);
//    // Server sends back some datas
//    if (self.responseData != nil) {
//        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//        
//        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//        
//        
//        NSMutableDictionary *foo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"newStr : %@", foo);
//        
//        self.responseData = nil;
//        self.responseData = [NSMutableData new];
//    }
//    
//}
//
//- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    NSMutableArray *userTasteDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    
//     NSLog(@"newStr : %@", userTasteDict);
//    
////        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
////            UserTaste *userTaste = [UserTaste  MR_createEntity];
////            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[userTasteDict objectForKey:@"user_favs"]];
////            userTaste.taste = arrayData;
////            userTaste.fbid = [NSNumber numberWithLong:1382410218159367];
////            userTaste.lastMeeting = [NSDate date];
////            userTaste.isFavorite = NO;
////        } completion:nil];
//}



- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
