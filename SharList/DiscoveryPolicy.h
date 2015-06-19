//
//  DiscoveryPolicy.h
//  SharList
//
//  Created by Jean-Louis Danielo on 19/06/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DiscoveryPolicy : NSEntityMigrationPolicy

- (NSString*) stringFromNumber:(NSNumber*)aFbIdNumber;

@end
