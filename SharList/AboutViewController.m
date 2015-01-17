//
//  AboutViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 11/12/2014.
//  Copyright (c) 2014 Jean-Louis Danielo. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    self.title = NSLocalizedString(@"About", nil);

    
    //Main screen display
    [self.view setBackgroundColor:[UIColor colorWithRed:(17.0/255.0f) green:(27.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f]];
    
    
    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    UIColor *topGradientView = [UIColor colorWithRed:(29.0f/255.0f) green:(82.0/255.0f) blue:(107.0f/255.0f) alpha:1];
    UIColor *bottomGradientView = [UIColor colorWithRed:(4.0f/255.0f) green:(49.0/255.0f) blue:(70.0f/255.0f) alpha:1];
    gradient.colors = [NSArray arrayWithObjects:(id)[topGradientView CGColor], (id)[bottomGradientView CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    UILabel *whatIsApp = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, screenWidth - 10, 0)];
    whatIsApp.text = NSLocalizedString(@"whatIsApp", nil);
    whatIsApp.numberOfLines = 0;
    whatIsApp.lineBreakMode = NSLineBreakByWordWrapping;
    whatIsApp.textColor = [UIColor whiteColor];
    whatIsApp.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    [whatIsApp heightToFit];
    [self.view addSubview:whatIsApp];
    
    UIView *creditsTextView = [[UIView alloc] initWithFrame:CGRectMake(10, whatIsApp.frame.origin.y + whatIsApp.frame.size.height + 25, screenWidth - 10, 30)];
    creditsTextView.backgroundColor = [UIColor clearColor];
    creditsTextView.opaque = YES;
    [creditsTextView sizeToFit];
    [self.view addSubview:creditsTextView];
    
    UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 10, 20)];
    creditsLabel.text = NSLocalizedString(@"Credits", nil);
    creditsLabel.textColor = [UIColor whiteColor];
    creditsLabel.backgroundColor = [UIColor clearColor];
    creditsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    [creditsTextView addSubview:creditsLabel];
    
    UITextView *creditsText = [[UITextView alloc] initWithFrame:CGRectMake(0, creditsLabel.frame.origin.y + creditsLabel.frame.size.height + 5, screenWidth - 10, 30)];
    creditsText.textColor = [UIColor whiteColor];
    creditsText.backgroundColor = [UIColor clearColor];
    creditsText.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    creditsText.text = NSLocalizedString(@"datasOrigins", nil);
    creditsText.dataDetectorTypes = UIDataDetectorTypeAll;
    creditsText.editable = NO;
    [creditsText sizeToFit];
    creditsText.textAlignment = NSTextAlignmentLeft;
    creditsText.contentInset = UIEdgeInsetsMake(-6, -3, 0, 0);
    [creditsTextView addSubview:creditsText];
    
    
//    UIView *privacyTextViews = [[UIView alloc] initWithFrame:CGRectMake(10, creditsTextView.frame.origin.y + creditsTextView.frame.size.height + 40, screenWidth - 10, 30)];
//    privacyTextViews.backgroundColor = [UIColor clearColor];
//    privacyTextViews.opaque = YES;
//    [privacyTextViews sizeToFit];
//    [self.view addSubview:privacyTextViews];
//    
//    UILabel *privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 10, 20)];
//    privacyLabel.text = NSLocalizedString(@"Privacy", nil);
//    privacyLabel.textColor = [UIColor whiteColor];
//    privacyLabel.backgroundColor = [UIColor clearColor];
//    privacyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
//    [privacyTextViews addSubview:privacyLabel];
//
//    UITextView *privacyText = [[UITextView alloc] initWithFrame:CGRectMake(0, privacyLabel.frame.origin.y + privacyLabel.frame.size.height + 5, screenWidth - 10, 30)];
//    privacyText.textColor = [UIColor whiteColor];
//    privacyText.backgroundColor = [UIColor clearColor];
//    privacyText.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
//    privacyText.text = NSLocalizedString(@"PrivacyContent", nil);
//    privacyText.dataDetectorTypes = UIDataDetectorTypeAll;
//    privacyText.editable = NO;
//    [privacyText sizeToFit];
//    privacyText.textAlignment = NSTextAlignmentLeft;
//    privacyText.contentInset = UIEdgeInsetsMake(-6, -3, 0, 0);
//    [privacyTextViews addSubview:privacyText];
    
    
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    NSString *aboutApp = [NSString stringWithFormat:@"%@ \r %@", [settingsDict valueForKey:@"appversion"], [settingsDict valueForKey:@"contactShound"]];
//    aboutApp = [aboutApp stringByAppendingString:@"\n"];
//    aboutApp = [aboutApp stringByAppendingString:];
    
    UITextView *contactShound = [[UITextView alloc] initWithFrame:CGRectMake(0, screenHeight - ((49 * 3) + 30), screenWidth, 80)];
    contactShound.text = aboutApp;
    contactShound.textColor = [UIColor whiteColor];
    contactShound.textAlignment = NSTextAlignmentCenter;
    contactShound.dataDetectorTypes = UIDataDetectorTypeAll;
    contactShound.editable = NO;
    contactShound.backgroundColor = [UIColor clearColor];
    contactShound.opaque = YES;
    contactShound.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    contactShound.tintColor = [UIColor colorWithRed:(221.0/255.0f) green:(214.0f/255.0f) blue:(227.0f/255.0f) alpha:.95f];
//    [contactShound sizeToFit];
    [self.view addSubview:contactShound];
}

- (void) foo {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
