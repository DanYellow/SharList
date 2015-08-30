//
//  MediaMessagesViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 16/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "MediaCommentsViewController.h"

@interface MediaCommentsViewController ()

@property(strong, nonatomic) NSMutableArray *comments;
@property (nonatomic, assign, getter=ishavingComment) BOOL havingComment;

@end

#pragma mark - tag list references
// Tag list
// 1  : messagesTableView
// 2  : emptyTableView
// 3  : highlightMessagesSV
// 4  : searchLoadingIndicator
// 5  : UIPageControl
// 5678  : warningMessageView

@implementation MediaCommentsViewController

- (void)viewWillAppear:(BOOL)animated
{
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
    
    self.title = [NSLocalizedString(@"comments", nil) uppercaseString];
    
    self.hello = [NSNumber numberWithFloat:self.presentingViewController.splitViewController.primaryColumnWidth];
//    NSLog(@"x-hello : %@", self.hello);
//        NSLog(@"ref : %f", self.presentingViewController.splitViewController.primaryColumnWidth);
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    // Variables init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // self.presentingViewController.splitViewController.primaryColumnWidth
//    NSUInteger offsetWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 308 : 0;

    screenWidth = screenRect.size.width ;
    screenHeight = screenRect.size.height;
    
    self.havingComment = NO;
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    

    // http://stackoverflow.com/questions/26907352/how-to-draw-radial-gradients-in-a-calayer
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self easterEgg];
    });
    
    
    UIActivityIndicatorView *messagesLoadingIndicator = [UIActivityIndicatorView new];
    messagesLoadingIndicator.center = CGPointMake(screenWidth/2, self.view.center.y);
    messagesLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    messagesLoadingIndicator.hidesWhenStopped = YES;
    messagesLoadingIndicator.tag = 4;
    messagesLoadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    messagesLoadingIndicator.backgroundColor = [UIColor clearColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:messagesLoadingIndicator];
        [messagesLoadingIndicator startAnimating];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CommentsWarning"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CommentsWarning"];
            [self showWarningMessage];
        }
    });
    
    
    
    UIBarButtonItem *addEditCommentBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addMessageNavIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(postNewComment:)];
    self.navigationItem.rightBarButtonItem = addEditCommentBarBtn;
    

    [self loadComments];
    
//    [self easterEgg];
    
    
}

- (void) easterEgg
{
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGRect biggerRect = CGRectMake(0, 0, screenWidth, screenHeight);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    int radius = 23.0;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((screenWidth  - (2.0 * radius)) / 2, (screenHeight - (2.0 * radius)) / 2, 2.0 * radius, 2.0 * radius) cornerRadius:radius];
    [maskPath appendPath:circlePath];
    
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setFillColor:[[UIColor colorWithRed:(33.0f/255.0f) green:(33.0f/255.0f) blue:(33.0f/255.0f) alpha:1.0f] CGColor]];

    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    NSArray *colors = @[
                       (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                       (id)[[UIColor colorWithWhite:0 alpha:1] CGColor]
                       ];
    [gradientLayer setColors:colors];
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:.5], [NSNumber numberWithFloat:1.0]];
    
//    [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
//     [NSNumber numberWithFloat:20 / view.frame.size.height],
//     [NSNumber numberWithFloat:(view.frame.size.height - 20) / view.frame.size.height],
//     [NSNumber numberWithFloat:1.], nil]
    [gradientLayer setStartPoint:CGPointMake(0.5f, 0.5f)];
    [gradientLayer setEndPoint:CGPointMake(0.5f, 0.5f)];
    gradientLayer.frame = self.view.bounds;
//    gradientLayer.mask = maskWithHole;
    
    NSArray *colors2 = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithWhite:0 alpha:0] CGColor], (__bridge id)[[UIColor colorWithWhite:0 alpha:1] CGColor], nil];
    
//    NSArray *colors2 = [NSArray arrayWithObjects:(__bridge id)[[UIColor redColor] CGColor], (__bridge id)[[UIColor purpleColor] CGColor], nil];
    
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    [gradientLayer2 setFrame:[self.view bounds]];
    [gradientLayer2 setColors:colors2];
    [gradientLayer2 setStartPoint:CGPointMake(0.0f, 0.0f)];
//    [gradientLayer2 setEndPoint:CGPointMake(0.0f, 0.5f)];
    
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"endPoint"];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 50.5;
    pathAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.0f, 0.5f)];
    pathAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0f, 4.5f)];
    
    [gradientLayer2 addAnimation:pathAnimation forKey:@"endPoint"];
    [gradientLayer2 setEndPoint:CGPointMake(0.0f, 4.5f)];

    
    UIView *hellView = [[UIView alloc] initWithFrame:self.view.bounds];
//    hellView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
    hellView.backgroundColor = [UIColor redColor];
    hellView.alpha = 1;
    hellView.layer.mask = gradientLayer2;
//    [hellView.layer insertSublayer:gradientLayer atIndex:0];
    [self.view insertSubview:hellView atIndex:50];
}


- (void) displayComments
{
    // Table view
    UITableView *commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                                   70,
                                                                                   screenWidth,
                                                                                   CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tabBarController.tabBar.bounds) - 98)
                                                                  style:UITableViewStylePlain];
    commentsTableView.dataSource = self;
    commentsTableView.delegate = self;
    commentsTableView.backgroundColor = [UIColor clearColor];
    commentsTableView.tag = 1;
    commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    commentsTableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + 15, 0);
    commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    commentsTableView.allowsSelection = NO;
    commentsTableView.rowHeight = UITableViewAutomaticDimension;
    commentsTableView.estimatedRowHeight = 44.0;
    
    if (![commentsTableView isDescendantOfView:self.view]) {
        [self.view insertSubview:commentsTableView atIndex:1];
    }
   
    
    if ([self.comments count] >= 1) {
        [self displayDiscoverAndUserCommentForDatas];
    }
    
    // Empty list view
    UIView *emptyTableView = [[UIView alloc] initWithFrame:CGRectMake(0, (floorf(((screenHeight*30.80985915) / 100)) - 118), screenWidth, 120)];
    emptyTableView.backgroundColor = [UIColor clearColor];
    emptyTableView.tag = 2;
    emptyTableView.hidden = YES;
    emptyTableView.opaque = YES;
    [commentsTableView insertSubview:emptyTableView aboveSubview:commentsTableView];

    
    
    NSMutableAttributedString *WSQuoteAttrString = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"WSQuote", "William Shakespeare quote") uppercaseString] attributes:nil];
    NSRange hellStringRange = [[WSQuoteAttrString string] rangeOfString:[NSLocalizedString(@"hell", nil) uppercaseString]];
    [WSQuoteAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] range:NSMakeRange(hellStringRange.location, hellStringRange.length)];
    NSRange devilsStringRange = [[WSQuoteAttrString string] rangeOfString:[NSLocalizedString(@"devils", nil) uppercaseString]];
    [WSQuoteAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0] range:NSMakeRange(devilsStringRange.location, devilsStringRange.length)];
    
    UILabel *WSQuoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 36)];
    WSQuoteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    WSQuoteLabel.attributedText = WSQuoteAttrString;
    WSQuoteLabel.textColor = [UIColor whiteColor];
    WSQuoteLabel.numberOfLines = 2;
    WSQuoteLabel.textAlignment = NSTextAlignmentCenter;
    [WSQuoteLabel sizeToFit];
    WSQuoteLabel.backgroundColor = [UIColor clearColor];
    WSQuoteLabel.center = CGPointMake(screenWidth/2, WSQuoteLabel.center.y);
    
    [emptyTableView addSubview:WSQuoteLabel];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, WSQuoteLabel.frame.size.height + 11, screenWidth, 14)];
    authorLabel.text = @"W. Shakespeare";
    authorLabel.textAlignment = NSTextAlignmentCenter;
    authorLabel.textColor = [UIColor colorWithRed:(223.0/255) green:(223.0/255) blue:(223.0/255) alpha:1.0];
    authorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];

    [emptyTableView addSubview:authorLabel];
    

    UIImage *newCommentBtnImage = [[UIImage imageNamed:@"newMessageBtn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton *newCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newCommentBtn.frame = CGRectMake(0, authorLabel.frame.size.height + authorLabel.frame.origin.y + 28, 113, 113);
    newCommentBtn.tintColor = [UIColor colorWithRed:(223.0/255) green:(223.0/255) blue:(223.0/255) alpha:1.0];
    
    [newCommentBtn setImage:newCommentBtnImage forState:UIControlStateNormal];
    newCommentBtn.contentMode = UIViewContentModeScaleToFill;
    newCommentBtn.center = CGPointMake(screenWidth/2, newCommentBtn.center.y);
    newCommentBtn.backgroundColor = [UIColor clearColor];
    [newCommentBtn addTarget:self action:@selector(postNewComment:) forControlEvents:UIControlEventTouchUpInside];
 
    [emptyTableView addSubview:newCommentBtn];
    
    
    UIView *emptyViewLastView = emptyTableView.subviews.lastObject;
    CGRect emptyTableViewFrame = emptyTableView.frame;
    emptyTableViewFrame.size.height = emptyViewLastView.frame.size.height + emptyViewLastView.frame.origin.y;
    emptyTableView.frame = emptyTableViewFrame;
}

- (void) displayDiscoverAndUserCommentForDatas
{
    UITableView *commentsTableView = (UITableView*)[self.view viewWithTag:1];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 140)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIScrollView *highlightMessagesSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 140)];
    highlightMessagesSV.backgroundColor = [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:.3];
    highlightMessagesSV.center = CGPointMake(self.view.center.x, highlightMessagesSV.center.y);
    highlightMessagesSV.pagingEnabled = YES;
    highlightMessagesSV.delegate = self;
    highlightMessagesSV.tag = 3;
    highlightMessagesSV.showsHorizontalScrollIndicator = NO;
    
    if (![highlightMessagesSV isDescendantOfView:headerView]) {
        [headerView addSubview:highlightMessagesSV];
    }
    
    CALayer *highlightMessagesSVBottomBorder = [CALayer layer];
    highlightMessagesSVBottomBorder.frame = CGRectMake(-(highlightMessagesSV.frame.size.width / 2), highlightMessagesSV.frame.size.height - 1, screenWidth*3, 1.0f);
    highlightMessagesSVBottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [highlightMessagesSV.layer addSublayer:highlightMessagesSVBottomBorder];
    
    CALayer *highlightMessagesSVTopBorder = [CALayer layer];
    highlightMessagesSVTopBorder.frame = CGRectMake(-(highlightMessagesSV.frame.size.width / 2), 0, screenWidth*3, 1.0f);
    highlightMessagesSVTopBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [highlightMessagesSV.layer addSublayer:highlightMessagesSVTopBorder];
    
    UIView *headerViewLastView = [[headerView subviews] lastObject];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"by date", nil), NSLocalizedString(@"by relevance", nil)]];
    
    segmentedControl.frame = CGRectMake(10, CGRectGetMaxY(headerViewLastView.frame) + 9, screenWidth - 20, 30);
    [segmentedControl addTarget:self action:@selector(sortTableview:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor whiteColor];
    
    // There is no segmented control if there is only one comment
    if (![segmentedControl isDescendantOfView:headerView] && [self.comments count] > 1) {
        [headerView addSubview:segmentedControl];
    }
    
    headerViewLastView = [[headerView subviews] lastObject];
    
    headerView.frame = CGRectMake(0, 0, screenWidth, CGRectGetMaxY(headerViewLastView.frame) + 10);
    
    commentsTableView.tableHeaderView = headerView;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"];
    NSString *discoveryId = [NSString stringWithFormat:@"%@", self.userDiscoverId];
    
    // Manage the case which the user reach the page without a discover
    int loopIteration = 0;
    
    if (self.userDiscoverId) {
        loopIteration = 2;
    } else {
//        discoveryId = @"fb456745"; //10205919757172919 | fb456745
        loopIteration = 1;
    }
    
    highlightMessagesSV.contentSize = CGSizeMake(screenWidth*loopIteration, 140);
    
    UIPageControl *highlightMessagesPC = [[UIPageControl alloc] initWithFrame:CGRectMake(0, highlightMessagesSV.frame.size.height - 22, screenWidth, 20)];
    highlightMessagesPC.numberOfPages = loopIteration;
    highlightMessagesPC.currentPage = 0;
    highlightMessagesPC.tag = 5;
    highlightMessagesPC.hidesForSinglePage = YES;
    highlightMessagesPC.backgroundColor = [UIColor clearColor];
    [highlightMessagesPC addTarget:self action:@selector(changeComment:) forControlEvents:UIControlEventTouchUpInside];
    if (![highlightMessagesPC isDescendantOfView:headerView]) {
        [headerView addSubview:highlightMessagesPC];
    }
    
    
    // 10205919757172919
    // We check if the user met have made a comment
    NSPredicate *predicateDiscover = [NSPredicate predicateWithFormat:@"fbId == %@", discoveryId];
    NSArray *filteredDiscover = [[NSArray alloc] initWithArray:[self.comments filteredArrayUsingPredicate:predicateDiscover]];
    
    // We check if the current user has made a comment
    NSPredicate *predicateUser = [NSPredicate predicateWithFormat:@"fbId == %@", userId];
    NSArray *filteredUser = [[NSArray alloc] initWithArray:[self.comments filteredArrayUsingPredicate:predicateUser]];
    
    
    NSMutableArray *filteredDatas = [[NSMutableArray alloc] initWithArray:[filteredDiscover arrayByAddingObjectsFromArray:filteredUser]];

    
    
//    if ([filteredUser count] == 0) {
//        <#statements#>
//    }
    
    if (self.userDiscoverId) {
        
        if ([filteredDiscover count] == 0) {
            [filteredDatas insertObject:[NSNull null] atIndex:0];
        }
        
        if ([filteredUser count] == 0) {
            [filteredDatas insertObject:[NSNull null] atIndex:1];
        }
        
        // There no data for current user and the user discovered
        if ([filteredDatas count] == 0) {
            [filteredDatas insertObject:[NSNull null] atIndex:0];
            [filteredDatas insertObject:[NSNull null] atIndex:1];
        }
    }

    
    for (int i = 0; i < loopIteration; i++) {
        NSMutableDictionary *datas;
        if ( [filteredDatas count] > 0 && ![filteredDatas[i] isEqual:[NSNull null] ]) {
            datas = [[NSMutableDictionary alloc] initWithDictionary:filteredDatas[i]];
        }
        
        int discoverCommentViewLabelX = (screenWidth * i);
        
        CGRect discoverCommentViewFrame = highlightMessagesSV.frame;
        discoverCommentViewFrame.origin.x = discoverCommentViewLabelX;
        
        UIView *discoverCommentView = [[UIView alloc] initWithFrame:discoverCommentViewFrame];
        discoverCommentView.opaque = YES;
        discoverCommentView.backgroundColor = [UIColor clearColor];
        if (![discoverCommentView isDescendantOfView:highlightMessagesSV]) {
            [highlightMessagesSV addSubview:discoverCommentView];
        }
        
        UILabel *discoverCommentViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 18, screenWidth, 14)];
        discoverCommentViewLabel.textColor = [UIColor colorWithRed:(41.0/255.0) green:(41.0/255.0) blue:(41.0/255.0) alpha:1.0];
        discoverCommentViewLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0];
        
        if (![discoverCommentViewLabel isDescendantOfView:discoverCommentView]) {
            [discoverCommentView addSubview:discoverCommentViewLabel];
        }
        
        int discoverCommentViewTextViewY = discoverCommentViewLabel.frame.size.height + discoverCommentViewLabel.frame.origin.y + 6;
        UITextView *discoverCommentViewTextView = [[UITextView alloc] initWithFrame:CGRectMake(18, discoverCommentViewTextViewY, floorf(((screenWidth * 85.53125) / 100)), 70)];
        discoverCommentViewTextView.editable = NO;
        discoverCommentViewTextView.tag = 60;
        discoverCommentViewTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        discoverCommentViewTextView.textColor = [UIColor whiteColor];
        discoverCommentViewTextView.showsVerticalScrollIndicator = NO;
        discoverCommentViewTextView.contentInset = UIEdgeInsetsMake(-10, -5, 0, 0);
        discoverCommentViewTextView.scrollEnabled = NO;
        discoverCommentViewTextView.backgroundColor = [UIColor clearColor];
        if (![discoverCommentViewTextView isDescendantOfView:discoverCommentView]) {
            [discoverCommentView addSubview:discoverCommentViewTextView];
        }
        
        UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, discoverCommentView.frame.size.height - 20, discoverCommentView.frame.size.width - 21, 13)];
        dateMessageLabel.textAlignment = NSTextAlignmentRight;
        
        dateMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        dateMessageLabel.textColor = [UIColor colorWithRed:(41.0/255.0) green:(41.0/255.0) blue:(41.0/255.0) alpha:1.0];
        if (![dateMessageLabel isDescendantOfView:discoverCommentView]) {
            [discoverCommentView addSubview:dateMessageLabel];
        }
        
        
        if (datas) {
            // User has comment
            if ([userId isEqualToString:[datas valueForKeyPath:@"fbId"]]) {
                discoverCommentViewLabel.text = NSLocalizedString(@"comment user", nil);
                discoverCommentViewTextView.alpha = 1;
                self.havingComment = YES;
            } else {
                // It's an user's facebook friend
                if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:[datas valueForKeyPath:@"fbId"]]) {
                    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"id == %@", [filteredDatas[i] valueForKeyPath:@"fbId"]];
                    NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:friendPredicate];
                    NSString *facebookFriendName = (NSString*)[[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
                    discoverCommentViewLabel.text = [NSString stringWithFormat:NSLocalizedString(@"comment friend %@", nil), facebookFriendName];
                    discoverCommentViewTextView.alpha = 1;
                } else {
                    discoverCommentViewTextView.alpha = .01;
                    discoverCommentViewLabel.text = NSLocalizedString(@"comment discover", nil);
                    discoverCommentViewTextView.tag = 60;
                    
                    UILongPressGestureRecognizer *longPressCellGesture = [[UILongPressGestureRecognizer alloc]
                                                                          initWithTarget:self action:@selector(displayComment:)];
                    longPressCellGesture.minimumPressDuration = 1.0;
                    [discoverCommentView addGestureRecognizer:longPressCellGesture];
                }
                
            }
            
            NSString *rawMessage = [datas valueForKeyPath:@"comment.text"];
            NSData *data = [rawMessage dataUsingEncoding:NSUTF8StringEncoding];
            
            discoverCommentViewTextView.text = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            // Exemple date : 2015-05-10 17:28:12
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.ssssss";
            NSDate *dateMessage = [dateFormatter dateFromString:[datas valueForKeyPath:@"comment.date.date"]];
            dateFormatter.dateFormat = NSLocalizedString(@"yyyy/MM/dd at HH:mm" , nil);
            
            dateMessageLabel.text =  [dateFormatter stringFromDate:dateMessage];
        } else {
            // if self.userDiscoverId is nil so uer access the view directly from search engine
            if (i == 1 || self.userDiscoverId == nil) {
                discoverCommentViewLabel.text = NSLocalizedString(@"no comment user", nil);
            } else {
                if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:discoveryId]) {
                    
                    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"id == %@", discoveryId];
                    NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:friendPredicate];
                    NSString *facebookFriendName = (NSString*)[[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""];
                    discoverCommentViewLabel.text = [NSString stringWithFormat:NSLocalizedString(@"no comment friend %@", nil), facebookFriendName];
                    
                } else {
                    discoverCommentViewLabel.text = NSLocalizedString(@"no comment discover", nil);
                }
            }
        }
    }
}

- (void) changeComment:(UIPageControl*)sender
{
    NSUInteger page = sender.currentPage;
    UIScrollView *highlightMessagesSV = (UIScrollView*)[self.view viewWithTag:3];
    
    CGRect frame = highlightMessagesSV.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [highlightMessagesSV scrollRectToVisible:frame animated:YES];
}

- (void) showWarningMessage
{
    UIView *warningMessageView = [[UIView alloc] initWithFrame:self.view.frame];
    warningMessageView.tag = 5678;
    warningMessageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.85];
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:[self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = 1.0f;
    [bluredImageView setFrame:warningMessageView.frame];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = bluredImageView.bounds;
    
    [bluredImageView addSubview:visualEffectView];
    [warningMessageView addSubview:bluredImageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:warningMessageView];
    
    float percentHeight = (150*100)/screenHeight;
    UIView *warningMessageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, (percentHeight*screenHeight)/100, screenWidth, screenHeight-(percentHeight*screenHeight)/100)];
    warningMessageViewContainer.backgroundColor = [UIColor clearColor];
    
    UIImageView *warningPictoContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    warningPictoContainer.image = [[UIImage imageNamed:@"warning-picto"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    warningPictoContainer.center = CGPointMake(self.view.center.x, 0.0);
    warningPictoContainer.tintColor = [UIColor whiteColor];
    warningPictoContainer.backgroundColor = [UIColor clearColor];
    warningPictoContainer.contentMode = UIViewContentModeScaleAspectFill;
    [warningMessageViewContainer addSubview:warningPictoContainer];
    
    
    NSUInteger warningMessageY = warningPictoContainer.frame.size.height - 30;
    
    UITextView *warningMessage = [[UITextView alloc] initWithFrame:CGRectMake(0, warningMessageY, 225, 110)];
    warningMessage.text = [NSLocalizedString(@"warning message for comments", nil) uppercaseString];
    warningMessage.textColor = [UIColor whiteColor];
    warningMessage.center = CGPointMake(self.view.center.x, warningMessage.center.y);
    warningMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    warningMessage.textAlignment = NSTextAlignmentCenter;
    warningMessage.editable = NO;
//    [warningMessage sizeToFit];
    warningMessage.backgroundColor = [UIColor clearColor];
    [warningMessageViewContainer addSubview:warningMessage];
    
    UIButton *endTutorial = [UIButton buttonWithType:UIButtonTypeCustom];
    [endTutorial addTarget:self action:@selector(hideTutorial) forControlEvents:UIControlEventTouchUpInside];
    [endTutorial setTitle:[NSLocalizedString(@"gotit", nil) uppercaseString] forState:UIControlStateNormal];
    endTutorial.frame = CGRectMake(0, warningMessageViewContainer.frame.size.height - 150, screenWidth, 49);
    endTutorial.tintColor = [UIColor whiteColor];
    [endTutorial setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [endTutorial setTitleColor:[UIColor colorWithWhite:1.0 alpha:.50] forState:UIControlStateHighlighted];
    endTutorial.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    
    [warningMessageViewContainer addSubview:endTutorial];
    
    [warningMessageView addSubview:warningMessageViewContainer];
}

- (void) hideTutorial
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *tutorialView = (UIView*)[[[UIApplication sharedApplication] keyWindow] viewWithTag:5678];
    [UIView animateWithDuration:0.25 delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tutorialView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [tutorialView removeFromSuperview];
                     }];
}

-  (void) loadComments
{
    if ([self.numberOfComments integerValue] == 0) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayComments];
        });
        return;
    }

    UIActivityIndicatorView *messagesLoadingIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:4];
    
    UITableView *commentsTableView = (UITableView*)[self.view viewWithTag:1];
    
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/comments"];
    

    NSDictionary *parameters = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"],
                                 @"imdbId": self.mediaId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"response"] != nil) {
            self.comments = responseObject[@"response"];
            // This part is called for reload uitableview
            // e.g : current user adds new comment
            if ([commentsTableView isDescendantOfView:self.view]) {
                if ([self.comments count] >= 1) {
                    [self displayDiscoverAndUserCommentForDatas];
                }
                [commentsTableView reloadData];
            } else {
                [self displayComments];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [messagesLoadingIndicator stopAnimating];
    }];
    
}



- (void) postNewComment:(id)sender
{
    PostCommentViewController *postCommentViewController = [PostCommentViewController new];
    postCommentViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
    postCommentViewController.mediaId = self.mediaId;
    postCommentViewController.havingComment = self.havingComment;

    
    UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:[self takeSnapshotOfView:self.view]];
    bluredImageView.alpha = 0.99f;
    [bluredImageView setFrame:postCommentViewController.view.frame];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = bluredImageView.bounds;
    
    [bluredImageView addSubview:visualEffectView];
    [postCommentViewController.view addSubview:bluredImageView];
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    [self.navigationController pushViewController:postCommentViewController animated:YES];
}

- (UIImage *) takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - UITableView functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;

    NSString *message, *dateMessageString;
    
    UITextView *messageLabel;
    UIView *messageContainer;
    UILabel *dateMessageLabel;
    
//    NSNumberFormatter *numberFormatter;
    // Exemple date : 2015-05-10 17:28:12
    NSDateFormatter *dateFormatter;
    
    UIButton *likeCommentBtn;
    CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        messageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, floorf(((screenWidth * 89.375) / 100)), cellFrame.size.height)];
        messageContainer.backgroundColor = [UIColor clearColor];
        messageContainer.center = CGPointMake(self.view.center.x, messageContainer.center.y);
        

        messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 14, floorf(((screenWidth * 87.53125) / 100)), 76)];
        messageLabel.editable = NO;
        messageLabel.tag = 60;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.showsVerticalScrollIndicator = NO;
        messageLabel.textContainerInset = UIEdgeInsetsZero;
        messageLabel.textContainer.lineFragmentPadding = 0;
        messageLabel.scrollEnabled = NO;
        messageLabel.backgroundColor = [UIColor clearColor];
//        messageLabel.backgroundColor = [UIColor redColor];
        [messageContainer addSubview:messageLabel];
        
        
        CALayer *messageContainerBottomBorder = [CALayer layer];
        messageContainerBottomBorder.frame = CGRectMake(0, cellFrame.size.height, messageContainer.frame.size.width, 1.0f);
        messageContainerBottomBorder.backgroundColor = [UIColor colorWithRed:(87.0/255.0) green:(86.0/255.0) blue:(75.0/255.0) alpha:1.0].CGColor;
        [messageContainer.layer addSublayer:messageContainerBottomBorder];
        
        
        dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cellFrame.size.height - 25, 0, 50)];
        dateMessageLabel.textAlignment = NSTextAlignmentLeft;
        dateMessageLabel.numberOfLines = 0;
        dateMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        dateMessageLabel.textColor = [UIColor colorWithRed:(124.0/255.0) green:(124.0/255.0) blue:(124.0/255.0) alpha:1.0];
        dateMessageLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        dateMessageLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
        dateMessageLabel.layer.shadowOpacity = .95f;
        
        [messageContainer addSubview:dateMessageLabel];
        
        
        UILongPressGestureRecognizer *longPressCellGesture = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(displayComment:)];
        longPressCellGesture.minimumPressDuration = 1.0; //seconds
        [cell addGestureRecognizer:longPressCellGesture];
        
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.ssssss";
        
        likeCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [likeCommentBtn addTarget:self action:@selector(likeComment:) forControlEvents:UIControlEventTouchUpInside];
//        [likeCommentBtn setTitle:[numberFormatter stringFromNumber:@420] forState:UIControlStateNormal];
        likeCommentBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
        likeCommentBtn.frame = CGRectMake(0, cellFrame.size.height - 28, 70, 25); //
        likeCommentBtn.backgroundColor = [UIColor clearColor];
        [likeCommentBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [likeCommentBtn setTitleColor:[UIColor colorWithRed:(114.0/255.0) green:(117.0/255.0) blue:(121.0/255.0) alpha:1.0f] forState:UIControlStateHighlighted];
        likeCommentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        likeCommentBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -likeCommentBtn.titleLabel.frame.size.width - 10);
        likeCommentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 1, 0);
        likeCommentBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        
        [messageContainer addSubview:likeCommentBtn];
        
        [cell.contentView addSubview:messageContainer];
    }
    
    likeCommentBtn.tag = 1000 + [[[self.comments objectAtIndex:indexPath.row] valueForKeyPath:@"comment.id"] integerValue];
    
    NSString *goodValue = [[self.comments objectAtIndex:indexPath.row] valueForKeyPath:@"comment.text"];
    NSData *data = [goodValue dataUsingEncoding:NSUTF8StringEncoding];
    message = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    messageLabel.text = message;
    [messageLabel sizeToFit];
    [messageLabel.textContainer setSize:messageLabel.frame.size];
    
    
    [likeCommentBtn setTitle:[[self.comments objectAtIndex:indexPath.row] valueForKey:@"likesNumber"]
                    forState:UIControlStateNormal];
    
    // User already like this comment
    if ([[[self.comments objectAtIndex:indexPath.row] valueForKey:@"isLiked"] boolValue]) {
        [likeCommentBtn setImage:[UIImage imageNamed:@"like-comment"] forState:UIControlStateNormal];
    } else {
        [likeCommentBtn setImage:[UIImage imageNamed:@"like-comment-empty"] forState:UIControlStateNormal];
    }
    
    dateMessageString = [[self.comments objectAtIndex:indexPath.row] valueForKeyPath:@"comment.date.date"];
    
    
    NSDate *dateMessage = [dateFormatter dateFromString:dateMessageString];
    dateFormatter.dateFormat = NSLocalizedString(@"yyyy/MM/dd at HH:mm" , nil);
    
    dateMessageLabel.text = [dateFormatter stringFromDate:dateMessage];

    NSString *commentUserId = [[self.comments objectAtIndex:indexPath.row] valueForKeyPath:@"fbId"];
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] valueForKey:@"id"] containsObject:commentUserId]) {
        messageLabel.alpha = 1;
        
        NSArray *facebookFriendDatas = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsList"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", commentUserId]];
        NSString *firstNameFirstLetter = [[[facebookFriendDatas valueForKey:@"first_name"] componentsJoinedByString:@""] stringByAppendingString:@"\n"]; // •
        
        dateMessageLabel.text = [firstNameFirstLetter stringByAppendingString:dateMessageLabel.text];
        
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"] isEqualToString:commentUserId] ) {
        messageLabel.alpha = 1;
    
        dateMessageLabel.text = [NSLocalizedString(@"your comment", nil) stringByAppendingString:dateMessageLabel.text];
    } else {
        messageLabel.alpha = .005;
    }
    
    [dateMessageLabel sizeToFit];
    dateMessageLabel.frame = CGRectMake(CGRectGetWidth(messageContainer.frame) - CGRectGetWidth(dateMessageLabel.frame),
                                        cellFrame.size.height - 28,
                                        CGRectGetWidth(dateMessageLabel.frame),
                                        CGRectGetHeight(dateMessageLabel.frame));
    
//    likeCommentBtn.frame = CGRectMake(CGRectGetMinX(dateMessageLabel.frame) - CGRectGetWidth(likeCommentBtn.frame) - 10,
//                                      CGRectGetMinY(likeCommentBtn.frame) + 1,
//                                      CGRectGetWidth(likeCommentBtn.frame),
//                                      CGRectGetHeight(likeCommentBtn.frame));


    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UIView *emptyTableView = (UIView*)[self.view viewWithTag:2];
    
    // There is no messages
    if ([self.comments count] < 1) {
        emptyTableView.hidden = NO;
        UIActivityIndicatorView *messagesLoadingIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:4];
        [messagesLoadingIndicator stopAnimating];
    } else {
        emptyTableView.hidden = YES;
        // We show the header if there are messages
        tableView.tableHeaderView.hidden = NO;
    }

    
    return [self.comments count];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = [[self.comments objectAtIndex:indexPath.row] valueForKeyPath:@"comment.text"];
    CGSize constraint = CGSizeMake(floorf(((screenWidth * 87.53125) / 100)) - (floorf(((screenWidth * 13.53125) / 100)) * 2), 20000.0f);
    CGRect size = [message boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]}
                                     context:nil];
    CGFloat height = MAX(CGRectGetHeight(size), 44.0f);
    

    return height + 40;
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        UIActivityIndicatorView *messagesLoadingIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:4];
        [messagesLoadingIndicator stopAnimating];
    }
}


#pragma mark - other functions

- (void) displayComment:(UILongPressGestureRecognizer*)sender
{
    UITextView *messageLabel = (UITextView*)[sender.view viewWithTag:60];
    messageLabel.alpha = 1;
}

- (void) dismissModal
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) likeComment:(UIButton*)sender
{
    NSUInteger numberLikes = [sender.titleLabel.text integerValue];
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"like-comment"]]) {
        [sender setImage:[UIImage imageNamed:@"like-comment-empty"]
                forState:UIControlStateNormal];
        numberLikes--;
    } else {
        [sender setImage:[UIImage imageNamed:@"like-comment"]
                forState:UIControlStateNormal];
        numberLikes++;
    }

    // Unbalanced calls to begin/end appearance transitions for
    [sender setTitle:[[NSNumber numberWithInteger:numberLikes] stringValue]
                    forState:UIControlStateNormal];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(likeCommentQueryForId:) object:nil];
    [self performSelector:@selector(likeCommentQueryForId:) withObject:[NSNumber numberWithInteger:sender.tag - 1000] afterDelay:0.0];
}

- (void) likeCommentQueryForId:(NSNumber*)commentId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"likecomment" forHTTPHeaderField:@"X-Shound"];
    
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/comment/like"];
    NSDictionary *parameters = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"], @"commentId": commentId};
    
    [manager POST:shoundAPIPath parameters:parameters success:nil failure:nil];
}

- (void) sortTableview:(UISegmentedControl*)sender
{
    UITableView *commentsTableView = (UITableView*)[self.view viewWithTag:1];
    NSSortDescriptor *sorter;
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            sorter = [NSSortDescriptor sortDescriptorWithKey:@"comment.date.date"
                                                                     ascending:NO];
        }
            break;
            
        case 1:
        {
            sorter = [NSSortDescriptor sortDescriptorWithKey:@"likesNumber"
                                                   ascending:NO];
        }
            break;
            
        default:
            break;
    }
    
    self.comments = [[self.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]] mutableCopy];
    [commentsTableView reloadData];
}

#pragma mark - delegate function

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    uint page = sender.contentOffset.x / sender.frame.size.width;
    
    UIPageControl *highlightMessagesPC = (UIPageControl*)[self.view viewWithTag:5];
    [highlightMessagesPC setCurrentPage:page];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
