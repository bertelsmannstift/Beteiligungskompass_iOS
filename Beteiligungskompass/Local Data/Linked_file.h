//
//  Linked_file.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Linked_file : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * fileDescription;
@property (nonatomic, retain) File *file;
@property (nonatomic, retain) Article *article;

@end
