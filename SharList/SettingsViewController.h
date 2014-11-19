//
//  SettingsVieWControllerViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UINavigationControllerDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (strong, nonatomic) UITableViewController *settingsTVController;

@end
