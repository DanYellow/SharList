//
//  PostCommentViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 19/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>

//Vendors
#import "AFNetworking.h"

@interface PostCommentViewController : UIViewController <UITextViewDelegate, NSLayoutManagerDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSDictionary *settingsDict;
}


@property (strong, nonatomic) NSString *mediaId;

@end
