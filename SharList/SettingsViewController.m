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

#pragma mark - tag list references
// Tag list
// 1 : settingsTableview
// 2 : fbLoginButton
// 3 : geolocSwitch
// 4 : Alertview for access device's settings
// 5 : Alertview for betaseries
// 6 : connectBSButton
// 7 : alertEnableAnonymousMode
// 8 : enableAnonSwitch

@implementation SettingsViewController

- (void) viewDidAppear:(BOOL)animated
{
}

- (void) viewWillAppear:(BOOL)animated
{
    self.settingsItemsList = [[NSMutableArray alloc] initWithArray:@[NSLocalizedString(@"Enable anonymous mode", nil),
                                                                     NSLocalizedString(@"Enable geolocation", nil),
                                                                     NSLocalizedString(@"Log out", nil)]];
    
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    // We display the betaseries button only if the user is french
    if ([userLanguage isEqualToString:@"fr"]) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BSUserToken"]) {
            [self.settingsItemsList insertObject:NSLocalizedString(@"BSConnect", nil) atIndex:self.settingsItemsList.count];
        } else {
            [self.settingsItemsList insertObject:NSLocalizedString(@"BSDisconnect", nil) atIndex:self.settingsItemsList.count];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    // Contains globals datas of the project
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
//    self.settingsItemsList = @[NSLocalizedString(@"Enable geolocation", nil),
//                               NSLocalizedString(@"Log out", nil)]; //NSLocalizedString(@"Delete account", nil)
    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    
    UIButton* aboutBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [aboutBtn addTarget:self action:@selector(displayAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *aboutBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:aboutBtn];
    self.navigationItem.rightBarButtonItem = aboutBarBtnItem;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradient.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    FBLoginView *fbLoginButton = [FBLoginView new];
    fbLoginButton.tag = 2;
    fbLoginButton.frame = CGRectMake(51, screenHeight + 150, 218, 46);
    [self.view addSubview:fbLoginButton];
    
    
    UIButton *shareShoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareShoundBtn setFrame:CGRectMake(0, 20, screenWidth, 44)];
    [shareShoundBtn setTitle:NSLocalizedString(@"Talk about shound", nil) forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareShoundBtn setTitleColor:[UIColor colorWithRed:(1/255) green:(76/255) blue:(119/255) alpha:1.0] forState:UIControlStateSelected];
    [shareShoundBtn addTarget:self action:@selector(shareFb) forControlEvents:UIControlEventTouchUpInside];

    // UITableview of user selection (what user likes)
    UITableView *settingsTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStyleGrouped];
    settingsTableview.dataSource = self;
    settingsTableview.delegate = self;
    settingsTableview.backgroundColor = [UIColor clearColor];
    settingsTableview.tag = 1;
    settingsTableview.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    settingsTableview.tableFooterView = shareShoundBtn;
    settingsTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    settingsTableview.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    [self.view addSubview:settingsTableview];
}

- (void) showBetaSeriesConnect
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BSConnect", nil)
                                                    message:NSLocalizedString(@"BSExplaination", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 5;
    [alert addButtonWithTitle:NSLocalizedString(@"Connection", nil)];
    [alert show];
    
    UITextField *usernameTextField = [alert textFieldAtIndex:0];
    usernameTextField.placeholder = NSLocalizedString(@"BSLoginPlaceholder", nil);
    
    UITextField *passwordTextField = [alert textFieldAtIndex:1];
    passwordTextField.placeholder = NSLocalizedString(@"BSPasswordPlaceholder", nil);
}

- (void) manageBSConnection
{
    NSString *BSUserToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"BSUserToken"];
    
    if (!BSUserToken) {
        [self showBetaSeriesConnect];
    } else {
        [self showBetaSeriesDisconnect];
    }
}

- (void) showBetaSeriesDisconnect
{
    NSString *disconnectMessage = [NSString stringWithFormat:@"Connecté(e) en tant que %@ sur BetaSeries", [[NSUserDefaults standardUserDefaults] objectForKey:@"BSUserLoginName"]];
    UIActionSheet *disconnectBetaSeries = [[UIActionSheet alloc] initWithTitle:disconnectMessage delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:NSLocalizedString(@"Disconnect", nil) otherButtonTitles: nil];
    [disconnectBetaSeries showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        NSString *BSUserToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"BSUserToken"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"a6843502959f" forHTTPHeaderField:@"X-BetaSeries-Key"];
        [manager.requestSerializer setValue:BSUserToken forHTTPHeaderField:@"X-BetaSeries-Token"];
        
        NSString *urlAPI = @"https://api.betaseries.com/members/destroy";
        
        [manager POST:urlAPI
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BSUserToken"];
                  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BSUserLoginName"];
    
                  
                  UITableView *settingsTableview = (UITableView*)[self.view viewWithTag:1];
                  UITableViewCell *cell = [settingsTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
                  cell.textLabel.text = NSLocalizedString(@"BSConnect", nil);
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
    }
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

#pragma mark - UITableview's methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingsItemsList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 2)
//        return 70.0f;
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
    
    UILabel *footerSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, screenWidth-30, 100)];
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 1;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == EnableGeoloc) {
            UISwitch *geolocSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            geolocSwitch.onTintColor = [UIColor colorWithRed:(26.0f/255.0f) green:(79.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
            geolocSwitch.enabled = YES;
            geolocSwitch.tag = 3;
            [geolocSwitch addTarget:self action:@selector(geolocSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"geoLocEnabled"] ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
                geolocSwitch.on = NO;
            } else {
                geolocSwitch.on = YES;
            }
            
            cell.accessoryView = geolocSwitch;
        }
        
        if (indexPath.section == EnabledAnonymous) {
            UISwitch *enableAnonSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            enableAnonSwitch.onTintColor = [UIColor colorWithRed:(26.0f/255.0f) green:(79.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
            enableAnonSwitch.enabled = YES;
            [enableAnonSwitch addTarget:self action:@selector(enableAnonSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            enableAnonSwitch.tag = 8;
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"anonModeEnabled"]) {
                enableAnonSwitch.on = NO;
            } else {
                enableAnonSwitch.on = YES;
            }
            
            cell.accessoryView = enableAnonSwitch;
        }
        
        if (indexPath.section == EnableGeoloc || indexPath.section == EnabledAnonymous) {
            
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:(44.0f/255.0f) green:(44.0f/255.0f) blue:(44.0f/255.0f) alpha:1.0];
        
        if (indexPath.section == FBLogOut || indexPath.section == UnlinkBS) {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:(205.0f/255.0f) green:(239.0f/255.0f) blue:(254.0/255.0f) alpha:.75]];
    cell.selectedBackgroundView = bgColorView;
    
    NSString *title = [self.settingsItemsList objectAtIndex:indexPath.section];
    cell.textLabel.text = title;

    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        // Facebook log out
        case FBLogOut:
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
            
        // Connect / Disconnect BS
        case UnlinkBS:
        {
            if (![self connected]) {
                UIAlertView *errConnectionAlertView;
                errConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                                                    message:NSLocalizedString(@"noconnection", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                [errConnectionAlertView show];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                return;
            }
            
            [self manageBSConnection];
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

- (void) enableAnonSwitchChanged:(id)sender
{
    UISwitch *enableAnonSwitch = sender;
    
    if (enableAnonSwitch.on && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isMessageIndicatorForAnonymousModeHaveBeenShowed"]) {
        UIAlertView *alertEnableAnonymousMode = [[UIAlertView alloc] initWithTitle:@""
                                                                           message:NSLocalizedString(@"Enable anonymous mode message", nil)                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        alertEnableAnonymousMode.tag = 7;
        [alertEnableAnonymousMode show];
    }

    enableAnonSwitch.enabled = NO;
    BOOL anonModeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"anonModeEnabled"];
    anonModeEnabled = !anonModeEnabled;
    
    [[NSUserDefaults standardUserDefaults] setBool:anonModeEnabled forKey:@"anonModeEnabled"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *urlAPI = [[settingsDict valueForKey:@"apiPath"] stringByAppendingString:@"updateUserStatus.php"];
    
//    NSString *isAnonymousBoolString = (anonModeEnabled) ? @"True" : @"False";
    
    NSDictionary *apiParams = @{@"isAnonymous" : [NSNumber numberWithBool:anonModeEnabled],
                                @"fbiduser" : [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]};

    [manager POST:urlAPI
       parameters:apiParams
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              enableAnonSwitch.enabled = YES;
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              NSLog(@"Error: %@", error);
          }];
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
                alert.tag = 4;
                [alert show];
                aBool = NO;
            }
                break;                
            default:
                break;
        }
    } else {
//        alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"geoloc disabled", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
        aBool = NO;
    }
    
    
    return aBool;
}

#pragma mark - UIAction View delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 4) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"Settings", nil)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    } else if (alertView.tag == 5) {
        if (buttonIndex == 1)
        {
            UITextField *username = [alertView textFieldAtIndex:0];
            UITextField *password = [alertView textFieldAtIndex:1];
            
            if (![self isUITextFieldValueEmpty:username] || ![self isUITextFieldValueEmpty:password]) {
                return;
            }
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"a6843502959f" forHTTPHeaderField:@"X-BetaSeries-Key"];

            
            NSString *urlAPI = [NSString stringWithFormat:@"http://api.betaseries.com/members/auth?client_id=8bc04c11b4c283b72a3fa48cfc6149f3&login=%@&password=%@", username.text, [NSString md5:password.text]];
            
            [manager POST:urlAPI
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, id jsonResponse) {
                      
                      if ([jsonResponse[@"errors"] count] > 0) {
                          
                          // We have to display the Alertview in the main controller
                          dispatch_async(dispatch_get_main_queue(), ^{
                              NSString *errorFromBSAPI = (NSString*)[jsonResponse valueForKeyPath:@"errors.text"][0];
                              UIAlertView *errorIDBSAlert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:errorFromBSAPI delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                              [errorIDBSAlert show];
                          });
                          
                          return;
                      }
                      
                      [[NSUserDefaults standardUserDefaults] setObject:jsonResponse[@"token"] forKey:@"BSUserToken"];
                      [[NSUserDefaults standardUserDefaults] setObject:[jsonResponse valueForKeyPath:@"user.login"] forKey:@"BSUserLoginName"];

                      
                      UITableView *settingsTableview = (UITableView*)[self.view viewWithTag:1];
                      UITableViewCell *cell = [settingsTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
                      cell.textLabel.text = NSLocalizedString(@"BSDisconnect", nil);

                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"Error: %@", error);
                  }];
        }
    } else if (alertView.tag == 7) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // We show message about anonymous mode only one time
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isMessageIndicatorForAnonymousModeHaveBeenShowed"];
        }
//        else if (buttonIndex == 1) { // User touch "cancel"
//            UISwitch *enableAnonSwitch = (UISwitch*)[self.view viewWithTag:8];
//            enableAnonSwitch.on = NO;
//        }
    }
}

- (BOOL) isUITextFieldValueEmpty:(UITextField*)anUITextField
{
    NSString *anUITextFieldText = [anUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [anUITextFieldText length] > 0 && ![anUITextFieldText isEqualToString:@""];
}

- (BOOL) connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - Share facebook

- (void) shareFb
{
    FBLinkShareParams *params = [FBLinkShareParams new];
    params.link = [NSURL URLWithString:@"https://appsto.re/us/sYAB4.i"];
    params.name = NSLocalizedString(@"FBLinkShareParams_name", nil);
    params.caption = NSLocalizedString(@"FBLinkShareParams_caption", nil);
    params.picture = [NSURL URLWithString:@"http://shound.fr/shound_logo_fb.jpg"];
        
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:nil
                                  description:NSLocalizedString(@"FBLinkShareParams_caption", nil)
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                                                    message:NSLocalizedString(@"FBLinkShareParams_posterror", nil)
                                                                         delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
                                          } else if (![results[@"completionGesture"] isEqualToString:@"cancel"]) {
                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FBLinkShareParams_postsuccess_title", nil)
                                                                          message:NSLocalizedString(@"FBLinkShareParams_postsuccess", nil)
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
                                          }
                                      }];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                    message:NSLocalizedString(@"FBLinkShareParams_noapp", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil] show];
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

@end
