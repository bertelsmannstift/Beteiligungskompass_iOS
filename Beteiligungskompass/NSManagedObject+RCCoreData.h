//
//  EWCoreData.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>


@interface NSManagedObject (RCCoreData)

+ (id)createObjectInContext:(NSManagedObjectContext*)ctx;
+ (NSEntityDescription*)entityInContext:(NSManagedObjectContext*)ctx;
+ (NSArray*)fetchObjectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext*)ctx;
+ (NSInteger)numberOfObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext*)ctx;

- (void)copyTo:(NSManagedObject*)destination;

@end
