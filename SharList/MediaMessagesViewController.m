//
//  MediaMessagesViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 16/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "MediaMessagesViewController.h"

@interface MediaMessagesViewController ()

@property(strong, nonatomic) NSMutableArray *messages;

@end

#pragma mark - tag list references
// Tag list
// 1  : messagesTableView
// 2  : emptyTableView

@implementation MediaMessagesViewController

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Variables init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    

    // http://stackoverflow.com/questions/26907352/how-to-draw-radial-gradients-in-a-calayer
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self easterEgg];
//    });
    
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathLocal"] stringByAppendingString:@"media.php/media/messages"];
    
    NSDictionary *parameters = @{@"fbiduser": @"fb456742", @"imdbId": self.mediaId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"response"]) {
            self.messages = responseObject[@"response"];
            [self displayMessages];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
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
                       (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithWhite:0 alpha:1] CGColor]
                       ];
    [gradientLayer setColors:colors];
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:.5], [NSNumber numberWithFloat:1.]];
    
//    [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
//     [NSNumber numberWithFloat:20 / view.frame.size.height],
//     [NSNumber numberWithFloat:(view.frame.size.height - 20) / view.frame.size.height],
//     [NSNumber numberWithFloat:1.], nil]
    [gradientLayer setStartPoint:CGPointMake(0.5f, 0.5f)];
    [gradientLayer setEndPoint:CGPointMake(0.5f, 0.5f)];
    gradientLayer.frame = self.view.bounds;
//    gradientLayer.layer.mask = gradientLayer;

    
    UIView *hellView = [[UIView alloc] initWithFrame:self.view.bounds];
    hellView.backgroundColor = [UIColor redColor];
    hellView.alpha = 1;
    hellView.layer.mask = gradientLayer;
//    [hellView.layer insertSublayer:gradient atIndex:0];
    [self.view insertSubview:hellView atIndex:50];
}

- (void) displayMessages
{
    UIScrollView *highlightMessagesSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth + 50, 120)];
    highlightMessagesSV.backgroundColor = [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:.3];
    highlightMessagesSV.center = CGPointMake(self.view.center.x, highlightMessagesSV.center.y);
    
    CALayer *highlightMessagesSVBottomBorder = [CALayer layer];
    highlightMessagesSVBottomBorder.frame = CGRectMake(0, 119, screenWidth, 1.0f);
    highlightMessagesSVBottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [highlightMessagesSV.layer addSublayer:highlightMessagesSVBottomBorder];
    
    CALayer *highlightMessagesSVTopBorder = [CALayer layer];
    highlightMessagesSVTopBorder.frame = CGRectMake(0, 0, screenWidth, 1.0f);
    highlightMessagesSVTopBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [highlightMessagesSV.layer addSublayer:highlightMessagesSVTopBorder];
    
    
    UITableView *messagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                                   118,
                                                                                   screenWidth,
                                                                                   CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tabBarController.tabBar.bounds))
                                                                  style:UITableViewStylePlain];
    messagesTableView.dataSource = self;
    messagesTableView.delegate = self;
    messagesTableView.backgroundColor = [UIColor clearColor];
    messagesTableView.tag = 1;
    messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    messagesTableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + 15, 0);
    messagesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    messagesTableView.tableHeaderView = highlightMessagesSV;
    messagesTableView.tableHeaderView.hidden = YES;
    messagesTableView.allowsSelection = NO;
    [self.view insertSubview:messagesTableView atIndex:1];
    
    
    // Empty list view
    UIView *emptyTableView = [[UIView alloc] initWithFrame:CGRectMake(0, (floorf(((screenHeight*30.80985915) / 100)) - 118), screenWidth, 120)];
    emptyTableView.backgroundColor = [UIColor clearColor];
    emptyTableView.tag = 2;
    emptyTableView.hidden = YES;
    emptyTableView.opaque = YES;
    [messagesTableView insertSubview:emptyTableView aboveSubview:messagesTableView];
    
    
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
    WSQuoteLabel.center = CGPointMake(self.view.center.x, WSQuoteLabel.center.y);
    
    [emptyTableView addSubview:WSQuoteLabel];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, WSQuoteLabel.frame.size.height + 11, screenWidth, 14)];
    authorLabel.text = @"W. Shakespeare";
    authorLabel.textAlignment = NSTextAlignmentCenter;
    authorLabel.textColor = [UIColor colorWithRed:(223.0/255) green:(223.0/255) blue:(223.0/255) alpha:1.0];
    authorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];

    [emptyTableView addSubview:authorLabel];
    
    
    UIImage *newMessageBtnImage = [[UIImage imageNamed:@"newMessageBtn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton *newMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newMessageBtn.frame = CGRectMake(0, authorLabel.frame.size.height + authorLabel.frame.origin.y + 28, 113, 113);
    newMessageBtn.tintColor = [UIColor colorWithRed:(223.0/255) green:(223.0/255) blue:(223.0/255) alpha:1.0];
    
    [newMessageBtn setImage:newMessageBtnImage forState:UIControlStateNormal];
    newMessageBtn.contentMode = UIViewContentModeScaleToFill;
    newMessageBtn.center = CGPointMake(self.view.center.x, newMessageBtn.center.y);
    newMessageBtn.backgroundColor = [UIColor clearColor];
    [newMessageBtn addTarget:self action:@selector(postNewMessage) forControlEvents:UIControlEventTouchUpInside];
 
    [emptyTableView addSubview:newMessageBtn];
    
    
    UIView *emptyViewLastView = emptyTableView.subviews.lastObject;
    CGRect emptyTableViewFrame = emptyTableView.frame;
    emptyTableViewFrame.size.height = emptyViewLastView.frame.size.height + emptyViewLastView.frame.origin.y;
    emptyTableView.frame = emptyTableViewFrame;
}

- (void) postNewMessage
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - UITableView functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
    NSString *message, *dateMessageString;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];

    
    UIView *messageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, floorf(((screenWidth * 89.375) / 100)), cellFrame.size.height)];
    messageContainer.backgroundColor = [UIColor clearColor];
    messageContainer.center = CGPointMake(self.view.center.x, messageContainer.center.y);

    CALayer *messageContainerBottomBorder = [CALayer layer];
    messageContainerBottomBorder.frame = CGRectMake(0, cellFrame.size.height, messageContainer.frame.size.width, 1.0f);
    messageContainerBottomBorder.backgroundColor = [UIColor colorWithRed:(87.0/255.0) green:(86.0/255.0) blue:(75.0/255.0) alpha:1.0].CGColor;
    [messageContainer.layer addSublayer:messageContainerBottomBorder];
    
    message = [[self.messages objectAtIndex:indexPath.row] valueForKeyPath:@"message.text"];
    
    UITextView *messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, floorf(((screenWidth * 85.53125) / 100)), 65)];
    messageLabel.text = message;
    messageLabel.editable = NO;
    messageLabel.tag = 60;
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.alpha = 0;
    messageLabel.backgroundColor = [UIColor clearColor];
    
    CGSize scrollableSize = messageLabel.frame.size;
    [messageLabel setContentSize:scrollableSize];
    
    [messageContainer addSubview:messageLabel];
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = cellFrame;
//    [messageContainer addSubview:effectView];
    
    
    dateMessageString = [[self.messages objectAtIndex:indexPath.row] valueForKeyPath:@"message.date.date"];
    
    // Exemple date : 2015-05-10 17:28:12
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate *dateMessage = [dateFormatter dateFromString:dateMessageString];
    
    dateFormatter.dateFormat = NSLocalizedString(@"yyyy/MM/dd at HH:mm" , nil);
    
    UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cellFrame.size.height - 15, messageContainer.frame.size.width, 13)];
    dateMessageLabel.textAlignment = NSTextAlignmentRight;
    dateMessageLabel.text =  [dateFormatter stringFromDate:dateMessage];
    dateMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    dateMessageLabel.textColor = [UIColor colorWithRed:(124.0/255.0) green:(124.0/255.0) blue:(124.0/255.0) alpha:1.0];
    dateMessageLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    dateMessageLabel.layer.shadowOffset = CGSizeMake(1.50f, 1.50f);
    dateMessageLabel.layer.shadowOpacity = .95f;
    [messageContainer addSubview:dateMessageLabel];
    
    [cell.contentView addSubview:messageContainer];
    
    UILongPressGestureRecognizer *longPressCellGesture = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(displayMessage:)];
    longPressCellGesture.minimumPressDuration = 1.0; //seconds
    [cell addGestureRecognizer:longPressCellGesture];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UIView *emptyTableView = (UIView*)[self.view viewWithTag:2];
    
    if ([self.messages count] < 1) {
        emptyTableView.hidden = NO;
    } else {
        // We show the header if there are messages
        tableView.tableHeaderView.hidden = NO;
    }
    
    return [self.messages count];
}

//- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 85.0f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}


#pragma mark - other functions

- (void) displayMessage:(UILongPressGestureRecognizer*)sender
{
    UITextView *messageLabel = (UITextView*)[sender.view viewWithTag:60];
    messageLabel.alpha = 1;
}

- (void) dismissModal
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
