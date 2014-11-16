//
//  SideMenuViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController () {
    NSInteger _presentedRow;
}

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Menu", nil);
    UILabel *menuTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    menuTitle.text = NSLocalizedString(@"Menu", nil);
    menuTitle.textColor = [UIColor whiteColor];
//    [self.navigationController.view addSubview:menuTitle];
    menuTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.hidden = NO;
    
    
    
    UITableView *sideMenuTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)
                                                                                 style:UITableViewStylePlain];

    sideMenuTableview.dataSource = self;
    sideMenuTableview.delegate = self;
    sideMenuTableview.backgroundColor = [UIColor clearColor];
    sideMenuTableview.separatorColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    sideMenuTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:sideMenuTableview];
    
    self.view.backgroundColor = [UIColor colorWithRed:(44.0f/255.0f) green:(61.0f/255.0f) blue:(69.0f/255.0f) alpha:1];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSString *text = nil;
    if (row == 0) {
        text = @"Mon shike";
    } else if (row == 1) {
        text = @"Mes rencontres";
    } else if (row == 2) {
        text = @"Paramètres";
    }
    
    cell.textLabel.text = NSLocalizedString(text, nil);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    NSInteger row = indexPath.row;
    
    // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
    // we'll just set position and return
    
    if ( row == _presentedRow )
    {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
//    else if (row == 2)
//    {
//        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
//        return;
//    }

    // otherwise we'll create a new frontViewController and push it with animation
    
    UIViewController *newFrontController = nil;
    
    if (row == 0) {
        newFrontController = [[ViewController alloc] init];
    } else if (row == 1) {
        newFrontController = [[SettingsViewControllerViewController alloc] init];
    } else if (row == 2) {
        newFrontController = [[SettingsViewControllerViewController alloc] init];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    [navigationController setViewControllers:@[newFrontController]];
    navigationController.navigationBar.shadowImage = [UIImage new];

    UIColor *firstColor = [UIColor colorWithRed:203.0f/255.0f green:217.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:217.0f/255.0f green:231.0f/255.0f blue:236.0f/255.0f alpha:1.0f];

    NSArray *colors = @[firstColor, secondColor];
    
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[navigationController navigationBar] setTranslucent:NO]; // Remember, the default value is YES.
    
    [revealController pushFrontViewController:navigationController animated:YES];
    
    _presentedRow = row;  // <- store the presented row
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
