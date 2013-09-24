//
//  File.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image,Linked_file;

@interface File : NSManagedObject

@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * mime;
@property (nonatomic, retain) NSString * ext;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSSet *files;
@property (nonatomic, retain) NSSet *images;
@end

@interface File (CoreDataGeneratedAccessors)

- (void)addFilesObject:(Linked_file *)value;
- (void)removeFilesObject:(Linked_file *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
