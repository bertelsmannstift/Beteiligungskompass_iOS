//
//  Criterion.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CriteriaOption;

@interface Criterion : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * criterionDescription;
@property (nonatomic, retain) NSNumber * orderindex;
@property (nonatomic, retain) NSString * discriminator;
@property (nonatomic, retain) NSNumber * show_in_planner;
@property (nonatomic, retain) NSString * group_article_types;
@property (nonatomic, retain) NSNumber * filter_type_or;
@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSSet *options;
@property (nonatomic, retain) NSSet *contexts;
@property (nonatomic, retain) NSSet *grouping;
@end

@interface Criterion (CoreDataGeneratedAccessors)

- (void)addGroupingObject:(Context *)value;
- (void)removeGroupingObject:(Context *)value;
- (void)addGrouping:(NSSet *)values;
- (void)removeGrouping:(NSSet *)values;

- (void)addContextsObject:(NSManagedObject *)value;
- (void)removeContextsObject:(NSManagedObject *)value;
- (void)addContexts:(NSSet *)values;
- (void)removeContexts:(NSSet *)values;

- (void)addOptionsObject:(CriteriaOption *)value;
- (void)removeOptionsObject:(CriteriaOption *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

@end
