//
//  PostCommentViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 19/05/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "PostCommentViewController.h"

@interface PostCommentViewController ()

@end

@implementation PostCommentViewController

#pragma mark - Tag List
// Tag list
// 1  : placeholderLabel
// 2  : postField
// 3  : charactersCountLabel
// 4  : messageLoadingIndicator

- (void) viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"validate", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(validateComment:)];
    [[self navigationItem] setRightBarButtonItem:newBackButton];
    
    self.title = [NSLocalizedString(@"update comment", nil) uppercaseString];
    
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.35];
    
    
    // Variables init
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    NSString *settingsPlist = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    // Build the array from the plist
    settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsPlist];
    
    
    UILabel *charactersCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, ceilf((screenWidth * 95) / 100), 24)];
    charactersCount.textColor = [UIColor colorWithRed:(176.0f/255.0f) green:(176.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
    charactersCount.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    charactersCount.center = CGPointMake(self.view.center.x, charactersCount.center.y);
    charactersCount.textAlignment = NSTextAlignmentRight;
    charactersCount.tag = 3;
    charactersCount.text = @"";
    
    
    UITextView *postField = [[UITextView alloc] initWithFrame:CGRectMake(0, 106, ceilf((screenWidth * 95) / 100), 150)];
    postField.editable = YES;
    postField.textColor = [UIColor whiteColor];
    postField.backgroundColor = [UIColor clearColor];
    postField.center = CGPointMake(self.view.center.x, postField.center.y);
    postField.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    postField.delegate = self;
    postField.tag = 2;
    postField.editable = NO;
    postField.layoutManager.delegate = self;
    postField.contentInset = UIEdgeInsetsMake(-10, -5, 0, 0);
    

    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 2.0, postField.frame.size.width - 10.0, 34.0)];
    placeholderLabel.textColor = [UIColor colorWithRed:(176.0f/255.0f) green:(176.0f/255.0f) blue:(176.0f/255.0f) alpha:0.90f];
    placeholderLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    placeholderLabel.tag = 1;
    [postField addSubview:placeholderLabel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:postField];
        [self.view addSubview:charactersCount];
    });
    
    UIActivityIndicatorView *messageLoadingIndicator = [UIActivityIndicatorView new];
    messageLoadingIndicator.center = self.view.center;
    messageLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    messageLoadingIndicator.hidesWhenStopped = YES;
    messageLoadingIndicator.tag = 4;
    messageLoadingIndicator.tintColor = [UIColor colorWithRed:(17.0f/255.0f) green:(34.0f/255.0f) blue:(42.0f/255.0f) alpha:1];
    messageLoadingIndicator.backgroundColor = [UIColor clearColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:messageLoadingIndicator];
        [messageLoadingIndicator startAnimating];
    });
}

- (void) viewDidAppear:(BOOL)animated
{
    UILabel *placeholderLabel = (UILabel*)[self.view viewWithTag:1];
    UITextView *postField = (UITextView*)[self.view viewWithTag:2];
    UIActivityIndicatorView *messageLoadingIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:4];
    
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathLocal"] stringByAppendingString:@"media.php/media/usercomment"];
    NSDictionary *parameters = @{@"fbiduser": @"fb456742", @"imdbId": self.mediaId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"foo" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (responseObject[@"response.text"] != nil) {
            postField.text = [responseObject valueForKeyPath:@"response.text"];
        }

        placeholderLabel.text = [NSString stringWithFormat:NSLocalizedString(@"think about %@", nil), [responseObject valueForKeyPath:@"response.name"]];
        postField.editable = YES;
        [postField becomeFirstResponder];
        [messageLoadingIndicator stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [messageLoadingIndicator stopAnimating];
    }];
}


#pragma mark - delegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self managePlaceholderForTextView:textView];
}

- (void) textViewDidChange:(UITextView *)textView
{
    [self managePlaceholderForTextView:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self managePlaceholderForTextView:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 140;
}

- (CGFloat) layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 20.0f;
}

#pragma mark other function

- (void) validateComment:(UIBarButtonItem*)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) managePlaceholderForTextView:(UITextView*)textView
{
    UILabel *placeholderLabel = (UILabel*)[self.view viewWithTag:1];
    if(![textView hasText]) {
        placeholderLabel.hidden = NO;
    } else {
        placeholderLabel.hidden = YES;
    }
    
    
    UILabel *charactersCount = (UILabel*)[self.view viewWithTag:3];
    NSUInteger charactersCountDe = 140 - textView.text.length;
    charactersCount.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:charactersCountDe]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
