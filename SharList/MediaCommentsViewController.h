//
//  MediaMessagesViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 16/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>


//Vendors
#import "AFNetworking.h"

#import "PostCommentViewController.h"

@interface MediaCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
}

@property (strong, nonatomic) NSString *mediaId;
@property (strong, nonatomic) NSString *userDiscoverId;

-  (void) loadComments;


@end
