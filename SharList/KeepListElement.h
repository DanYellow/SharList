//
//  KeepListElement.h
//  SharList
//
//  Created by Jean-Louis Danielo on 09/09/2015.
//  Copyright (c) 2015 Jean-Louis Danielo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KeepListElement : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * imdbId;
@property (nonatomic, retain) NSDate * addedAt;

@end
