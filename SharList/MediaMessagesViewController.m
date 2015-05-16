//
//  MediaMessagesViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 16/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "MediaMessagesViewController.h"

@interface MediaMessagesViewController ()

@property(strong, nonatomic) NSMutableArray *messages;

@end

#pragma mark - tag list references
// Tag list
// 1  : UITableview

@implementation MediaMessagesViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    CALayer *bottomBorderLayer = [self.navigationController.navigationBar.layer valueForKey:@"bottomBorder"];
    [bottomBorderLayer removeFromSuperlayer];
    [self.navigationController.navigationBar.layer setValue:nil forKey:@"bottomBorder"];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    NSArray* sublayers = [NSArray arrayWithArray:self.navigationController.navigationBar.layer.sublayers];
    for (CALayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"bottomBorderLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Variables init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    

    
    
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathLocal"] stringByAppendingString:@"media.php/media/messages"];
    
    
    NSDictionary *parameters = @{@"fbiduser": @"fb456742", @"imdbId": self.mediaId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject : %@", responseObject[@"response"]);
         NSLog(@"responseObject : %@", responseObject[@"error"]);
        if (responseObject[@"response"]) {
            self.messages = responseObject[@"response"];
            [self displayMessages];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
    }];
}


- (void) displayMessages
{
    UITableView *messagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                                   118,
                                                                                   screenWidth,
                                                                                   CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tabBarController.tabBar.bounds))
                                                                  style:UITableViewStylePlain];
    messagesTableView.dataSource = self;
    messagesTableView.delegate = self;
    messagesTableView.backgroundColor = [UIColor clearColor];
    messagesTableView.tag = 1;
    messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    messagesTableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + 15, 0);
    messagesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    messagesTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    messagesTableView.allowsSelection = NO;
    [self.view insertSubview:messagesTableView atIndex:1];
}


#pragma mark - UITableView functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
    NSString *message, *dateMessageString;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];

    
    UIView *messageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, floorf(((screenWidth * 89.375) / 100)), cellFrame.size.height)];
    messageContainer.backgroundColor = [UIColor clearColor];
    messageContainer.center = CGPointMake(self.view.center.x, messageContainer.center.y);

    CALayer *messageContainerBottomBorder = [CALayer layer];
    messageContainerBottomBorder.frame = CGRectMake(0, cellFrame.size.height, messageContainer.frame.size.width, 1.0f);
    messageContainerBottomBorder.backgroundColor = [UIColor colorWithRed:(87.0/255.0) green:(86.0/255.0) blue:(75.0/255.0) alpha:1.0].CGColor;
    [messageContainer.layer addSublayer:messageContainerBottomBorder];
    
    message = [[self.messages objectAtIndex:indexPath.row] valueForKeyPath:@"message.text"];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, floorf(((screenWidth * 85.53125) / 100)), 65)];
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
    [messageLabel sizeToFit];
    [messageContainer addSubview:messageLabel];
    
    
    dateMessageString = [[self.messages objectAtIndex:indexPath.row] valueForKeyPath:@"message.date.date"];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDate *dateMessage = [dateFormatter dateFromString:dateMessageString];
    
    NSLog(@"%@, %@, %@", [dateFormatter stringFromDate:dateMessage], dateMessage, dateMessageString);
    
    UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cellFrame.size.height - 20, messageContainer.frame.size.width, 13)];
    dateMessageLabel.textAlignment = NSTextAlignmentRight;
    dateMessageLabel.text = @"16/05/2015";
    dateMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    dateMessageLabel.textColor = [UIColor colorWithRed:(124.0/255.0) green:(124.0/255.0) blue:(124.0/255.0) alpha:1.0];
    dateMessageLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    dateMessageLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
    dateMessageLabel.layer.shadowOpacity = .95f;
    [messageContainer addSubview:dateMessageLabel];
    
    [cell.contentView addSubview:messageContainer];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

//- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 85.0f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0f;
}

- (void) dismissModal
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
