//
//  CriteriaOption.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CriteriaOption;

@interface CriteriaOption : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * optionDescription;
@property (nonatomic, retain) NSNumber * orderindex;
@property (nonatomic, retain) NSNumber * default_value;
@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSSet *articles;
@property (nonatomic, retain) CriteriaOption *parent;
@property (nonatomic, retain) NSSet *childs;
@property (nonatomic, retain) NSManagedObject *criterion;
@end

@interface CriteriaOption (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(NSManagedObject *)value;
- (void)removeArticlesObject:(NSManagedObject *)value;
- (void)addArticles:(NSSet *)values;
- (void)removeArticles:(NSSet *)values;

- (void)addChildsObject:(CriteriaOption *)value;
- (void)removeChildsObject:(CriteriaOption *)value;
- (void)addChilds:(NSSet *)values;
- (void)removeChilds:(NSSet *)values;

@end
