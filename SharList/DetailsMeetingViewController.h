//
//  DetailsMeetingViewController.h
//  SharList
//
//  Created by Jean-Louis Danielo on 26/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


#import "ShareListMediaTableViewCell.h"
#import "DetailsMediaViewController.h"

#import "NSString+SentenceCapitalizedString.h"

@protocol UpdateMeetingsListDelegate;

@interface DetailsMeetingViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSURLConnectionDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSUserDefaults *userPreferences;
}


@property (nonatomic, strong) id meetingDatas;
@property (retain, nonatomic) NSMutableData *responseData;
@property (nonatomic, assign) id<UpdateMeetingsListDelegate> delegate;



@end

@protocol UpdateMeetingsListDelegate <NSObject>

@required

- (void) meetingsListHaveBeenUpdate;

@end