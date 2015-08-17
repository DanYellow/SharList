//
//  ProfileHeaderView.m
//  SharList
//
//  Created by Jean-Louis Danielo on 16/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "ProfileHeaderView.h"

@interface ProfileHeaderView()

@property (strong, nonatomic) SHDUserDiscoveredDatas *userDatas;
@property (strong, atomic) UIView *profileHeaderView;

@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) NSUInteger bottomOffset;


@end

@implementation ProfileHeaderView


- (id) initWithDatas:(SHDUserDiscoveredDatas*)userDatas
{
    self = [super init];
    if ( !self ) return nil;
    
    const CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
    self.screenHeight = screenRect.size.height;
    
    CGFloat percent = (userDatas.isSameUser) ? (348.0/1136.0) : (423.0/1136.0);
    
    self.bottomOffset = (userDatas.isSameUser) ? 0 : 5;
    self.frame = CGRectMake(0, 0, self.screenWidth, self.screenHeight * percent); //455
    
    self.backgroundColor = [UIColor clearColor];
    self.userDatas = userDatas;
    
    self.profileHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight * .1919014085)];
    self.profileHeaderView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.profileHeaderView];
    
    [self displayProfile];
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
    
    NSString *urlAPI = [[settingsDict valueForKey:@"apiPathV2"] stringByAppendingString:@"user.php/user"];
    
    
    
    NSString *currentUserId = self.userDatas.fbid;
    if (self.userDatas.fbid == nil) {
        currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"];
    }
    
    NSDictionary *apiParams = @{@"fbiduser" : currentUserId};
    
    [manager GET:urlAPI
      parameters:apiParams
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if (!responseObject[@"error"]) {
                 // gentoo
                 [self displayFollowers:[responseObject valueForKeyPath:@"response.followersCount"]];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
    
    UIView *statsContainer = [self displayButtons];
    statsContainer.frame = CGRectMake(0, CGRectGetMaxY(self.profileHeaderView.frame) - self.bottomOffset,
                                      CGRectGetWidth(statsContainer.frame), CGRectGetHeight(statsContainer.frame));
    [self addSubview:statsContainer];
    
    int sizeImage = 130;
    
    NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", self.userDatas.fbid, sizeImage, sizeImage];

    self.bgImageProfile = [[UIImageView alloc] initWithFrame:self.frame];
    [self.bgImageProfile setImageWithURL:[NSURL URLWithString:metUserFBImgURL] placeholderImage:nil];
    self.bgImageProfile.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageProfile.tag = 5;
    self.bgImageProfile.clipsToBounds = YES;
//    [self insertSubview:bgImage atIndex:0];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.frame;
    [self.bgImageProfile addSubview:visualEffectView];

    return self;
}

- (void) displayProfile
{
    // Profile Image
    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 20, 62, 62)];
    profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    profileImageView.backgroundColor = [UIColor clearColor];
    profileImageView.clipsToBounds = YES;
    profileImageView.layer.masksToBounds = YES;
    
    profileImageView.layer.borderWidth = 2.0f;
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    profileImageView.layer.cornerRadius = 31;
    
    
    NSUInteger sizeImage = (int)CGRectGetHeight(profileImageView.frame) * 2;
    
    NSString *fbMetUserString = self.userDatas.fbid;
    NSString *metUserFBImgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%li&height=%li", fbMetUserString,sizeImage, sizeImage];
    
    [profileImageView setImageWithURL:[NSURL URLWithString:metUserFBImgURL] placeholderImage:nil];
    [self.profileHeaderView addSubview:profileImageView];
    
    // Labels
    UIView *labelsContainer = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(profileImageView.frame) + 10, CGRectGetMinY(profileImageView.frame) + 3, 0, 0)];
    labelsContainer.backgroundColor = [UIColor clearColor];
    [self.profileHeaderView addSubview:labelsContainer];
    
    // Percent
    NSNumberFormatter *percentageFormatter = [NSNumberFormatter new];
    [percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    NSString *percentString = [percentageFormatter stringFromNumber:[NSNumber numberWithFloat:self.userDatas.percentToDiscover]];
    
    NSMutableAttributedString *statsAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ to discover", nil), percentString] attributes:nil];
    NSRange percentRange = [[statsAttrString string] rangeOfString:percentString];
    [statsAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0] range:NSMakeRange(percentRange.location, percentRange.length)];
    
    UILabel *statsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    statsLabel.textColor = [UIColor whiteColor];
    statsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    if (!self.userDatas.isSameUser) {
        statsLabel.attributedText = statsAttrString;
    } else {
        statsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0];
//        statsLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPatronym"];
        
        statsLabel.text = self.userDatas.lastMediaAdded;

    }
    
    [statsLabel sizeToFit];
    [labelsContainer addSubview:statsLabel];
    
    // Last entry
    UIView *labelsContainerLastView = [labelsContainer.subviews lastObject];
    
    NSString *lastMediaAdded = @"Breaking Bad of Sillicon Valley";
    NSMutableAttributedString *lastEntryDiscoverAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"last element added %@", nil), lastMediaAdded] attributes:nil];
    NSRange lastEntryRange = [[lastEntryDiscoverAttrString string] rangeOfString:lastMediaAdded];
    [lastEntryDiscoverAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0] range:NSMakeRange(lastEntryRange.location, lastEntryRange.length)];
    
    
    NSUInteger maxWidthLastEntryDiscoverLabel = (int)self.screenWidth - ((int)CGRectGetMinX(labelsContainer.frame) + 20);
    
    UILabel *lastEntryDiscover = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(labelsContainerLastView.frame), maxWidthLastEntryDiscoverLabel, 0)];
    lastEntryDiscover.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    lastEntryDiscover.attributedText = lastEntryDiscoverAttrString;
    lastEntryDiscover.textColor = [UIColor whiteColor];
    lastEntryDiscover.clipsToBounds = NO;
    lastEntryDiscover.lineBreakMode = NSLineBreakByWordWrapping;
    lastEntryDiscover.numberOfLines = 0;
    [lastEntryDiscover sizeToFit];
    lastEntryDiscover.backgroundColor = [UIColor clearColor];
    
    lastEntryDiscover.frame = CGRectMake(0, CGRectGetMinY(lastEntryDiscover.frame), maxWidthLastEntryDiscoverLabel, CGRectGetHeight(lastEntryDiscover.frame));
    
    [labelsContainer addSubview:lastEntryDiscover];
}

- (UIView*) displayButtons
{
    float widthViews = self.screenWidth * 0.246875;
    NSUInteger offsetBtnElements = 12;
    
    UIView *statsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    statsContainer.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < [[self.userDatas.discoveredUserLikes filterKeysForNullObj] count]; i++) {
        NSString *dictKey = [[self.userDatas.discoveredUserLikes filterKeysForNullObj] objectAtIndex:i];
        NSString *title = [NSLocalizedString(dictKey, nil) uppercaseString];
        
        
        CGRect statContainerFrame = CGRectMake((i * 1) + (widthViews * i),
                                               0,
                                               widthViews, 64);
        
        
        UIButton *statContainer = [[UIButton alloc] initWithFrame:statContainerFrame];
        statContainer.backgroundColor = [UIColor colorWithRed:(17.0/255.0) green:(27.0/255.0) blue:(28.0/255.0) alpha:.55];
        statContainer.tag = i;
        
//        [statContainer addTarget:self action:@selector(scrollToSectionWithNumber:) forControlEvents:UIControlEventTouchUpInside];
        [statsContainer addSubview:statContainer];
        
        UILabel *statCount = [[UILabel alloc] initWithFrame:CGRectMake(offsetBtnElements, 0, widthViews, 35.0)];
        statCount.textColor = [UIColor whiteColor];
        statCount.backgroundColor = [UIColor clearColor];
        statCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:35.0f];
        
        // COntains the number of Series / Movies
        NSUInteger nbElementsForCat = [[self.userDatas.discoveredUserLikes objectForKey:dictKey] count];
        statCount.text = [NSString stringWithFormat: @"%li", nbElementsForCat];
        [statCount sizeToFit];
        [statContainer insertSubview:statCount atIndex:10];
        
        
        UILabel *statTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        statTitle.textColor = [UIColor whiteColor];
        statTitle.backgroundColor = [UIColor clearColor];
        statTitle.text = title;
        statTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        [statTitle sizeToFit];
        statTitle.frame = CGRectMake(offsetBtnElements,
                                     CGRectGetMaxY(statContainer.frame) - CGRectGetHeight(statTitle.frame) - 3,
                                     CGRectGetWidth(statTitle.frame), CGRectGetHeight(statTitle.frame));
        
        [statContainer addSubview:statTitle];
    }
    
    return statsContainer;
}

- (void) displayFollowers:(NSNumber*)numberOfFollowers
{
    float widthViews = self.screenWidth * 0.5;
    
    
    
    UIButton *followersLabelContainerBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - widthViews,
                                                                                      CGRectGetMaxY(self.profileHeaderView.frame) - self.bottomOffset,
                                                                                      widthViews, 64)];
    followersLabelContainerBtn.backgroundColor = [UIColor colorWithRed:(17.0/255.0)
                                                                 green:(27.0/255.0)
                                                                  blue:(28.0/255.0) alpha:.55];
    followersLabelContainerBtn.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        followersLabelContainerBtn.alpha = 1;
    }];
    
    
    UILabel *followersTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    followersTitle.textColor = [UIColor whiteColor];
    followersTitle.backgroundColor = [UIColor clearColor];
    followersTitle.text = [NSLocalizedString(@"followers", nil) uppercaseString];
    
    followersTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
    followersTitle.textAlignment = NSTextAlignmentRight;
    if (![followersTitle isDescendantOfView:followersLabelContainerBtn]) {
        [followersLabelContainerBtn addSubview:followersTitle];
    }
    
    
    if ([numberOfFollowers integerValue] > 1) {
        followersTitle.text = [NSLocalizedString(@"followers", nil) uppercaseString];
    } else {
        followersTitle.text = [NSLocalizedString(@"follower", nil) uppercaseString];
    }
    [followersTitle sizeToFit];
    followersTitle.frame = CGRectMake(CGRectGetWidth(followersLabelContainerBtn.frame) - (CGRectGetWidth(followersTitle.frame) + 12),
                                      CGRectGetHeight(followersLabelContainerBtn.frame) - (CGRectGetHeight(followersTitle.frame) + 3),
                                      CGRectGetWidth(followersTitle.frame), CGRectGetHeight(followersTitle.frame));
    
    
    UILabel *numberFollowersLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    numberFollowersLabel.textColor = [UIColor whiteColor];
    numberFollowersLabel.backgroundColor = [UIColor redColor];
    numberFollowersLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f];
    numberFollowersLabel.text = [NSString stringWithFormat:@"%@", numberOfFollowers];
    numberFollowersLabel.tag = 8;
    numberFollowersLabel.backgroundColor = [UIColor clearColor];
    numberFollowersLabel.textAlignment = NSTextAlignmentRight;
    
    [numberFollowersLabel sizeToFit];
    numberFollowersLabel.frame = CGRectMake(CGRectGetWidth(followersLabelContainerBtn.frame) - (CGRectGetWidth(numberFollowersLabel.frame) + 12),
                                            CGRectGetMinY(followersTitle.frame) - CGRectGetHeight(numberFollowersLabel.frame),
                                            CGRectGetWidth(numberFollowersLabel.frame), CGRectGetHeight(numberFollowersLabel.frame));
    
    [followersLabelContainerBtn addSubview:numberFollowersLabel];
    
    [self addSubview:followersLabelContainerBtn];
}

@end
