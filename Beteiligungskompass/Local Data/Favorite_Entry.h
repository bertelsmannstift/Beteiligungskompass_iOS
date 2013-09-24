//
//  Favorite_Entry.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article;

@interface Favorite_Entry : NSManagedObject

@property (nonatomic, retain) NSManagedObject *user;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * id_from_import;

@end

@interface Favorite_Entry (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(NSManagedObject *)value;
- (void)removeGroupsObject:(NSManagedObject *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
