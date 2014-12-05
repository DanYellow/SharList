//
//  DetailsMediaViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "DetailsMediaViewController.h"

@interface DetailsMediaViewController ()

@property (strong, nonatomic) UserTaste *userTaste;
@property (nonatomic, assign, getter=isConnectedToInternet) BOOL ConnectedToInternet;

@end



#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



// Tag list
// 1 : displayBuyView (blurred view)
// 2 : addMediaBtnItem
// 3 : addRemoveMediaLabel

// 400 - 410 : Buttons buy range
// 400 : Amazon
// 401 : iTunes

@implementation DetailsMediaViewController



// Before page loading we hide the tabbar

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [self.tabBarController.tabBar setHidden:NO];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor colorWithRed:(173.0/255.0f) green:(173.0f/255.0f) blue:(173.0f/255.0f) alpha:1.0f].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.name = @"bottomBorderLayer";
    bottomBorder.frame = CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 1.0f);
    
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ConnectedToInternet = YES;
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.omdbapi.com/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                self.ConnectedToInternet = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                self.ConnectedToInternet = NO;
                break;
        }
    }];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradient.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat imgMediaHeight = [self computeRatio:470 forDimension:screenHeight];
    
    UIView *infoMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, imgMediaHeight)];
    infoMediaView.tag = 2;
    
    UILabel *addRemoveMediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, 60, screenWidth - 5, 20)];
    addRemoveMediaLabel.textColor = [UIColor whiteColor];
    addRemoveMediaLabel.textAlignment = NSTextAlignmentRight;
    
    addRemoveMediaLabel.alpha = 0;
    addRemoveMediaLabel.hidden = YES;
    addRemoveMediaLabel.tag = 3;
    [infoMediaView insertSubview:addRemoveMediaLabel atIndex:10];
    
    // Init vars
    self.PhysicsAdded = NO;
    buyButtonsInitPositions = [NSMutableArray new];
    // Shoud contain raw data from the server
    self.responseData = [NSMutableData new];
    
    self.userTaste = [UserTaste MR_findFirstByAttribute:@"fbid"
                                              withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserID"]];
    userTasteDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     [NSNull null], @"book",
                     [NSNull null], @"movie",
                     [NSNull null], @"serie",
                     nil];
    
    
    // This statement is hre for prevent empty user list
    // Because it corrupt the NSMutableDictionary
    // And you're not able to update it
    if ([NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] != nil) {
        userTasteDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userTaste taste]] mutableCopy];
    }
    
    //Navigationbarcontroller
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIBarButtonItem *addMediaToFavoriteBtnItem;
    // This media is not among user list
    if (![[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] containsObject:self.mediaDatas]) {
        self.Added = NO;
        addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteUnselected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
        addRemoveMediaLabel.text = NSLocalizedString(@"Added", nil);
    } else {
        self.Added = YES;
        addMediaToFavoriteBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetingFavoriteSelected"] style:UIBarButtonItemStylePlain target:self action:@selector(addAndRemoveMediaToList:)];
        addRemoveMediaLabel.text = NSLocalizedString(@"Deleted", nil);
    }
    self.navigationItem.rightBarButtonItem = addMediaToFavoriteBtnItem;
    
    
    
    
    __block NSDictionary *datasFromServer;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *linkAPI = @"http://www.omdbapi.com/?i=";
    if (self.mediaDatas[@"imdbID"]) {
        linkAPI = [linkAPI stringByAppendingString:self.mediaDatas[@"imdbID"]];
    } else {
        linkAPI = [linkAPI stringByAppendingString:@"tt0903747"]; //Avengers
    }
    linkAPI = [linkAPI stringByAppendingString:@"&plot=full&r=json"];
    
    [manager GET:linkAPI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        datasFromServer = [[NSDictionary alloc] initWithDictionary:responseObject];
        [self setMediaViewForData:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *errConnectionAlertView = [[UIAlertView alloc] initWithTitle:@"Oups" message:@"Il semblerait qu'on ait du mal à afficher cette fiche. \n Réessayez plus tard." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errConnectionAlertView show];
        [loadingIndicator stopAnimating];
    }];
    
    
    
    
    CGFloat mediaTitleLabelY = imgMediaHeight - [self computeRatio:108 forDimension:imgMediaHeight];
    UILabel *mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, mediaTitleLabelY, screenWidth, 25)];
    mediaTitleLabel.text = self.mediaDatas[@"name"];
    mediaTitleLabel.textColor = [UIColor whiteColor];
    mediaTitleLabel.textAlignment = NSTextAlignmentCenter;
    mediaTitleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    mediaTitleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    mediaTitleLabel.layer.shadowRadius = 2.5;
    mediaTitleLabel.layer.shadowOpacity = 0.75;
    mediaTitleLabel.clipsToBounds = NO;
    mediaTitleLabel.layer.masksToBounds = NO;
    mediaTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
    [mediaTitleLabel addMotionEffect:[self UIMotionEffectGroupwithValue:7]];
    
    [infoMediaView insertSubview:mediaTitleLabel atIndex:9];
    [self.view addSubview:infoMediaView];
    
    
    
    loadingIndicator = [[UIActivityIndicatorView alloc] init];
    loadingIndicator.center = self.view.center;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [loadingIndicator startAnimating];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    [self.view addSubview:loadingIndicator];
}

- (void) setMediaViewForData:(NSDictionary*)data
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    
    // Design of the page
    UIImageView *imgMedia = [UIImageView new];
        [imgMedia setImageWithURL:
         [NSURL URLWithString:data[@"Poster"]]
                 placeholderImage:[UIImage imageNamed:@"bb"]];
    CGFloat imgMediaHeight = [self computeRatio:470 forDimension:screenHeight];
    imgMedia.frame = CGRectMake(0, 9, screenWidth, imgMediaHeight);
    imgMedia.contentMode = UIViewContentModeScaleAspectFill;
    imgMedia.clipsToBounds = YES;
    imgMedia.alpha = 0;
//    imgMedia.transform = CGAffineTransformScale(CGAffineTransformIdentity, .7, .7);
    [infoMediaView insertSubview:imgMedia atIndex:0];
    
    CCARadialGradientLayer *radialGradientLayer = [CCARadialGradientLayer layer];
    radialGradientLayer.gradientOrigin = imgMedia.center;
    radialGradientLayer.gradientRadius = 196;
    radialGradientLayer.colors = @[
                                   (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.001] CGColor],
                                   (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.35] CGColor],
                                   (id)UIColorFromRGB(0x000000).CGColor
                                   ];
    radialGradientLayer.locations = @[@0, @0.3, @1];
    radialGradientLayer.frame = imgMedia.bounds;
    [imgMedia.layer insertSublayer:radialGradientLayer atIndex:0];
    
    
    CGFloat mediaDescriptionWidth = [self computeRatio:608 forDimension:screenWidth];
    CGFloat mediaDescriptionX = [self computeRatio:16 forDimension:screenWidth];
    UITextView *mediaDescription = [[UITextView alloc] initWithFrame:CGRectMake(mediaDescriptionX, CGRectGetMinY(imgMedia.frame) + CGRectGetHeight(imgMedia.frame), mediaDescriptionWidth, [self computeRatio:416 forDimension:screenHeight])];
    mediaDescription.text = data[@"Plot"];
    mediaDescription.textColor = [UIColor whiteColor];
    mediaDescription.editable = NO;
    mediaDescription.selectable = YES;
    mediaDescription.delegate = self;
    mediaDescription.backgroundColor = [UIColor clearColor];
    mediaDescription.alpha = 0;
//    mediaDescription.transform = CGAffineTransformMakeScale(0.7, 0.7);
    mediaDescription.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [self.view addSubview:mediaDescription];
    
    CGRect frame = mediaDescription.frame;
    frame.size.height = mediaDescription.contentSize.height;
    mediaDescription.frame = frame;
    
    [UIView animateWithDuration:0.3 delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         mediaDescription.alpha = 1;
//                         mediaDescription.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                         mediaDescription.transform = CGAffineTransformMakeScale(1, 1);
                         
                         imgMedia.alpha = 1;
                         imgMedia.frame = CGRectMake(0, 0, screenWidth, imgMediaHeight);
//                         imgMedia.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                     }
                     completion:^(BOOL finished){
                     }];
    
    UIButton *addToFavsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // User have this media amongst their list
    if ([userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] != [NSNull null] && [[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] containsObject:self.mediaDatas] == YES) {
        [addToFavsButton addTarget:self action:@selector(removeMediaToUserList:) forControlEvents:UIControlEventTouchUpInside];
        [addToFavsButton setTitle:@"Retirer à sa liste" forState:UIControlStateNormal];
//        addMediaBtnItem.enabled = NO;
        
//        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    } else {

//        addMediaBtnItem.enabled = YES;
        
//        self.navigationItem.rightBarButtonItem.enabled = YES;
        
//        NSLog(@"%@", NSStringFromClass([[userTasteDict objectForKey:[self.mediaDatas objectForKey:@"type"]] class]));
        if ([userTasteDict objectForKey:[self.mediaDatas objectForKey:@"type"]] != [NSNull null]) {
            if ([[userTasteDict objectForKey:[self.mediaDatas objectForKey:@"type"]] count] >= 5) {
                //            [addToFavsButton setBackgroundImage:<#(UIImage *)#> forState:<#(UIControlState)#>]
                addToFavsButton.enabled = NO;
            }
        }
    }
    
    [addToFavsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    addToFavsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 36, 0, 0);
    addToFavsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    addToFavsButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0f];
    addToFavsButton.frame = CGRectMake(0, screenHeight - [self computeRatio:222.0 forDimension:screenHeight], screenWidth, 43);
    addToFavsButton.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:addToFavsButton];
    

    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton addTarget:self action:@selector(displayBuyScreen) forControlEvents:UIControlEventTouchUpInside];
    [buyButton setTitle:[NSLocalizedString(@"buy", nil) uppercaseString] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0f];
    buyButton.frame = CGRectMake(0, screenHeight - 43, screenWidth, 43);
    buyButton.backgroundColor = [UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f];
    [self.view addSubview:buyButton];
    
    [loadingIndicator stopAnimating];
}


- (UIMotionEffectGroup*) UIMotionEffectGroupwithValue:(int)aInt
{
    UIInterpolatingMotionEffect *xAxis;
    xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                            type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    xAxis.minimumRelativeValue = [NSNumber numberWithInt:aInt*-1];
    xAxis.maximumRelativeValue = [NSNumber numberWithInt:aInt];
    
    UIInterpolatingMotionEffect *yAxis;
    yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    yAxis.minimumRelativeValue = [NSNumber numberWithInt:aInt*-1];
    yAxis.maximumRelativeValue = [NSNumber numberWithInt:aInt];
    
    UIMotionEffectGroup *motionGroup = [[UIMotionEffectGroup alloc] init];
    motionGroup.motionEffects = @[xAxis];
    
    return motionGroup;
}

- (void) displayBuyScreen
{
    // We don't need uinavigationcontroller so...
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIView *displayBuyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    displayBuyView.tag = 1;
    displayBuyView.hidden = NO;
    displayBuyView.alpha = .25f;
    displayBuyView.backgroundColor = [UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f];

    
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage: [self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = .85f;
    [bluredImageView setFrame:displayBuyView.frame];

    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = bluredImageView.bounds;
    
    [bluredImageView addSubview:visualEffectView];
    
    [displayBuyView addSubview:bluredImageView];
    
    BOOL doesContain = [self.view.subviews containsObject:(UIView*)[self.view viewWithTag:1]];
    UIView *displayBuyViewAlias = (UIView*)[self.view viewWithTag:1];
    if (doesContain == YES) {
        displayBuyViewAlias.hidden = NO;
    } else {
       [self.view addSubview:displayBuyView];
    }
    
    [UIView animateWithDuration:0.4 delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         displayBuyView.alpha = 1;
                         displayBuyViewAlias.alpha = 1;
                     }
                     completion:nil];
    

    UILabel *titleBuyMedia = [[UILabel alloc] initWithFrame:CGRectMake(0, [self computeRatio:86 forDimension:screenHeight], screenWidth, 16.0f)];
    titleBuyMedia.textColor = [UIColor whiteColor];
    titleBuyMedia.backgroundColor = [UIColor clearColor];
    titleBuyMedia.text = [[NSString stringWithFormat:NSLocalizedString(@"buy %@", nil), self.mediaDatas[@"name"]] uppercaseString];
    titleBuyMedia.font = [UIFont fontWithName:@"Helvetica-Neue" size:19.0f];
    titleBuyMedia.textAlignment = NSTextAlignmentCenter;
    [displayBuyView addSubview:titleBuyMedia];
    
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica" size:18.0f];
    CGSize buttonSize = CGSizeMake([self computeRatio:574 forDimension:screenWidth], 41.0f);
    CGPoint buttonPos = CGPointMake([self computeRatio:34 forDimension:screenWidth], [self computeRatio:190 forDimension:screenHeight]);
    
    
    UIColor *amazonOrange = [UIColor colorWithRed:1 green:(124.0f/255.0f) blue:(2.0f/255.0f) alpha:1.0f];
    
    ShopButton *amazonBuyButton = [ShopButton buttonWithType:UIButtonTypeCustom];
    amazonBuyButton.tag = 400;
    [amazonBuyButton addTarget:self action:@selector(openStore:) forControlEvents:UIControlEventTouchUpInside];
    [amazonBuyButton setTitle:[@"Amazon" uppercaseString] forState:UIControlStateNormal];
    [amazonBuyButton setTitleColor:amazonOrange forState:UIControlStateNormal];
    amazonBuyButton.titleLabel.font = buttonFont;
    amazonBuyButton.frame = CGRectMake(buttonPos.x, buttonPos.y, buttonSize.width, buttonSize.height);
    amazonBuyButton.backgroundColor = [UIColor clearColor];
    amazonBuyButton.layer.borderColor = amazonOrange.CGColor;
    amazonBuyButton.layer.borderWidth = 2.0f;
    [displayBuyView addSubview:amazonBuyButton];
    

    
    CGFloat itunesBuyButtonPosY = amazonBuyButton.frame.origin.y + amazonBuyButton.frame.size.height + (38/2);
    UIColor *itunesGray = [UIColor colorWithRed:(166.0f/255.0f) green:(166.0f/255.0f) blue:(166.0f/255.0f) alpha:1.0f];
    
    ShopButton *itunesBuyButton = [ShopButton buttonWithType:UIButtonTypeCustom];
    itunesBuyButton.tag = 401;
    [itunesBuyButton addTarget:self action:@selector(openStore:) forControlEvents:UIControlEventTouchUpInside];
    [itunesBuyButton setTitle:[@"itunes" uppercaseString] forState:UIControlStateNormal];
    itunesBuyButton.titleLabel.font = buttonFont;
    [itunesBuyButton setTitleColor:itunesGray forState:UIControlStateNormal];
    itunesBuyButton.frame = CGRectMake(buttonPos.x, itunesBuyButtonPosY, buttonSize.width, buttonSize.height);
    itunesBuyButton.backgroundColor = [UIColor clearColor];
    itunesBuyButton.layer.borderColor = itunesGray.CGColor;
    itunesBuyButton.layer.borderWidth = 2.0f;
    [displayBuyView addSubview:itunesBuyButton];
    
    UIView* barrier = [[UIView alloc] initWithFrame:CGRectMake(0, amazonBuyButton.frame.origin.y + amazonBuyButton.frame.size.height + 7, 5, 3)]; // w: 25
    barrier.tag = 2;
    barrier.backgroundColor = [UIColor colorWithWhite:1 alpha:.15];
    [displayBuyView addSubview:barrier];
    
    
    CGRect lineFrame = CGRectMake(0, 18, 35, 4);
    
    
    UIButton *crossButton = [UIButton buttonWithType:UIButtonTypeCustom];
    crossButton.frame = CGRectMake([self computeRatio:250 forDimension:screenWidth], screenHeight - [self computeRatio:116 forDimension:screenHeight], 50, 50);
    [crossButton addTarget:self action:@selector(hideBuyScreen) forControlEvents:UIControlEventTouchUpInside];
    crossButton.backgroundColor = [UIColor clearColor];
    crossButton.layer.borderColor = [UIColor whiteColor].CGColor;
    crossButton.layer.borderWidth = 1.0f;
    crossButton.layer.cornerRadius = 25;
    crossButton.center = CGPointMake(self.view.center.x, crossButton.frame.origin.y);
    [displayBuyView addSubview:crossButton];
    
    UIView *lineRight = [[UIView alloc] initWithFrame:lineFrame];
    lineRight.backgroundColor = [UIColor whiteColor];
    lineRight.center = CGPointMake(crossButton.frame.size.width / 2, crossButton.frame.size.height / 2);
    lineRight.transform = CGAffineTransformMakeRotation(DegreesToRadians(-45));
    lineRight.userInteractionEnabled = NO;
    [crossButton addSubview:lineRight];
    
    UIView *lineLeft = [[UIView alloc] initWithFrame:lineFrame];
    lineLeft.backgroundColor = [UIColor whiteColor];
    lineLeft.userInteractionEnabled = NO;
    lineLeft.center = CGPointMake(crossButton.frame.size.width / 2, crossButton.frame.size.height / 2);
    lineLeft.transform = CGAffineTransformMakeRotation(DegreesToRadians(45));
    [crossButton addSubview:lineLeft];
    
    
    // Create array of all shop buttons one time only
    if (self.isPhysicsAdded == NO) {
        for (ShopButton *shopButton in displayBuyView.subviews) {
            if ([shopButton isKindOfClass:[ShopButton class]]) {
                [buyButtonsInitPositions addObject:[NSValue valueWithCGRect:shopButton.frame]];
            }
        }
    }
}

- (void) addPhysics
{
//    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];
    UIView *barrier = (UIView*)[self.view viewWithTag:2];
    
    ShopButton *amazonBuyButton = (ShopButton*)[self.view viewWithTag:400];
    ShopButton *itunesBuyButton = (ShopButton*)[self.view viewWithTag:401];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    gravity = [[UIGravityBehavior alloc] initWithItems:@[amazonBuyButton]];
    collision = [[UICollisionBehavior alloc] initWithItems:@[amazonBuyButton, itunesBuyButton]];
    collision.collisionDelegate = self;
    
    UIDynamicItemBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[amazonBuyButton, itunesBuyButton]];
    itemBehaviour.elasticity = 0.9;
    itemBehaviour.allowsRotation = NO;
    itemBehaviour.density = .4000;
    
    [animator addBehavior:gravity];
    [animator addBehavior:itemBehaviour];
    [animator addBehavior:collision];
    

    CGPoint rightEdge = CGPointMake(barrier.frame.origin.x +
                                    barrier.frame.size.width, barrier.frame.origin.y);
    [collision addBoundaryWithIdentifier:@"barrier"
                               fromPoint:barrier.frame.origin
                                 toPoint:rightEdge];
    
    self.PhysicsAdded = YES;
}

- (void) hideBuyScreen
{
    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];
    
//    ShopButton *amazonBuyButton = (ShopButton*)[self.view viewWithTag:400];
//    ShopButton *itunesBuyButton = (ShopButton*)[self.view viewWithTag:401];
    
    [self addPhysics];
    
    [UIView animateWithDuration:0.7 delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         displayBuyView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         displayBuyView.hidden = YES;
                         
                         // We need uinavigationcontroller so...
                         [self.navigationController setNavigationBarHidden:NO];

                         
                         NSUInteger count = 0;
                         // shopButton.frame = [(UIView *)[buyButtonsInitPositions objectAtIndex:count] frame];
                         // shopButton.frame = [[buyButtonsInitPositions objectAtIndex:count] CGRectValue];
                         for (ShopButton *shopButton in displayBuyView.subviews) {
                             if ([shopButton isKindOfClass:[ShopButton class]]) {
//                                 ShopButton *foo = (ShopButton *)[buyButtonsInitPositions objectAtIndex:count];
//                                 shopButton.frame = [(ShopButton *)[buyButtonsInitPositions objectAtIndex:count] frame];
                                 shopButton.frame = [[buyButtonsInitPositions objectAtIndex:count] CGRectValue];
                                 count++;
                             }
                         }
                         [animator removeAllBehaviors];
                     }];
}

- (UIImage *) takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) addAndRemoveMediaToList:(UIBarButtonItem*) sender
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    UILabel *addRemoveMediaLabel = (UILabel*)[infoMediaView viewWithTag:3];
    addRemoveMediaLabel.hidden = NO;
    addRemoveMediaLabel.alpha = 1;
    
    if ([sender.image isEqual:[UIImage imageNamed:@"meetingFavoriteUnselected"]]) {
        sender.image = [UIImage imageNamed:@"meetingFavoriteSelected"];
        [self addMediaToUserList];
        addRemoveMediaLabel.text = NSLocalizedString(@"Added", nil);
    }else{
        sender.image = [UIImage imageNamed:@"meetingFavoriteUnselected"];
        [self removeMediaToUserList];
        addRemoveMediaLabel.text = NSLocalizedString(@"Deleted", nil);
    }
    
    [UIView animateWithDuration:0.6 delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         addRemoveMediaLabel.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         addRemoveMediaLabel.hidden = YES;
                     }];
}

- (void) addMediaToUserList
{
    // If the value of the key is nil so we create an new NSArray that contains the first elmt of the category
    if ([userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] == [NSNull null]) {
        NSArray *firstEntryToCategory = [[NSArray alloc] initWithObjects:self.mediaDatas, nil];
        [userTasteDict setObject:firstEntryToCategory forKey:[self.mediaDatas valueForKey:@"type"]];
    } else {
        NSMutableArray *updatedUserTaste = [[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] mutableCopy];
        [updatedUserTaste addObject:self.mediaDatas];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortedCategory = [updatedUserTaste sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];

        [userTasteDict removeObjectForKey:[self.mediaDatas valueForKey:@"type"]];
        [userTasteDict setObject:sortedCategory forKey:[self.mediaDatas valueForKey:@"type"]];
    }
    
    [self saveMediaUpdate];
}

- (void) removeMediaToUserList
{
    NSMutableArray *updatedUserTaste = [[userTasteDict objectForKey:[self.mediaDatas valueForKey:@"type"]] mutableCopy];
    [updatedUserTaste removeObject:self.mediaDatas];
    [userTasteDict removeObjectForKey:[self.mediaDatas valueForKey:@"type"]];
    [userTasteDict setObject:updatedUserTaste forKey:[self.mediaDatas valueForKey:@"type"]];
    
    [self saveMediaUpdate];
}

- (void) saveMediaUpdate
{
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbid == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserID"]];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        UserTaste *userTaste = [UserTaste MR_findFirstWithPredicate:userPredicate inContext:localContext];
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:userTasteDict];
        userTaste.taste = arrayData;
    } completion:^(BOOL success, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(userListHaveBeenUpdate:)]) {
            [self.delegate userListHaveBeenUpdate:userTasteDict];
        }
//        else {
//            ViewController *vc = [[ViewController alloc] init];
//            [vc userListHaveBeenUpdate:userTasteDict];
//        }
        // 7 secondes after update user list we update the database with new datas
        [self performSelector:@selector(updateServerDatasForFbIDTimer) withObject:nil afterDelay:7.0];
    }];
}


- (void) updateServerDatasForFbIDTimer
{
    [self updateServerDatasForFbID:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserID"]];
}

// This methods allows to retrieve and send (?) user datas from the server
- (void) updateServerDatasForFbID:(NSNumber*)userfbID
{
    if (self.isConnectedToInternet == NO)
        return;
        
    NSURL *aUrl = [NSURL URLWithString:@"http://192.168.1.55:8888/Share/updateDatas.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    // We send the json to the server only when we need it
    NSString *userTasteJSON = [self updateTasteForServer];

    NSString *postString = [NSString stringWithFormat:@"fbiduser=%@&userTaste=%@", userfbID, userTasteJSON];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Getting your response string
    
    if (self.responseData != nil) {
        
        self.responseData = nil;
        self.responseData = [NSMutableData new];
    }
}


// This method retrieve an readable json of user taste for the database
- (NSString *) updateTasteForServer
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userTasteDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        UIAlertView *errorServer = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"La synchronisation avec le serveur n'a pas pu avoir lieu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorServer show];
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return jsonString;
    }
}

- (void) openStore:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.duckduckgo.com"]];
}

- (CGFloat) computeRatio:(CGFloat)aNumber forDimension:(CGFloat)aDimension
{
    CGFloat ratio = 0;
    ratio = ((aNumber * 100)/aDimension);
    ratio = ((ratio*aDimension)/100);
    
    if ([UIScreen mainScreen].scale > 2.1) {
        
        ratio = ratio/3; // Because we are in retina HD
        
    } else {
        ratio = ratio/2; // Because we are in retina
    }
    
    return roundf(ratio);
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
