//
//  Context.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Context : NSManagedObject

@property (nonatomic, retain) NSSet *criteria;
@property (nonatomic, retain) NSManagedObject *grouped_by;
@property (nonatomic, retain) NSString * articletype;

@end

@interface Context (CoreDataGeneratedAccessors)

- (void)addCriteriaObject:(NSManagedObject *)value;
- (void)removeCriteriaObject:(NSManagedObject *)value;
- (void)addCriteria:(NSSet *)values;
- (void)removeCriteria:(NSSet *)values;

@end
