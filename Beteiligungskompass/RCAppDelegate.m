//
//  RCAppDelegate.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "RCAppDelegate.h"
#import "ZipArchive.h"
#import "RCImportViewController.h"
#import "RCBaseSettings.h"

@implementation RCAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize userStore=_userStore;
@synthesize globalStore=_globalStore;
@synthesize criteria=_criteria;
//@synthesize fetchRequests=_fetchRequests;
@synthesize resultList=_resultList;
@synthesize currentType=_currentType;
@synthesize sections=_sections;

- (void)buildCriteria
{
    NSMutableArray *criteria=[NSMutableArray array];
    for(Criterion *criterion in [Criterion fetchObjectsWithPredicate:nil inContext:self.managedObjectContext])
    {
        [criteria addObject:[NSDictionary dictionaryWithObjectsAndKeys:criterion,@"criterion",[NSMutableArray array],@"selection", nil]];
    }
    self.criteria=criteria;
}

- (NSPredicate *)buildOrPredicateForEntry:(id)entry
{
    NSArray *array = [[entry objectForKey:@"selection"] copy];
    NSPredicate *predicateOne = [NSPredicate predicateWithFormat:@"(any options in %@) OR ((SUBQUERY(options, $option, $option.criterion == %@)).@count == 0)", array, [entry objectForKey: @"criterion"]];
    return predicateOne;
}

- (NSPredicate *)buildAndPredicateForEntry:(id)entry
{
    NSMutableArray *predicates=[NSMutableArray array];
    for(CriteriaOption *option in [entry objectForKey:@"selection"])
    {
        [predicates addObject:[NSPredicate predicateWithFormat:@"options contains %@",option]];
    }
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

- (NSPredicate *)buildPredicateForEntry:(id)entry
{
    if([[entry objectForKey:@"selection"] count]==0)
        return nil;
    Criterion *criterion=[entry objectForKey:@"criterion"];
    if([criterion.filter_type_or boolValue])
    {
        return [self buildOrPredicateForEntry:entry];
    }
    else
    {
        return [self buildAndPredicateForEntry:entry];
    }
}

- (NSFetchRequest*)buildFetchRequestForPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:[Article entityInContext:self.managedObjectContext]];
    [request setPredicate:predicate];
    return request;
}

- (NSPredicate*)buildPredicateForContext:(Context *)context
{
    NSMutableArray *predicates=[NSMutableArray array];

    for(id elem in self.criteria)
    {
        Criterion *criterion=[elem objectForKey:@"criterion"];
        if([criterion.contexts containsObject:context])
        {
            NSPredicate *filter=[self buildPredicateForEntry:elem];
            if(filter!=nil)
            {
                [predicates addObject:filter];
            }
        }
    }
    [predicates addObject:[NSPredicate predicateWithFormat:@"type==%@",context.articletype]];

    if([context.articletype isEqualToString:@"news"])
    {
        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval: -(60*60*24*30)];
        [predicates addObject:[NSPredicate predicateWithFormat:@"date > %@", newDate]];
    }
    if([context.articletype isEqualToString:@"event"])
    {
        [predicates addObject:[NSPredicate predicateWithFormat:@"start_date > %@",[NSDate date]]];
    }

    [predicates addObjectsFromArray: @[[NSPredicate predicateWithFormat:@"is_custom==NO OR is_custom==nil"],
     [NSPredicate predicateWithFormat:@"deleted==NO OR deleted==nil"],
     [NSPredicate predicateWithFormat:@"active==YES"]]];

    if(self.searchTerm!=nil)
    {
        NSString *term=[NSString stringWithFormat:@"*%@*",self.searchTerm];
        [predicates addObject:[NSPredicate predicateWithFormat:@"title LIKE[cd] %@ OR short_description LIKE[cd] %@",term,term]];
    }
    NSPredicate *predicate=[NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    return predicate;
}

- (NSPredicate *)buildCountPredicate
{
    NSMutableArray *outerList=[NSMutableArray array];
    NSArray *contexts=[Context fetchObjectsWithPredicate:nil inContext:self.managedObjectContext];
    for(id elem in self.criteria)
    {
        Criterion *criterion=[elem objectForKey:@"criterion"];
        NSPredicate *filter=[self buildPredicateForEntry:elem];
        if(filter!=nil)
        {
            NSMutableArray *innerList=[NSMutableArray array];
            [innerList addObject:filter];
            for(Context *ctxt in [contexts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!self in %@",criterion.contexts]])
            {
                [innerList addObject:[NSPredicate predicateWithFormat:@"type=%@",ctxt.articletype]];
            }
            [outerList addObject:[NSCompoundPredicate orPredicateWithSubpredicates:innerList]];
        }
    }
    [outerList addObject:[NSPredicate predicateWithFormat:@"date >%@ or type<>%@",[[NSDate date] dateByAddingTimeInterval:-(60*60*24*30)],@"news"]];
    [outerList addObject:[NSPredicate predicateWithFormat:@"start_date >%@ or type<>%@",[NSDate date],@"event"]];
    [outerList addObjectsFromArray:@[[NSPredicate predicateWithFormat:@"is_custom==NO OR is_custom==nil"],
                              [NSPredicate predicateWithFormat:@"deleted==NO OR deleted==nil"],
                              [NSPredicate predicateWithFormat:@"active==YES"]]];
    return [NSCompoundPredicate andPredicateWithSubpredicates:outerList];
}


//this method is the data workhorse - it builds a new article list - based on the currently set filters
- (void)buildList
{
    NSLog(@"Building list");
    NSPredicate *predicate=[self buildCountPredicate];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:[Article entityInContext:self.managedObjectContext]];
    [request setRelationshipKeyPathsForPrefetching:@[@"options"]];
    NSMutableArray *seen=[NSMutableArray array];
    NSArray *result=[self.managedObjectContext executeFetchRequest:request error:nil];
    result=[result filteredArrayUsingPredicate:predicate];
    [self.fetchCounts removeAllObjects];
    for(Article *elem in result)
    {
        id identifier=elem.id_from_import;
        NSString *type=elem.type;
        if(![seen containsObject:identifier])
        {
            if(self.fetchCounts[type]==0)
            {
                self.fetchCounts[type]=@1;
            }
            else
            {
                self.fetchCounts[type]=@([self.fetchCounts[type] intValue]+1);
            }
            [seen addObject:identifier];
        }
    }
    predicate=[self buildPredicateForContext:[[Context fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"articletype=%@",self.currentType] inContext:self.managedObjectContext] lastObject]];
    request=[self buildFetchRequestForPredicate:predicate];
    self.resultList=[self.managedObjectContext executeFetchRequest:request error:nil];
    [self.fetchCounts setObject:@(self.resultList.count) forKey:self.currentType];
    //idea: for each OR filter build a single any in predicate
    //for each AND filter build a contains predicate for each selected item
    //result: AND on each predicate, based on type and contexts
    //NOW: sort correctly
    if([self.sortField isEqualToString:@"date"] || [self.sortField isEqualToString:@"start_date"] || [self.sortField isEqualToString:@"study_start"] || [self.sortField isEqualToString:@"created"] || [self.sortField isEqualToString: @"fav"])
    {
        self.resultList=[self.resultList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.sortField ascending:NO]]];
    }
    else
    {
        self.resultList=[self.resultList sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.sortField ascending:YES]]];
    }
    self.numberOfAllPlannedObjects=self.resultList.count;


    Criterion *criterion=[[Criterion fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"ANY grouping.articletype=%@",self.currentType] inContext:self.managedObjectContext] lastObject];
    id containment=[[self.criteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"criterion=%@",criterion]] lastObject];
    if((criterion==nil || [[containment objectForKey:@"selection"] count]>0) && ![self.currentType isEqualToString:@"event"])
        self.sections=nil;
    else if([self.currentType isEqualToString:@"event"])
    {
        NSMutableArray *array=[NSMutableArray array];
        NSMutableDictionary *helper=[NSMutableDictionary dictionary];
        NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
        [fmt setDateFormat:@"MMMM yyyy"];
        for(Article *article in self.resultList)
        {
            NSString *title=[fmt stringFromDate:article.start_date];
            if(title!=nil)
            {
                NSDictionary *section=[helper objectForKey:title];
                if(section==nil)
                {
                    NSMutableArray *items=[NSMutableArray array];
                    section=[NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",[NSNumber numberWithBool:YES],@"expanded",items,@"content",article.start_date,@"comparison", nil];
                    [helper setObject:section forKey:title];
                    [array addObject:section];
                }
                [[section objectForKey:@"content"] addObject:article];
                [[section objectForKey:@"content"] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES]]];
            }
        }
        [array sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"comparison" ascending:YES]]];
        self.sections=array;
    }
    else
    {
        NSArray *options=[criterion.options sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
        NSMutableArray *array=[NSMutableArray array];
        NSMutableDictionary *defaultDict;
        NSArray *rest=self.resultList;
        for(CriteriaOption *option in options)
        {
            NSMutableDictionary *dictionary=[NSMutableDictionary dictionary];
            [dictionary setObject:option.title forKey:@"title"];
            [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"expanded"];
            [dictionary setObject:[self.resultList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self in %@",option.articles]] forKey:@"content"];
            rest=[rest filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"not self in %@",[dictionary objectForKey:@"content"]]];
            if([option.default_value boolValue])
                defaultDict=dictionary;
            else if([[dictionary objectForKey:@"content"] count]>0)
                [array addObject:dictionary];
        }

        if(defaultDict)
        {
            [defaultDict setObject:rest forKey:@"content"];
            if(rest.count>0)
                [array insertObject:defaultDict atIndex:0];
        }

        self.sections=array;
    }
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RCListUpdatedNotification object:self];
    }
}

- (void)onMerge:(NSNotification*)notification
{
    if(notification.object==self.managedObjectContext)
    {
        [self.backgroundContext mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (void)setupArticleList
{
    self.currentType=@"study";//TODO: where to fetch the default?
    self.sortField=[[RCBaseSettings instance] sortForType:@"study"];
    [self buildCriteria];
    [self buildList];
}

- (void)onModuleUpdate:(id)notification
{
    [self setupArticleList];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMerge:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldAppFontOfSize:18] forKey:UITextAttributeFont]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil] forState:UIControlStateNormal];
//    self.fetchRequests=[NSMutableDictionary dictionary];
    self.fetchCounts=[NSMutableDictionary dictionary];
    self.comm=[[RCComm alloc] init];
    // Override point for customization after application launch.

    [self setupArticleList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModuleUpdate:) name:@"ModuleStatesChanged" object:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSUserDefaults *currentDefaults=[NSUserDefaults standardUserDefaults];
    NSDate *date=[currentDefaults objectForKey:@"lastUptodateCheck"];
    BOOL ask=YES;
    if(date!=nil)
    {
        NSDateComponents *comps=[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
        if([comps day]==0)
            ask=NO;
    }
    if(ask)
    {
        [self.comm getHashesAndCall:^(id response){
            NSString *selfHelper=@"";//um keine harte referenz in den blöcken auf self zu erzeugen -> retain loop vermeiden.
            if(response!=nil)
            {
                NSString *sqliteHash=[currentDefaults objectForKey:@"sqliteHash"];
                NSString *thumbnailHash=[currentDefaults objectForKey:@"thumbnailHash"];
                id subResponse=[response objectForKey:@"response"];
                if(![sqliteHash isEqualToString:[subResponse objectForKey:@"data.sqlite"]] ||
                   [thumbnailHash isEqualToString:[subResponse objectForKey:@"thumb.zip"]])
                {
                    [currentDefaults setObject:[NSDate date] forKey:@"lastUptodateCheck"];
                    selfHelper.appDelegate.alertDelegate=[[RCAlertViewDelegate alloc] init];
                    [selfHelper.appDelegate.alertDelegate addButtonWithText:RCLocalizedString(@"Aktualisieren", @"updatealert.update") isCancelButton:NO pressedHandler:^{
                        RCImportViewController *importCtrl=[selfHelper.appDelegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"import"];
                        importCtrl.modalPresentationStyle=UIModalPresentationFormSheet;
                        [selfHelper.appDelegate.window.rootViewController presentViewController:importCtrl animated:YES completion:nil];
                    }];
                    [selfHelper.appDelegate.alertDelegate addButtonWithText:RCLocalizedString(@"Abbrechen", @"updatealert.cancel") isCancelButton:YES pressedHandler:^{
                    }];
                    [selfHelper.appDelegate.alertDelegate runAlertViewWithTitle:RCLocalizedString(@"Neue Daten verfügbar", @"updatealert.title") message:RCLocalizedString(@"Es sind neue Daten verfügbar. Soll ein Import durchgeführt werden?", @"updatealert.text")];
                }
            }
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    self.backgroundContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.backgroundContext setPersistentStoreCoordinator:coordinator];
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Beteiligungskompass" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Beteiligungskompass.sqlite"];

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    self.userStore=[__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,[NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil] error:&error];

    NSString *path=[[NSString cacheDirectory] stringByAppendingPathComponent:@"Beteiligungskompass.sqlite"];
    NSFileManager *fm=[NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path])
    {
        if([[NSBundle mainBundle] pathForResource:@"Beteiligungskompass" ofType:@"sqlite"]!=nil)
        {
            [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Beteiligungskompass" ofType:@"sqlite"] toPath:path error:nil];
            ZipArchive *archive=[[ZipArchive alloc] init];
            [archive UnzipOpenFile:[[NSBundle mainBundle] pathForResource:@"thumbs" ofType:@"zip"]];
            [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] withIntermediateDirectories:YES attributes:Nil error:nil];
            [archive UnzipFileTo:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] overWrite:YES];
            [archive UnzipCloseFile];
        }

    }

    self.globalStore=[__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"Beteiligungskompass.sqlite"]] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,[NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil] error:nil];
    if (!self.userStore || !self.globalStore) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

@implementation NSObject (AppDelegate)

- (RCAppDelegate *)appDelegate
{
    return (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
}

@end


NSString *RCLocalizedString(NSString *fallback, NSString *key)
{
    NSString *text=((Localization*)[[Localization fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"key=%@",key] inContext:key.appDelegate.managedObjectContext] lastObject]).value;
    if(text==nil)
    {
        NSLog(@"Missing text for %@",key);
        return fallback;
    }
    return text;
}

