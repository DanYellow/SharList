//
//  KeepListViewControler.m
//  SharList
//
//  Created by Jean-Louis Danielo on 08/09/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "KeepListViewControler.h"

@interface KeepListViewControler ()

@end

@implementation KeepListViewControler

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;

    [self.tabBarController.tabBar setHidden:YES];
    
    // Animate background of cell selected on press back button
    UITableView *tableView = (UITableView*)[self.view viewWithTag:KLVTableViewTag];
    NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Variables init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    self.userKeepList = [NSMutableArray new];
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    
    CAGradientLayer *gradientBGView = [CAGradientLayer layer];
    gradientBGView.frame = self.view.bounds;
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
    
    
    UIView *headerTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 124)];
    headerTableView.backgroundColor = [UIColor colorWithRed:(17.0/255.0) green:(27.0/255.0) blue:(38.0/255.0) alpha:.55];
    CALayer *bottomBorder3 = [CALayer layer];
    bottomBorder3.borderColor = [UIColor whiteColor].CGColor;
    bottomBorder3.borderWidth = 1;
    bottomBorder3.name = @"bottomBorderLayer";
    CGRect bottomBorderFrame = CGRectMake(0.0f, CGRectGetHeight(headerTableView.frame), CGRectGetWidth(headerTableView.frame), .5f);
    bottomBorder3.frame = bottomBorderFrame;
    [headerTableView.layer addSublayer:bottomBorder3];
    
    UITextView *descriptionHeader = [[UITextView alloc] initWithFrame:CGRectMake(0, 12.0, screenWidth * (614.0/640.0), 60.0)];
    descriptionHeader.text = NSLocalizedString(@"keep_list_desc", nil);
    descriptionHeader.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    descriptionHeader.center = CGPointMake(self.view.center.x, descriptionHeader.center.y);
    descriptionHeader.textColor = [UIColor whiteColor];
    descriptionHeader.backgroundColor = [UIColor clearColor];
    [descriptionHeader sizeThatFits:CGSizeMake(screenWidth * (614.0/640.0), 57.0)];
    [headerTableView addSubview:descriptionHeader];
    
    
    UISegmentedControl *filterDiscoverLikes = [[UISegmentedControl alloc] initWithItems:@[[NSLocalizedString(@"movie", nil) capitalizedString],
                                                                                          [NSLocalizedString(@"serie", nil) capitalizedString]]];
    filterDiscoverLikes.frame = CGRectMake(0, CGRectGetMaxY(headerTableView.frame) - CGRectGetHeight(filterDiscoverLikes.frame) - 5,
                                           screenWidth - 20, 30);
    filterDiscoverLikes.center = CGPointMake(headerTableView.center.x, filterDiscoverLikes.center.y);
    [filterDiscoverLikes addTarget:self action:@selector(filterTableview:) forControlEvents: UIControlEventValueChanged];
    // If the user met has all his list in the current user we start at step two
    filterDiscoverLikes.selectedSegmentIndex = 0;
    filterDiscoverLikes.tag = KLVSegmentedControlTag;
//    filterDiscoverLikes.enabled = NO;
    filterDiscoverLikes.tintColor = [UIColor whiteColor];
    filterDiscoverLikes.backgroundColor = [UIColor clearColor];
    [headerTableView addSubview:filterDiscoverLikes];
    
    
    UITableView *keepListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    keepListTableView.dataSource = self;
    keepListTableView.delegate = self;
    keepListTableView.backgroundColor = [UIColor clearColor];
    keepListTableView.tag = KLVTableViewTag;
    keepListTableView.alpha = 1;
    keepListTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    keepListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    keepListTableView.tableHeaderView = headerTableView; //[[UIView alloc] initWithFrame:CGRectZero];
    keepListTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    keepListTableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:keepListTableView];
    
    if ([keepListTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [keepListTableView setSeparatorInset:UIEdgeInsetsZero];
    }
//    
//    KeepListElement *eg = [KeepListElement MR_createEntity];
//    eg.name = @"Avengers : L'ère d'Ultron";
//    eg.imdbId = @"tt2395427";
//    eg.type = @"movie";
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*)[self.view viewWithTag:KLVSegmentedControlTag];
    
    NSArray *categories = @[@"movie", @"serie"];
    
    NSPredicate *keepPredicate = [NSPredicate predicateWithFormat:@"type == %@", categories[segmentedControl.selectedSegmentIndex]];
    
   self.userKeepList = [[KeepListElement MR_findAllSortedBy:@"name"
                                                  ascending:YES
                                              withPredicate:keepPredicate] mutableCopy];
    
    return self.userKeepList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SHDMediaCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[SHDMediaCell alloc] initWithReuseIdentifier:CellIdentifier andFrame:CGRectMake(0, 0, screenWidth, 69.0f)];
    }
    
    KeepListElement *elmnt = [self.userKeepList objectAtIndex:indexPath.row];
    cell.textLabel.text = elmnt.name;
    
    NSDictionary *cellMediaDict = @{ @"name": elmnt.name, @"type": elmnt.type, @"imdbID": elmnt.imdbId };
    cell.media = cellMediaDict;
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    //    NSString *titleForHeader = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    
    SHDMediaCell *selectedCell = (SHDMediaCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSObject *object = selectedCell.media;
    
    DetailsMediaViewController *detailsMediaViewController = [DetailsMediaViewController new];
    detailsMediaViewController.mediaDatas = object;
    detailsMediaViewController.title = [selectedCell.media objectForKey:@"name"];
    [self.navigationController pushViewController:detailsMediaViewController animated:YES];
}



#pragma mark - custom methods

- (void) filterTableview:(id)sender
{
    UITableView *userSelectionTableView = (UITableView*)[self.view viewWithTag:KLVTableViewTag];
    
    [userSelectionTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationFade];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
