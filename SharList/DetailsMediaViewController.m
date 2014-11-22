//
//  DetailsMediaViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 10/11/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "DetailsMediaViewController.h"

@interface DetailsMediaViewController ()

@end

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



// Tag list
// 1 : displayBuyView (blurred view)
// 2 :

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    // Init vars
    self.PhysicsAdded = NO;
    buyButtonsInitPositions = [[NSMutableArray alloc] init];
    
    //Navigationbarcontroller
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMediaToUserList)];
    
    __block NSDictionary *datasFromServer;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *linkAPI = @"http://www.omdbapi.com/?i=";
    if (self.mediaDatas[@"imdbID"]) {
        linkAPI = [linkAPI stringByAppendingString:self.mediaDatas[@"imdbID"]];
    } else {
        linkAPI = [linkAPI stringByAppendingString:@"tt0903747"]; //Avengers
    }
    linkAPI = [linkAPI stringByAppendingString:@"&plot=short&r=json"];
    
    [manager GET:linkAPI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        datasFromServer = [[NSDictionary alloc] initWithDictionary:responseObject];
        [self setMediaViewForData:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        UIAlertView
    }];
    
    CGFloat imgMediaHeight = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:470 forDimension:screenHeight];
    
    UIView *infoMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, imgMediaHeight)];
    infoMediaView.tag = 2;
    
    CGFloat mediaTitleLabelY = imgMediaHeight - [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:108 forDimension:imgMediaHeight];
    UILabel *mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, mediaTitleLabelY, screenWidth, 20)];
    mediaTitleLabel.text = self.mediaDatas[@"name"];
    mediaTitleLabel.textColor = [UIColor whiteColor];
    mediaTitleLabel.textAlignment = NSTextAlignmentCenter;
    mediaTitleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    mediaTitleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    mediaTitleLabel.layer.shadowRadius = 2.5;
    mediaTitleLabel.layer.shadowOpacity = 0.75;
    mediaTitleLabel.clipsToBounds = NO;
    mediaTitleLabel.layer.masksToBounds = NO;
    mediaTitleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:22.0];
    [mediaTitleLabel addMotionEffect:[self UIMotionEffectGroupwithValue:7]];
    
    [infoMediaView insertSubview:mediaTitleLabel atIndex:9];
    [self.view addSubview:infoMediaView];
}

- (void) setMediaViewForData:(NSDictionary*)data
{
    UIView *infoMediaView = (UIView*)[self.view viewWithTag:2];
    
    // Design of the page
    UIImageView *imgMedia = [UIImageView new];
        [imgMedia setImageWithURL:
         [NSURL URLWithString:data[@"Poster"]]
                 placeholderImage:[UIImage imageNamed:@"bb"]];
    CGFloat imgMediaHeight = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:470 forDimension:screenHeight];
    imgMedia.frame = CGRectMake(0, 0, screenWidth, imgMediaHeight);
    imgMedia.contentMode = UIViewContentModeScaleAspectFill;
    imgMedia.clipsToBounds = YES;
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
    
    
    CGFloat mediaDescriptionWidth = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:608 forDimension:screenWidth];
    CGFloat mediaDescriptionX = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:16 forDimension:screenWidth];
    UITextView *mediaDescription = [[UITextView alloc] initWithFrame:CGRectMake(mediaDescriptionX, CGRectGetMinY(imgMedia.frame) + CGRectGetHeight(imgMedia.frame) + 15, mediaDescriptionWidth, 100)];
    mediaDescription.text = data[@"Plot"];
    mediaDescription.textColor = [UIColor whiteColor];
    mediaDescription.editable = NO;
    mediaDescription.selectable = YES;
    mediaDescription.delegate = self;
    //    mediaDescription.scrollEnabled = NO;
    [mediaDescription sizeToFit];
    mediaDescription.backgroundColor = [UIColor clearColor];
    mediaDescription.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self.view addSubview:mediaDescription];
    
    
    
    
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton addTarget:self action:@selector(displayBuyScreen) forControlEvents:UIControlEventTouchUpInside];
    [buyButton setTitle:[@"Acheter" uppercaseString] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0f];
    buyButton.frame = CGRectMake(0, screenHeight - 43, screenWidth, 43);
    buyButton.backgroundColor = [UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f];
    [self.view addSubview:buyButton];
}


- (void) aMethod:(UIButton*)sender
{
    NSLog(@"foo");
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
    

    UILabel *titleBuyMedia = [[UILabel alloc] initWithFrame:CGRectMake(0, [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:86 forDimension:screenHeight], screenWidth, 16.0f)];
    titleBuyMedia.textColor = [UIColor whiteColor];
    titleBuyMedia.backgroundColor = [UIColor clearColor];
    titleBuyMedia.text = [[NSString stringWithFormat:@"Acheter %@", @"Breaking Bad"] uppercaseString];
    titleBuyMedia.font = [UIFont fontWithName:@"Helvetica-Neue" size:19.0f];
    titleBuyMedia.textAlignment = NSTextAlignmentCenter;
    [displayBuyView addSubview:titleBuyMedia];
    
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica" size:18.0f];
    CGSize buttonSize = CGSizeMake([(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:574 forDimension:screenWidth], 41.0f);
    CGPoint buttonPos = CGPointMake([(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:34 forDimension:screenWidth], [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:190 forDimension:screenHeight]);
    
    
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
    crossButton.frame = CGRectMake([(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:250 forDimension:screenWidth], screenHeight - [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:116 forDimension:screenHeight], 50, 50);
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
                // [NSValue valueWithCGRect:shopButton.frame]
                NSLog(@"start : %@", NSStringFromCGRect(shopButton.frame));
                [buyButtonsInitPositions addObject:[NSValue valueWithCGRect:shopButton.frame]];
            }
        }
    }
}

- (void) addPhysics
{
    UIView *displayBuyView = (UIView*)[self.view viewWithTag:1];
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
    
    ShopButton *amazonBuyButton = (ShopButton*)[self.view viewWithTag:400];
    ShopButton *itunesBuyButton = (ShopButton*)[self.view viewWithTag:401];
    
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
//                                 NSLog(@"array : end, %@", NSStringFromCGRect(foo.frame));
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

- (void) addMediaToUserList
{
    
}

- (void) openStore:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.duckduckgo.com"]];
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
