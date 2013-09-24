//
//  EWCoreData.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "NSManagedObject+RCCoreData.h"


@implementation NSManagedObject (RCCoreData)

+ (id)createObjectInContext:(NSManagedObjectContext*)ctx
{
    id entity=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:ctx];
    return entity;
}

+ (NSEntityDescription*)entityInContext:(NSManagedObjectContext *)ctx
{
    return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:ctx];
}

+ (NSArray*)fetchObjectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext*)ctx
{
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    [req setEntity:[self entityInContext:ctx]];
    [req setPredicate:predicate];
    return [ctx executeFetchRequest:req error:nil];
}

+ (NSInteger)numberOfObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    [req setEntity:[self entityInContext:ctx]];
    [req setPredicate:predicate];
    return [ctx countForFetchRequest:req error:nil];
}

- (void)copyTo:(NSManagedObject *)destination
{
    NSEntityDescription *description=[[self class] entityInContext:self.managedObjectContext];
    NSDictionary *attributes=[description attributesByName];
    for(NSString *key in [attributes allKeys])
    {
        id value=[self valueForKey:key];
        [destination setValue:value forKey:key];
    }
}

@end
