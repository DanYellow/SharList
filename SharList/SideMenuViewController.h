//
//  SideMenuViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewController.h"

@interface SideMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (nonatomic, retain) UITableView *menuTableView;

@end
