//
//  SHDSplitViewController.m
//  SharList
//
//  Created by Jean-Louis Danielo on 12/07/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "SHDSplitViewController.h"

@interface SHDSplitViewController ()

@end

@implementation SHDSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.presentsWithGesture = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    
    NSLog(@"secondaryViewController = %@", secondaryViewController);
//    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
//        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[NoteViewController class]]
//        && ([(NoteViewController *)[(UINavigationController *)secondaryViewController topViewController] note] == nil)) {
//        // If the detail controller doesn't have an item, display the primary view controller instead
//        return YES;
//    }
    
    return YES;
    
}



@end
