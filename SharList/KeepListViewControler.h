//
//  KeepListViewControler.h
//  SharList
//
//  Created by Jean-Louis Danielo on 08/09/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeepListElement.h"

#import "SHDMediaCell.h"
#import "DetailsMediaViewController.h"

typedef NS_ENUM(NSUInteger, KLVTag) {
    KLVTableViewTag = 1,
    KLVSegmentedControlTag = 2
};

@interface KeepListViewControler : UIViewController <UITableViewDelegate, UITableViewDataSource, UpdateUserKeepListDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (strong, nonatomic) NSMutableArray *userKeepList;


@end
