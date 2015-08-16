//
//  SHDUserDiscoveredDatas.m
//  SharList
//
//  Created by Jean-Louis Danielo on 15/08/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import "SHDUserDiscoveredDatas.h"

@implementation SHDUserDiscoveredDatas

- (instancetype) initWithDiscoveredUser:(Discovery *) userDiscovered
{
    self = [super init];
    if ( !self ) return nil;
    
    self.currentUser = [Discovery MR_findFirstByAttribute:@"fbId"
                                                withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserfbID"]];
    self.userDiscovered = userDiscovered;
    
    self.isSameUser = ([self.currentUser.fbId isEqualToString:self.userDiscovered.fbId]) ? YES : NO;
    
    self.currentUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.currentUser likes]] mutableCopy];
    self.discoveredUserLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];

    
    return self;
}


- (CGFloat) percentToDiscover
{
    NSDictionary *userMetLikes = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.userDiscovered likes]] mutableCopy];
    
    NSMutableSet *currentUserTasteSet, *currentUserMetTasteSet;
    int commonTasteCount = 0;
    int currentUserNumberItems = 0;
    for (int i = 0; i < [[userMetLikes filterKeysForNullObj] count]; i++) {
        NSString *key = [[userMetLikes filterKeysForNullObj] objectAtIndex:i];
        if (![[self.currentUserLikes objectForKey:key] isEqual:[NSNull null]]) {
            currentUserTasteSet = [NSMutableSet setWithArray:[[self.currentUserLikes objectForKey:key] valueForKey:@"imdbID"]];
            
            currentUserNumberItems += [[userMetLikes objectForKey:key] count];
        }
        
        if (![[userMetLikes objectForKey:key] isEqual:[NSNull null]]) {
            currentUserMetTasteSet = [NSMutableSet setWithArray:[[userMetLikes objectForKey:key] valueForKey:@"imdbID"]];
        }
        
        [currentUserMetTasteSet intersectSet:currentUserTasteSet]; //this will give you only the objects that are in both sets
        
        NSArray* result = [currentUserMetTasteSet allObjects];
        
        commonTasteCount += result.count;
    }
    
    CGFloat notCommonLikesPercent = ((float)commonTasteCount / (float)currentUserNumberItems);
    
    if (isnan(notCommonLikesPercent)) {
        notCommonLikesPercent = 0.0f;
    }
    
    // If the user has only 1% in common
    if (notCommonLikesPercent == (float)1) {
        notCommonLikesPercent = 1.0;
    }
    
    // substract 1 cause NSNumberFormatter for percent waits a value between (0 and 1)
    notCommonLikesPercent = 1 - notCommonLikesPercent;
    

    return notCommonLikesPercent;
}

- (NSMutableArray*) mediasIds
{
    NSMutableArray *linearizeDiscoveredUserLikes = [NSMutableArray new];
    // We linearize the likes datas of obth users it will be easier for the next operations
    for (NSString *keyName in [self.discoveredUserLikes filterKeysForNullObj]) {
        [linearizeDiscoveredUserLikes addObjectsFromArray:[[self.discoveredUserLikes objectForKey:keyName] valueForKey:@"imdbID"]];
    }
    
    NSMutableArray *linearizeCurrentUserLikes = [NSMutableArray new];
    for (NSString *keyName in [self.currentUserLikes filterKeysForNullObj]) {
        [linearizeCurrentUserLikes addObjectsFromArray:[[self.currentUserLikes objectForKey:keyName] valueForKey:@"imdbID"]];
    }
    
    // We want only the datas which are not in current user list of likes
    NSMutableArray *toDiscoverMediaArray = [NSMutableArray arrayWithArray:linearizeDiscoveredUserLikes];
    [toDiscoverMediaArray removeObjectsInArray:linearizeCurrentUserLikes];
    
    NSUInteger randomIndex = 0;
    if (toDiscoverMediaArray.count < 4) {
        NSUInteger limitThumbs = 4;
    
        // We wants now datas in common with current user
        // We wants to fill the array, at max 4 datas
        [linearizeDiscoveredUserLikes removeObjectsInArray:toDiscoverMediaArray];
        
        // This loop is used only to fill the thumbs array if there is not enough entries
        for (NSUInteger idx = 0; idx < limitThumbs && idx < linearizeDiscoveredUserLikes.count; idx++) {
            if (linearizeDiscoveredUserLikes.count >= 9) {
                randomIndex = arc4random() % [linearizeDiscoveredUserLikes count];
            } else {
                randomIndex = idx;
            }
            
            [toDiscoverMediaArray addObject:[linearizeDiscoveredUserLikes objectAtIndex:randomIndex]];
        }
    } else {
        // Every time, the datas are shuffle
        for (NSUInteger idx = 0; idx < toDiscoverMediaArray.count; idx++) {
            randomIndex = arc4random() % toDiscoverMediaArray.count;
            [toDiscoverMediaArray exchangeObjectAtIndex:idx withObjectAtIndex:randomIndex];
        }
    }


    
    // We remove duplicate
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:toDiscoverMediaArray];
    toDiscoverMediaArray = [[orderedSet array] mutableCopy];
    
    return toDiscoverMediaArray;
}

- (NSString*) fbid
{
    return self.userDiscovered.fbId;
}

@end
