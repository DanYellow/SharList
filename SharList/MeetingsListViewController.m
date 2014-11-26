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

@implementation MeetingsListViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:4];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    if (!FBSession.activeSession.isOpen) {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];

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
    
    
    // Uitableview of user selection (what user likes)
    UITableView *userMeetingsListTableViewController = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 49) style:UITableViewStylePlain];
    userMeetingsListTableViewController.dataSource = self;
    userMeetingsListTableViewController.delegate = self;
    userMeetingsListTableViewController.backgroundColor = [UIColor clearColor];
    userMeetingsListTableViewController.tag = 1;
    userMeetingsListTableViewController.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    //    userSelectionTableViewController.refreshControl = userSelectRefresh;
    userMeetingsListTableViewController.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userMeetingsListTableViewController.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:userMeetingsListTableViewController];
    
    
    // Fetching datas
    NSPredicate *meetingsFilter = [NSPredicate predicateWithFormat:@"fbid != %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserID"]];
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:meetingsFilter]; // Order by date of meeting
//    NSLog(@"GENTOO : %li", meetings.count);
    NSMutableArray *listOfDistinctDays = [NSMutableArray new];
    NSMutableArray *foo = [NSMutableArray new];
    
//    NSMutableDictionary *foo2 = [NSMutableDictionary new];
    
    for (UserTaste *userTaste in meetings) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MM/dd/yy";
        NSString *dateString = [dateFormatter stringFromDate: [userTaste lastMeeting]];

        [listOfDistinctDays addObject: dateString];
        [foo addObject:[userTaste lastMeeting]];

    }
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginDate" ascending:NO];
    [listOfDistinctDays sortedArrayUsingSelector:@selector(compare:)]; // sortUsingDescriptors [NSArray arrayWithObject:sortDescriptor]

    daysList = [[NSMutableArray alloc] initWithArray:[[foo reverseObjectEnumerator] allObjects]]; //foo
    distinctDays = [[NSArray alloc] initWithArray:[[NSOrderedSet orderedSetWithArray:listOfDistinctDays] array]];
    
//    NSArray * uniqueArray = ;
    NSLog(@"%@, %@", daysList, distinctDays);
//    NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc]init]autorelease];
//    timeFormatter.dateFormat = @"HH:mm:ss";
//    
//    
//    NSString *dateString = [timeFormatter stringFromDate: localDate];
    

}

#pragma mark - Tableview configuration

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"distint key : %@", [distinctDays allObjects]);
    return [distinctDays count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [distinctDays objectAtIndex:section];
}

// Title of categories
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    CGFloat fontSize = 18.0f;
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 69.0)];
//    headerView.opaque = YES;
//    
//    NSString *title = [[distinctDays allObjects] objectAtIndex:section];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, screenWidth, 69.0)];
//    label.font = [UIFont fontWithName:@"Helvetica-Light" size:fontSize];
//    label.text = title;
//    
//
//    headerView.backgroundColor = [UIColor colorWithRed:(21.0f/255.0f) green:(22.0f/255.0f) blue:(23.0f/255.0f) alpha:.9f];
//    label.textColor = [UIColor whiteColor];
//    
//    [headerView addSubview:label];
//    
//    return headerView;
//}

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
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar]; // gets default calendar
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay) fromDate:[daysList objectAtIndex:section]]; // gets the year, month, and day for today's date
    NSDate *firstDate = [calendar dateFromComponents:components]; // makes a new NSDate keeping only the year, month, and day
    
//    NSLog(@"firstDate : %@", [daysList objectAtIndex:section]);
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastMeeting >= %@) AND (lastMeeting <= %@)", [daysList objectAtIndex:section], [daysList objectAtIndex:section]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastMeeting == %@", [daysList objectAtIndex:0]];
    
    NSCompoundPredicate *supe = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]];
    
    NSArray *meetings = [UserTaste MR_findAllSortedBy:@"lastMeeting" ascending:NO withPredicate:supe];
    
    NSLog(@"%@ | %li", [daysList objectAtIndex:0], section);
 
    return meetings.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"Install Gentoo");
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    

    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = @"title";
    cell.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(49.0/255.0) blue:(50.0/255.0) alpha:0.80];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.9f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}


#pragma mark - Fetch Datas in background


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
