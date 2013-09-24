//
//  RCAppDelegate.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <UIKit/UIKit.h>
#import "RCAlertViewDelegate.h"

@interface RCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStore *userStore;
@property (strong, nonatomic) NSPersistentStore *globalStore;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSArray *criteria;
//@property (strong, nonatomic) NSMutableDictionary *fetchRequests;
@property (strong, nonatomic) NSMutableDictionary *fetchCounts;

@property (strong, nonatomic) NSArray *resultList;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSString *currentType;
@property (strong, nonatomic) NSString *sortField;
@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) RCComm *comm;

@property (nonatomic, assign)int numberOfAllPlannedObjects;
@property (strong, nonatomic) RCAlertViewDelegate *alertDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)buildCriteria;
- (void)buildList;

@end

@interface NSObject (AppDelegate)
@property (nonatomic, readonly) RCAppDelegate *appDelegate;

@end
