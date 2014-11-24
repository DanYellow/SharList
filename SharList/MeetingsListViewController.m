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
    UITableViewController *userMeetingsListTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    userMeetingsListTableViewController.tableView.frame = CGRectMake(0, 0, screenWidth, screenHeight - 49); //[self computeRatio:800.0 forDimension:screenHeight] + 44
    userMeetingsListTableViewController.tableView.dataSource = self;
    userMeetingsListTableViewController.tableView.delegate = self;
    userMeetingsListTableViewController.tableView.backgroundColor = [UIColor clearColor];
    userMeetingsListTableViewController.tableView.tag = 1;
    userMeetingsListTableViewController.tableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    //    userSelectionTableViewController.refreshControl = userSelectRefresh;
    userMeetingsListTableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userMeetingsListTableViewController.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:userMeetingsListTableViewController.tableView];
}

#pragma mark - Tableview configuration

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Gentoo";
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
