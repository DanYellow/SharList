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
// 1 : userSelectionTableView (blurred view)


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
    
    // Vars init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    userPreferences = [NSUserDefaults standardUserDefaults];
    self.metUserTasteDict = [NSMutableDictionary new];
    self.metUserTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.meetingDatas taste]] mutableCopy];
    
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
    
    
    UIBarButtonItem *addMeetingToFavoriteBtnItem;
    // This list is not among user's favorites
    if (![self.meetingDatas isFavorite]) {
        addMeetingToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavorite:)];
    } else {
        addMeetingToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavorite:)];
    }
    addMeetingToFavoriteBtnItem.tag = 2;
    addMeetingToFavoriteBtnItem.enabled = YES;
    
    self.navigationItem.rightBarButtonItem = addMeetingToFavoriteBtnItem;
    

    NSDateFormatter *foo = [NSDateFormatter new];
    foo.timeStyle = kCFDateFormatterMediumStyle; // HH:MM:SS
    foo.dateStyle = kCFDateFormatterMediumStyle;
    
    //___________________
    // Uitableview of user selection (what user likes)
    UITableView *userSelectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    userSelectionTableView.dataSource = self;
    userSelectionTableView.delegate = self;
    userSelectionTableView.backgroundColor = [UIColor clearColor];
    userSelectionTableView.tag = 1;
    userSelectionTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    //    userSelectionTableViewController.refreshControl = userSelectRefresh;
    userSelectionTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    userSelectionTableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:userSelectionTableView];
}

#pragma mark - tableview definition

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [[[self.metUserTasteDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    NSArray *sectionElements = [self.metUserTasteDict objectForKey:sectionTitle];
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
    
    NSString *title = [[[self.metUserTasteDict allKeys] objectAtIndex:section] uppercaseString];
    
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
    
    NSString *sectionTitle = [[self.metUserTasteDict allKeys] objectAtIndex:indexPath.section];
    NSString *title, *year, *imdbID;
    ShareListMediaTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *rowsOfSection = [self.metUserTasteDict objectForKey:sectionTitle];
    CGRect cellFrame = CGRectMake(0, 0, screenWidth, 69.0f);
    
    title = [rowsOfSection objectAtIndex:indexPath.row][@"name"];
    imdbID = [rowsOfSection objectAtIndex:indexPath.row][@"imdbID"];
    
    if (cell == nil) {
        cell = [[ShareListMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
//    cell.delegate = self;
    // For "Classic mode" we want a cell's background more opaque
    cell.backgroundColor = [UIColor colorWithRed:(246.0/255.0) green:(246.0/255.0) blue:(246.0/255.0) alpha:0.87];
    
    //            cell.rightUtilityButtons = [self rightButtonsForSearch];
    
    // We hide this part to get easily datas
    cell.textLabel.frame = cellFrame;
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    cell.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.textLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
    cell.textLabel.layer.shadowOpacity = .75f;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //            cell.textLabel.hidden = YES;
    cell.model = [rowsOfSection objectAtIndex:indexPath.row];
    
    if (imdbID != nil) {
        [self getImageCellForData:imdbID aCell:cell];
    }
    
    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(235.0f/255.0f) green:(242.0f/255.0f) blue:(245.0f/255.0f) alpha:.7f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    cell.textLabel.text = title;
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = year;
    
    
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


- (void) getImageCellForData:(NSString*)imdbID aCell:(UITableViewCell*)cell
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
    
    
    cell.backgroundView = imgBackground; //[cell addSubview:imgBackground];
    
    __block NSString *imgDistURL; // URL of the image from imdb database api
    
    NSString *linkAPI = @"http://www.omdbapi.com/?i=";
    linkAPI = [linkAPI stringByAppendingString:imdbID];
    linkAPI = [linkAPI stringByAppendingString:@"&plot=short&r=json"];
    
    CALayer *imgLayer = [CALayer layer];
    imgLayer.frame = cellFrame;
    [imgLayer addSublayer:gradientLayer];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:linkAPI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        imgDistURL = responseObject[@"Poster"];
        
        [imgBackground setImageWithURL:
         [NSURL URLWithString:imgDistURL]
                      placeholderImage:[UIImage imageNamed:@"bb"]];
        [imgBackground.layer insertSublayer:gradientLayer atIndex:0];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
