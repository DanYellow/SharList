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

@property (nonatomic, assign, getter=isConnectedToInternet) BOOL ConnectedToInternet;


@end


// Tag list
// 1 : userSelectionTableView
// 2 : UIRefreshControl
// 3 : TutorialView
// 4 : metUserFBView
// 5 : metUserFBImgView


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
    
    NSURL *baseURL = [NSURL URLWithString:@"http://api.themoviedb.org"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                self.ConnectedToInternet = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                self.ConnectedToInternet = NO;
                break;
        }
    }];
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    self.metUserTasteDict = [NSMutableDictionary new];
    self.metUserTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.meetingDatas taste]] mutableCopy];
   
//    self.metUserTasteDict = [[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"list-tab-icon"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"discover-tab-icon"];

    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
//    NSLog(@"self.metUserTasteDict : %@", self.metUserTasteDict);
    
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
    if (![self.meetingDatas isFavorite]) {
        addMeetingToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavorite:)];
    } else {
        addMeetingToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavorite:)];
    }
    addMeetingToFavoriteBtnItem.tag = 2;
    addMeetingToFavoriteBtnItem.enabled = YES;
    
    UIBarButtonItem *seeFBUserMetAccountBtnItem;
    seeFBUserMetAccountBtnItem  = [[UIBarButtonItem alloc] initWithTitle:@"fb" style:UIBarButtonItemStylePlain target:self action:@selector(seeFbAccount:)];
    
    self.navigationItem.rightBarButtonItems = @[addMeetingToFavoriteBtnItem, seeFBUserMetAccountBtnItem];
    

//    NSDateFormatter *foo = [NSDateFormatter new];
//    foo.timeStyle = kCFDateFormatterMediumStyle; // HH:MM:SS
//    foo.dateStyle = kCFDateFormatterMediumStyle;
    
    UIView *meetingInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 42)];
    meetingInfoView.backgroundColor = [UIColor redColor];

    
//    UILabel *text = [[UILabel alloc] initWithFrame:meetingInfoView.frame];
//    text.text = @"GENTOO";
//    text.bounds = CGRectInset(meetingInfoView.frame, 10.0f, 10.0f);
//    [meetingInfoView addSubview:text];
    
  
    UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.0, screenWidth, 60)];
    tableFooter.textColor = [UIColor whiteColor];
    tableFooter.textAlignment = NSTextAlignmentCenter;
    tableFooter.opaque = YES;
    tableFooter.font = [UIFont boldSystemFontOfSize:15];
    tableFooter.text = [NSString sentenceCapitalizedString:[NSString stringWithFormat:NSLocalizedString(@"met %@ times", nil), [self.meetingDatas numberOfMeetings]]];

    //___________________
    // Uitableview of user selection (what user likes) initWithStyle:UITableViewStylePlain
    UITableView *userSelectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
//    userSelectionTableView.frame = CGRectMake(0, 0, screenWidth, screenHeight + self.tabBarController.tabBar.frame.size.height);
    userSelectionTableView.dataSource = self;
    userSelectionTableView.delegate = self;
    userSelectionTableView.backgroundColor = [UIColor clearColor];
    userSelectionTableView.tag = 1;
    userSelectionTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    userSelectionTableView.tableFooterView = tableFooter; //[[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:userSelectionTableView];
    
    // If the current user list is among user's favorites and the meeting have been made one hour ago
    // He can fetch his update to follow him
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    NSDateComponents *conversionInfo = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[self.meetingDatas lastMeeting] toDate:[NSDate date] options:0];
//    NSInteger hours = [conversionInfo hour];
    
    NSLog(self.ConnectedToInternet ? @"YES" : @"NO");
    if (YES) { //self.ConnectedToInternet
        UIView *metUserFBView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 120)];
        metUserFBView.backgroundColor = [UIColor clearColor];
        metUserFBView.tag = 4;
        int intWidthScreen = screenWidth;
        NSString *fbMetUserString = [[self.meetingDatas fbid] stringValue];
        NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", @"gentoo", intWidthScreen, 120];
        
        UIImageView *metUserFBImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 120)];
        [metUserFBImgView setImageWithURL:[NSURL URLWithString:metUserFBImgURL]];
        metUserFBImgView.contentMode = UIViewContentModeScaleAspectFit;
        metUserFBImgView.tag = 5;
        [metUserFBView addSubview:metUserFBImgView];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = metUserFBImgView.frame;
        [gradientLayer setStartPoint:CGPointMake(-0.05, 0.5)];
        [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
        gradientLayer.colors = @[(id)[[UIColor whiteColor] CGColor]];

        
        CALayer *metUserFBImgViewLayer = [CALayer layer];
        metUserFBImgViewLayer.backgroundColor = (__bridge CGColorRef)([UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]);
        metUserFBImgViewLayer.frame = metUserFBImgView.frame;
        [metUserFBImgView.layer addSublayer:gradientLayer];
        
        NSLog(@"metUserFBImgURL : %@", metUserFBImgView.image);
        
        userSelectionTableView.tableHeaderView = metUserFBView;
        
        [userSelectionTableView setContentOffset:CGPointMake(0, metUserFBView.bounds.size.height)];
    }


    if ([self.meetingDatas isFavorite]) {
        // Shoud contain raw data from the server
        self.responseData = [NSMutableData new];

        UIRefreshControl *userSelectRefreshControl = [[UIRefreshControl alloc] init];
        userSelectRefreshControl.backgroundColor = [UIColor clearColor];
        userSelectRefreshControl.tintColor = [UIColor whiteColor];
        userSelectRefreshControl.tag = 2;
        [userSelectRefreshControl addTarget:self action:@selector(updateCurrentUser) forControlEvents:UIControlEventValueChanged];
        [userSelectionTableView addSubview:userSelectRefreshControl];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"detailsMeetingFavTutorial"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"detailsMeetingFavTutorial"];
            [self showTutorial];
        }
    }
}

- (void) updateCurrentUser
{
    UIRefreshControl *userSelectRefresh = (UIRefreshControl*)[self.view viewWithTag:2];
    [userSelectRefresh endRefreshing];
    
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    [formatter setDateFormat:@"MMM d, h:mm a"];
//    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
//    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
//                                                                forKey:NSForegroundColorAttributeName];
//    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
//    userSelectRefresh.attributedTitle = attributedTitle;

    [self getServerDatasForFbID:[self.meetingDatas fbid]];
}

- (void) seeFbAccount:(UIBarButtonItem*)sender
{
//    fb://profile/(fbid)
    NSURL *fbAccountURL = [NSURL URLWithString:@"fb://profile/10205792663674205"];
    [[UIApplication sharedApplication] openURL:fbAccountURL];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/app_scoped_user_id/10205792663674205", nil]]];
//    
    // 10205792663674205
    // 1494405967495387
    
//    https://graph.facebook.com/1494405967495387/picture?width=230&height=120
//
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
                
                NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", [self.meetingDatas fbid]];
                UserTaste *oldUserTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                oldUserTaste.taste = arrayData;
//                oldUserTaste.lastMeeting = [NSDate date];
                
                UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
                [tableView reloadData];
            } else {
                UIAlertView *noNewDatasAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No results", nil) message:NSLocalizedString(@"no datas updated for this user", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [noNewDatasAlert show];
            }
        }
        
        self.responseData = nil;
        self.responseData = [NSMutableData new];
        
        UIRefreshControl *userSelectRefresh = (UIRefreshControl*)[self.view viewWithTag:2];
        [userSelectRefresh endRefreshing];
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
            
            imgDistURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w396/%@", imgURL];
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
    
    return [self.metUserTasteDict count];
}

// Title of categories
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat fontSize = 18.0f;
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
    NSString *sectionTitle = [[[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.section];
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
    
    cell.alpha = .3f;

    cell.model = [rowsOfSection objectAtIndex:indexPath.row];
    
    if (imdbID != nil) {
        [self getImageCellForData:cell.model aCell:cell];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    //    NSString *titleForHeader = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    
    ShareListMediaTableViewCell *selectedCell = (ShareListMediaTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    DetailsMediaViewController *detailsMediaViewController = [[DetailsMediaViewController alloc] init];
    detailsMediaViewController.mediaDatas = selectedCell.model;
    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
}


- (void) addAsFavorite:(UIBarButtonItem*)sender
{
    if ([sender.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
        sender.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        [self.meetingDatas setIsFavorite:YES];
    }else{
        sender.image = [UIImage imageNamed:@"meetingFavoriteUnselected"];
        [self.meetingDatas setIsFavorite:NO];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    if ([self.delegate respondsToSelector:@selector(meetingsListHaveBeenUpdate)]) {
        [self.delegate meetingsListHaveBeenUpdate];
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
