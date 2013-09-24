//
//  User.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article,Favorite_Entry,Favorite_Group;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * is_editor;
@property (nonatomic, retain) NSNumber * is_admin;
@property (nonatomic, retain) NSNumber * dbloptin;
@property (nonatomic, retain) NSNumber * is_active;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSSet *created_articles;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSSet *groups;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFavoritesObject:(Favorite_Entry *)value;
- (void)removeFavoritesObject:(Favorite_Entry *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

- (void)addGroupsObject:(Favorite_Group *)value;
- (void)removeGroupsObject:(Favorite_Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addCreated_articlesObject:(Article *)value;
- (void)removeCreated_articlesObject:(Article *)value;
- (void)addCreated_articles:(NSSet *)values;
- (void)removeCreated_articles:(NSSet *)values;

@end
