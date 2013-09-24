//
//  Image.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * imageDescription;
@property (nonatomic, retain) File *file;
@property (nonatomic, retain) NSManagedObject *article;
@property (nonatomic, retain) NSData * embedded;

@end
