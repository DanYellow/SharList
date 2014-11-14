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
    
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = imgMedia.bounds;
//    gradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.75] CGColor]];
//    [imgMedia.layer insertSublayer:gradient atIndex:0];
    
    CCARadialGradientLayer *radialGradientLayer = [CCARadialGradientLayer layer];
    radialGradientLayer.gradientOrigin = imgMedia.center;
    radialGradientLayer.gradientRadius = 196;
    radialGradientLayer.colors = @[
                                   (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:.005] CGColor],
                                   (id)[[UIColor clearColor] CGColor],
                                   (id)[[UIColor clearColor] CGColor],
                                   (id)UIColorFromRGB(0x000000).CGColor,
                                   ];
    radialGradientLayer.locations = @[@0, @0.3, @0.5, @1];
    radialGradientLayer.frame = imgMedia.bounds;
    [imgMedia.layer insertSublayer:radialGradientLayer atIndex:0];

    
    UIView *infoMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, imgMediaHeight)];
    [imgMedia addSubview:infoMediaView];
    
    CGFloat mediaTitleLabelY = imgMediaHeight - [(AppDelegate *)[[UIApplication sharedApplication] delegate] computeRatio:70 forDimension:imgMediaHeight];
    UILabel *mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, mediaTitleLabelY, screenWidth, 20)];
    mediaTitleLabel.text = @"Breaking Bad";
    mediaTitleLabel.textColor = [UIColor whiteColor];
    mediaTitleLabel.textAlignment = NSTextAlignmentCenter;
    mediaTitleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0];
    [infoMediaView addSubview:mediaTitleLabel];
    
    
//    UIView *buyButton = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 42, screenWidth, 42)];
//    buyButton.backgroundColor = [UIColor purpleColor];
//    buyButton
    
    
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchUpInside];
    [buyButton setTitle:@"Acheter" forState:UIControlStateNormal];
    buyButton.frame = CGRectMake(0, screenHeight - 120, screenWidth, 42);
    CGFloat buyButtonY = screenHeight - buyButton.frame.size.height;
    buyButton.frame = CGRectMake(0, buyButtonY, screenWidth, 42);
    buyButton.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:buyButton];
}

- (void) aMethod:(UIButton*)sender
{
    NSLog(@"foo");
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
