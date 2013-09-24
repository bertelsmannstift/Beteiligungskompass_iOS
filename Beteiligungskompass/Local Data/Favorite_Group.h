//
//  Favorite_Group.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Favorite_Entry;

@interface Favorite_Group : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *user;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSString * sharingurl;

@end

@interface Favorite_Group (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(Favorite_Entry *)value;
- (void)removeEntriesObject:(Favorite_Entry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
