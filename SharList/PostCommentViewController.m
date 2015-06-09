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
// 5  : newBackButton
// 6  : commentSendFeedbackLabel

- (void) viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *validateCommentBarBtn =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"validate", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(validateComment:)];
    validateCommentBarBtn.tag = 5;
    validateCommentBarBtn.enabled = NO;
    [[self navigationItem] setRightBarButtonItem:validateCommentBarBtn];
   
    if (self.havingComment) {
        self.title = [NSLocalizedString(@"update comment", nil) uppercaseString];
    } else {
        self.title = [NSLocalizedString(@"post comment", nil) uppercaseString];
    }
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
    
    UILabel *commentSendFeedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, ceilf((screenWidth * 95) / 100), 24)];
    commentSendFeedbackLabel.textColor = [UIColor colorWithRed:(0.0f/255.0f) green:(88.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0f];
    commentSendFeedbackLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    commentSendFeedbackLabel.center = CGPointMake(self.view.center.x, commentSendFeedbackLabel.center.y);
    commentSendFeedbackLabel.textAlignment = NSTextAlignmentLeft;
    commentSendFeedbackLabel.alpha = 1;
    commentSendFeedbackLabel.backgroundColor = [UIColor clearColor];
    commentSendFeedbackLabel.tag = 6;
    
    
    UITextView *postField = [[UITextView alloc] initWithFrame:CGRectMake(0, 106, ceilf((screenWidth * 95) / 100), 150)];
    postField.editable = YES;
    postField.textColor = [UIColor whiteColor];
    postField.backgroundColor = [UIColor colorWithWhite:1 alpha:.005];
    postField.center = CGPointMake(self.view.center.x, postField.center.y);
    postField.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    postField.delegate = self;
    postField.tag = 2;
    postField.editable = NO;
    postField.layoutManager.delegate = self;
    postField.contentInset = UIEdgeInsetsMake(-10, -5, 0, 0);
    

    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 5.0, postField.frame.size.width - 10.0, 40.0)];
    placeholderLabel.textColor = [UIColor colorWithRed:(176.0f/255.0f) green:(176.0f/255.0f) blue:(176.0f/255.0f) alpha:0.90f];
    placeholderLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    placeholderLabel.tag = 1;
//    placeholderLabel.lineBreakMode = NSLineBreakByCharWrapping;
    placeholderLabel.numberOfLines = 0;
    [postField addSubview:placeholderLabel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:postField];
        [self.view addSubview:commentSendFeedbackLabel];
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
    
    NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/usercomment"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"];
    NSDictionary *parameters = @{@"fbiduser": userId, @"imdbId": self.mediaId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"foo" forHTTPHeaderField:@"X-Shound"];
    
    [manager GET:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject valueForKeyPath:@"response.text"] != (id)[NSNull null]) {
            postField.text = [responseObject valueForKeyPath:@"response.text"];
            self.oldComment = postField.text;
            commentId = [responseObject valueForKeyPath:@"response.commentId"];
        }

        placeholderLabel.text = [NSString stringWithFormat:NSLocalizedString(@"think about %@", nil), [responseObject valueForKeyPath:@"response.name"]];
        
        postField.editable = YES;
        [postField becomeFirstResponder];
        [messageLoadingIndicator stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
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
    return 10.0f;
}

#pragma mark other function

- (void) validateComment:(UIBarButtonItem*)sender
{
    UITextView *postField = (UITextView*)[self.view viewWithTag:2];
    sender.enabled = NO;
    
    if (postField.text.length <= 0 || [self.oldComment isEqualToString:postField.text]) {
        // TODO : error for empty message
        sender.enabled = YES;
        return;
    }
    
    MediaCommentsViewController *mediaCommentsViewController = self.navigationController.viewControllers[0];
    
    if (self.ishavingComment) {
        NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/comment"];
        
        NSDictionary *parameters = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"], @"imdbId": self.mediaId, @"text": postField.text, @"commentId": commentId};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
        
        [manager PATCH:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            sender.enabled = YES;
            [self faceStatusForMessage:NSLocalizedString(@"updated comment", nil)];
            [self.view endEditing:YES];
            [mediaCommentsViewController loadComments];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error : %@", error);
        }];
    } else {
        NSString *shoundAPIPath = [[settingsDict objectForKey:@"apiPathV2"] stringByAppendingString:@"media.php/media/comment"];
        
        NSDictionary *parameters = @{@"fbiduser": [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"], @"imdbId": self.mediaId, @"text": postField.text};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:@"hello" forHTTPHeaderField:@"X-Shound"];
        
        [manager POST:shoundAPIPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            sender.enabled = YES;
            [self faceStatusForMessage:NSLocalizedString(@"sent comment", nil)];
            [self.view endEditing:YES];
            [mediaCommentsViewController loadComments];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error : %@", error);
        }];
    }
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
    
    if (charactersCountDe <= 5) {
        charactersCount.textColor = [UIColor colorWithRed:(209.0f/255.0f) green:(3.0f/255.0f) blue:(11.0f/255.0f) alpha:1.0];
    } else {
        charactersCount.textColor = [UIColor colorWithRed:(176.0f/255.0f) green:(176.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
    }
    
    if (textView.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void) faceStatusForMessage:(NSString*)message
{
    UILabel *commentSendFeedbackLabel = (UILabel*)[self.view viewWithTag:6];
    commentSendFeedbackLabel.alpha = 1.0f;
    commentSendFeedbackLabel.text = message;
    [UIView animateWithDuration:.8f delay:1.9f options:UIViewAnimationOptionCurveLinear animations:^{
        commentSendFeedbackLabel.alpha = 0.0f;
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
