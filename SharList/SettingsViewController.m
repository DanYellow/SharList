//
//  SettingsVieWControllerViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void) viewDidAppear:(BOOL)animated
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    

    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradient.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    FBLoginView *fbLoginButton = [FBLoginView new];
    fbLoginButton.delegate = self;
    fbLoginButton.tag = 2;
    fbLoginButton.frame = CGRectMake(51, screenHeight + 150, 218, 46);
    [self.view addSubview:fbLoginButton];
    
    self.settingsItemsList = @[NSLocalizedString(@"Enable geolocation", nil),
                               NSLocalizedString(@"Log out", nil)]; //NSLocalizedString(@"Delete account", nil)
    
    
    // Uitableview of user selection (what user likes)
    UITableView *settingsTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStyleGrouped];
    settingsTableview.dataSource = self;
    settingsTableview.delegate = self;
    settingsTableview.backgroundColor = [UIColor clearColor];
    settingsTableview.tag = 1;
    settingsTableview.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    settingsTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    settingsTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    settingsTableview.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:settingsTableview];
    
    
    UIButton *aboutButton = [UIButton new];
    [aboutButton setTitle:NSLocalizedString(@"about", nil) forState:UIControlStateNormal];
    [aboutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aboutButton addTarget:self action:@selector(displayAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    aboutButton.frame = CGRectMake(0, screenHeight - ((49 * 3) + 30), screenWidth, 49);
    [self.view addSubview:aboutButton];
}

- (void) displayAboutScreen
{
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    aboutViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
 
    
    navigationController.navigationBar.translucent = NO; // Or else we don't have the same background as in the psd
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    CALayer *bottomBorder3 = [CALayer layer];
    bottomBorder3.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder3.borderWidth = 1;
    bottomBorder3.name = @"bottomBorderLayer";
    CGRect bottomBorderFrame = CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 1.0f);
    bottomBorder3.frame = bottomBorderFrame;
    [navigationController.navigationBar.layer addSublayer:bottomBorder3];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
//    [self.navigationController pushViewController:aboutViewController animated:YES];

    // Present AboutViewController
}

- (void) dismissModal
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingsItemsList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2)
        return 70.0f;
    return 0.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (100.0/2.0);
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section >= 0) {
        return nil;
    }
    // We don't want this message currently
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
    tempView.backgroundColor = [UIColor clearColor];
    
    UILabel *footerSectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, screenWidth-30, 100)];
    footerSectionLabel.backgroundColor = [UIColor clearColor];
    footerSectionLabel.textColor = [UIColor whiteColor];
    footerSectionLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    footerSectionLabel.text = NSLocalizedString(@"Geoloc explain", nil);
    footerSectionLabel.textAlignment = NSTextAlignmentCenter;
    footerSectionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    footerSectionLabel.numberOfLines = 0;
    [tempView addSubview:footerSectionLabel];
    
    return tempView;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 85.0;
//}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *myLabel;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        if (indexPath.section == 0) {
            myLabel.frame = CGRectMake(12.0, 0, screenWidth, 50);
            myLabel.enabled = YES;
            
            UISwitch *geolocSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            geolocSwitch.onTintColor = [UIColor colorWithRed:(26.0f/255.0f) green:(79.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
            geolocSwitch.enabled = YES;
            geolocSwitch.tag = 3;
            [geolocSwitch addTarget:self action:@selector(geolocSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
                geolocSwitch.on = NO;
//                UIAlertView
                NSLog(@"denied");
            } else {
                geolocSwitch.on = YES;
            }
            
            cell.accessoryView = geolocSwitch;
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }
        myLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        myLabel.backgroundColor = [UIColor clearColor];
        

        [cell.contentView addSubview:myLabel];
    }
    
    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(205.0f/255.0f) green:(239.0f/255.0f) blue:(254.0/255.0f) alpha:.75]];
    cell.selectedBackgroundView = bgColorView;
    
    NSString *title = [self.settingsItemsList objectAtIndex:indexPath.section];
    
    myLabel.text = title;
    myLabel.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0];
    
    if (indexPath.section == 1 || indexPath.section == 2) {
        myLabel.textAlignment= NSTextAlignmentCenter;
    }
    
    if (indexPath.section == 2) {
        myLabel.textColor = [UIColor colorWithRed:(171.0f/255.0f) green:(0/255.0f) blue:(0/255.0f) alpha:1.0];
    }
    
    
    
    // [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        // Facebook log out
        case 1:
        {
            FBLoginView *fbLoginButton = (FBLoginView*)[self.view viewWithTag:2];
            
            for (id obj in fbLoginButton.subviews)
            {
                if ([obj isKindOfClass:[UIButton class]])
                {
                    [obj sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void) geolocSwitchChanged:(id)sender {
    UISwitch *switchControl = sender;
    
    if ([switchControl isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"geoLocEnabled"];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        // If user try to enable geoloc but he doesn't enable it
        // He gets an error and the switch is set to false
        if (![self userLocationAuthorization]) {}
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"geoLocEnabled"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UISwitch *geolocSwitch = (UISwitch*)[self.view viewWithTag:3];
    geolocSwitch.on = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"geoLocEnabled"];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
}

- (BOOL) userLocationAuthorization
{
    BOOL aBool = YES;
    UIAlertView *alert;
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
            {
                alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"geoloc denied", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
                aBool = NO;
            }
                break;                
            default:
                break;
        }
    } else {
        alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"geoloc disabled", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
        aBool = NO;
    }
    
    [alert show];
    alert = nil;
    
    
    
    return aBool;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"Settings", nil)])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

//- (void)updateSwitchAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableView *tableView = (UITableView*)[self.view viewWithTag:1];
//
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UISwitch *switchView = (UISwitch *)cell.accessoryView;
//    
//    if ([switchView isOn]) {
//        [switchView setOn:NO animated:YES];
//        [[NSUserDefaults standardUserDefaults] setBool:@0 forKey:@"geoLocEnabled"];
//        NSLog(@"NO");
//    } else {
//        [switchView setOn:YES animated:YES];
//        [[NSUserDefaults standardUserDefaults] setBool:@1 forKey:@"geoLocEnabled"];
//        NSLog(@"YES");
//    }
//}

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
