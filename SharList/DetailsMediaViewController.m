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

@implementation DetailsMediaViewController

- (void) viewWillAppear:(BOOL)animated {
//    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"appBG"]]];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIImageView *imgMedia = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bb"]];
    CGFloat imgMediaHeight = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:470 forDimension:screenHeight];
    imgMedia.frame = CGRectMake(0, 0, screenWidth, imgMediaHeight);
    imgMedia.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imgMedia];
    
    CCARadialGradientLayer *radialGradientLayer = [CCARadialGradientLayer layer];
    radialGradientLayer.gradientOrigin = imgMedia.center;
    radialGradientLayer.gradientRadius = 196;
    radialGradientLayer.colors = @[
                                   (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.001] CGColor],
                                   (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.001] CGColor],
                                   (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.015] CGColor],
                                   (id)UIColorFromRGB(0x000000).CGColor
                                   ];
    radialGradientLayer.locations = @[@0, @0.3, @0.4, @1];
    radialGradientLayer.frame = imgMedia.bounds;
    [imgMedia.layer insertSublayer:radialGradientLayer atIndex:0];

    
    UIView *infoMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, imgMediaHeight)];
    [imgMedia addSubview:infoMediaView];
    
    CGFloat mediaTitleLabelY = imgMediaHeight - [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:108 forDimension:imgMediaHeight];
    UILabel *mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, mediaTitleLabelY, screenWidth, 20)];
    mediaTitleLabel.text = @"Breaking Bad";
    mediaTitleLabel.textColor = [UIColor whiteColor];
    mediaTitleLabel.textAlignment = NSTextAlignmentCenter;
    mediaTitleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0];
    [infoMediaView addSubview:mediaTitleLabel];
    
    CGFloat mediaDescriptionWidth = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:608 forDimension:screenWidth];
    CGFloat mediaDescriptionX = [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:16 forDimension:screenWidth];
    UITextView *mediaDescription = [[UITextView alloc] initWithFrame:CGRectMake(mediaDescriptionX, CGRectGetMinY(imgMedia.frame) + CGRectGetHeight(imgMedia.frame) + 15, mediaDescriptionWidth, 100)];
    mediaDescription.text = @"Walter « Walt » White est professeur de chimie dans un lycée, et vit avec son fils handicapé et sa femme enceinte à Albuquerque, au Nouveau-Mexique. Lorsqu'on lui diagnostique un cancer du poumon en phase terminale avec une espérance de vie estimée à deux ans, tout s'effondre pour lui. Il décide alors de mettre en place un laboratoire et un trafic de méthamphétamine pour assurer un avenir financier confortable à sa famille après sa mort, en s'associant à Jesse Pinkman, un de ses anciens élèves devenu petit trafiquant.";
    mediaDescription.textColor = [UIColor colorWithRed:(26.0f/255.0f) green:(26.0f/255.0f) blue:(26.0f/255.0f) alpha:1];
    mediaDescription.editable = NO;
    mediaDescription.selectable = YES;
    mediaDescription.delegate = self;
//    mediaDescription.scrollEnabled = NO;
    [mediaDescription sizeToFit];
    mediaDescription.backgroundColor = [UIColor clearColor];
    mediaDescription.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self.view addSubview:mediaDescription];
    
    
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchUpInside];
    [buyButton setTitle:@"Acheter" forState:UIControlStateNormal];
    buyButton.frame = CGRectMake(0, screenHeight - 104, screenWidth, 42);
    buyButton.backgroundColor = [UIColor purpleColor];
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
    motionGroup.motionEffects = @[xAxis, yAxis];
    
    return motionGroup;
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
