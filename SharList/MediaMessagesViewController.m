//
//  MediaMessagesViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 16/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "MediaMessagesViewController.h"

@interface MediaMessagesViewController ()

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
    
    
    // Uitableview of user selection (what user likes)
    UITableView *userTasteListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tabBarController.tabBar.bounds)) style:UITableViewStylePlain];
    userTasteListTableView.dataSource = self;
    userTasteListTableView.delegate = self;
    userTasteListTableView.backgroundColor = [UIColor clearColor];
    userTasteListTableView.tag = 1;
    userTasteListTableView.separatorColor = [UIColor colorWithRed:(174.0/255.0f) green:(174.0/255.0f) blue:(174.0/255.0f) alpha:1.0f];
    userTasteListTableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + 15, 0); //self.bottomLayoutGuide.length
    userTasteListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userTasteListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:userTasteListTableView atIndex:1];
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
