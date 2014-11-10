//
//  SettingsVieWControllerViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "SettingsViewControllerViewController.h"

@interface SettingsViewControllerViewController ()

@end

@implementation SettingsViewControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    imgView.image = [UIImage imageNamed:@"appBG"];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgView];
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
