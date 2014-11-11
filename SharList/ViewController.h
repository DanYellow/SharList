//
//  ViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import <FacebookSDK/FacebookSDK.h>


#import "ShareListMediaTableViewCell.h"
#import "DetailsMediaViewController.h"

#import "UserTaste.h"



@interface ViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource,
UISearchControllerDelegate, UISearchResultsUpdating, UINavigationControllerDelegate, UISearchBarDelegate>
{    
    CGFloat screenWidth;
    CGFloat screenHeight;
   
    // Datas from API
    NSArray *APIdatas;
//    NSMutableArray *filteredDatas;
    NSMutableDictionary *filteredTableDatas;
    NSArray *categoryList;
    NSMutableDictionary *userTasteDict;
    
    
    
    BOOL USERALREADYMADEARESEARCH;
    
}

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;
@property (strong, nonatomic) UserTaste *userTaste;


- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension;
- (UIImage *) takeSnapshotOfView:(UIView *)view;

@end

