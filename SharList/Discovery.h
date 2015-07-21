//
//  Discovery.h
//  SharList
//
//  Created by Jean-Louis Danielo on 19/06/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Discovery : NSManagedObject

@property (nonatomic, retain) NSNumber * dbId;
@property (nonatomic, retain) NSString * fbId;
@property (nonatomic, assign) BOOL isFacebookFriend;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL isRandomDiscover;
@property (nonatomic, assign) BOOL isSeen;
@property (nonatomic, retain) NSDate * lastDiscovery;
@property (nonatomic, retain) NSNumber * numberOfDiscoveries;
@property (nonatomic, retain) NSData * likes;

@end
