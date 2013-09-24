//
//  RCImportViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCImportViewController.h"
#import <sqlite3.h>
#import "SBJson.h"
#import "NSString+ApplicationDirectory.h"
#import "ZipArchive.h"
#import "RCModuleManagement.h"
#import "RCBaseSettings.h"

@interface RCImportViewController ()

@end

@implementation RCImportViewController {
    BOOL _cancelImport;
    NSString *staticPage;
}
@synthesize context=_context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)onMerge:(NSNotification *)notification
{
    if(notification.object==self.context)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        });
    }
}



- (void)performSync
{
    [self.appDelegate.comm getExportAndCall:^(NSData *data){
        if(data==nil && !_cancelImport)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Import fehlgeschlagen", @"label.import_error")
                                                          message:RCLocalizedString(@"Der Import ist fehlgeschlagen. Bitte versuchen Sie es später erneut.", @"label.error_import")
                                                         delegate:nil
                                                cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                                otherButtonTitles:nil];
            [alert show];
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        else if(_cancelImport)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        [data writeToFile:[[NSString cacheDirectory] stringByAppendingPathComponent:@"data.sqlite"] atomically:YES];
        data=nil;
        [self.appDelegate.comm getThumbnailsAndCall:^(NSData *thumbs){
            if(thumbs==nil && !_cancelImport)
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Import fehlgeschlagen", @"label.import_error")
                                                              message:RCLocalizedString(@"Der Import ist fehlgeschlagen. Bitte versuchen Sie es später erneut.", @"label.error_import")
                                                             delegate:nil
                                                    cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                                    otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            else if(_cancelImport)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            [thumbs writeToFile:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbs.zip"] atomically:YES];
            [self.appDelegate.comm getStaticPageAndCall:^(NSString *response) {
                staticPage=response;
                [self import];
            }];
            
        }];
    }];

}

- (void)import
{
    ZipArchive *archive=[[ZipArchive alloc] init];
    [archive UnzipOpenFile:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbs.zip"]];
    [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails_new"] withIntermediateDirectories:YES attributes:Nil error:nil];
    [archive UnzipFileTo:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails_new"] overWrite:YES];
    [archive UnzipCloseFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMerge:) name:NSManagedObjectContextDidSaveNotification object:nil];
    NSManagedObjectContext *context=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context=context;
    [context setPersistentStoreCoordinator:self.appDelegate.persistentStoreCoordinator];
    [context performBlock:^{
        Page *static_basics=nil;
        if(staticPage!=nil)
        {
            Page *page=[[Page fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type=%@",@"basics_static"] inContext:context] lastObject];
            if(page==nil)
                page=[Page createObjectInContext:context];
            page.type=@"basics_static";
            page.content=staticPage;
            static_basics=page;
        }
        BOOL failed=NO;
        sqlite3 *database;
        sqlite3_open([[[NSString cacheDirectory] stringByAppendingPathComponent:@"data.sqlite"] UTF8String], &database);
        NSString *query=@"select article_types,description,discriminator,filter_type_or,group_article_types,id,orderindex,show_in_planner,title,type from criteria where deleted=0";
        sqlite3_stmt *stmt=NULL;
        int code = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        NSMutableDictionary *criteria=[NSMutableDictionary dictionary];
        NSArray *cArray = [Criterion fetchObjectsWithPredicate:nil inContext:context];
        
        for(Criterion *item in cArray)
        {
            [context deleteObject: item];
            //[criteria setObject:item forKey:item.id_from_import];
        }
        NSMutableArray *criteriaToKeep=[NSMutableArray array];
        
        NSMutableDictionary *contexts=[NSMutableDictionary dictionary];
        for(Context *ctxt in [Context fetchObjectsWithPredicate:nil inContext:context])
        {
            [contexts setObject:ctxt forKey:ctxt.articletype];
        }
        if(contexts[@"news"]==nil)
        {
            Context *ctxt=[Context createObjectInContext:context];
            ctxt.articletype=@"news";
            contexts[@"news"]=ctxt;
        }
        if(contexts[@"event"]==nil)
        {
            Context *ctxt=[Context createObjectInContext:context];
            ctxt.articletype=@"event";
            contexts[@"event"]=ctxt;
            
        }
        if(contexts[@"study"]==nil)
        {
            Context *ctxt=[Context createObjectInContext:context];
            ctxt.articletype=@"study";
            contexts[@"study"]=ctxt;
        }
        if(contexts[@"qa"]==nil)
        {
            Context *ctxt=[Context createObjectInContext:context];
            ctxt.articletype=@"qa";
            contexts[@"qa"]=ctxt;
        }
        if(contexts[@"method"]==nil)
        {
            Context *ctxt=[Context createObjectInContext:context];
            ctxt.articletype=@"method";
            contexts[@"method"]=ctxt;
        }
        if(contexts[@"expert"]==nil)
        {
            Context *ctxt=[Context createObjectInContext:context];
            ctxt.articletype=@"expert";
            contexts[@"expert"]=ctxt;
        }
        NSArray *videos = [Video fetchObjectsWithPredicate: nil inContext: context];
        
        for(Video *aVideo in videos)
            [context deleteObject: aVideo];
        
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            char *article_types=(char*)sqlite3_column_text(stmt, 0);
            char *description=(char*)sqlite3_column_text(stmt, 1);
            char *discriminator=(char*)sqlite3_column_text(stmt, 2);
            char *filter_type_or=(char*)sqlite3_column_text(stmt, 3);
            char *group_article_type=(char*)sqlite3_column_text(stmt, 4);
            unsigned long identifier=sqlite3_column_int64(stmt, 5);
            int orderindex=sqlite3_column_int(stmt, 6);
            int show_in_planner=sqlite3_column_int(stmt, 7);
            char *title=(char*)sqlite3_column_text(stmt, 8);
            char *type=(char*)sqlite3_column_text(stmt, 9);
            
            Criterion *item=[criteria objectForKey:[NSNumber numberWithUnsignedLongLong:identifier]];
            if(item==nil)
            {
                item=[Criterion createObjectInContext:context];
                [context assignObject:item toPersistentStore:self.appDelegate.globalStore];
                [criteria setObject:item forKey:[NSNumber numberWithUnsignedLongLong:identifier]];
                [criteriaToKeep addObject:item];
            }
            else
            {
                [criteriaToKeep addObject:item];
            }
            
            NSString *ArticleTypes=[[NSString alloc] initWithCString:article_types encoding:NSUTF8StringEncoding];
            NSArray *parsedArticleTypes=[ArticleTypes JSONValue];
            [item removeContexts:item.contexts];
            for(NSString *t in parsedArticleTypes)
            {
                Context *ctxt=[contexts objectForKey:t];
                if(ctxt==nil)
                {
                    ctxt=[Context createObjectInContext:context];
                    [context assignObject:ctxt toPersistentStore:self.appDelegate.globalStore];
                    ctxt.articletype=t;
                    [contexts setObject:ctxt forKey:t];
                }
                [item addContextsObject:ctxt];
            }
            if(description!=NULL)
                item.criterionDescription=[[NSString alloc] initWithCString:description encoding:NSUTF8StringEncoding];
            if(discriminator!=NULL)
                item.discriminator=[[NSString alloc] initWithCString:discriminator encoding:NSUTF8StringEncoding];
            item.filter_type_or=[NSNumber numberWithBool:filter_type_or!=0];
            if(group_article_type!=NULL)
            {
                ArticleTypes=[[NSString alloc] initWithCString:group_article_type encoding:NSUTF8StringEncoding];
                parsedArticleTypes=[ArticleTypes JSONValue];
                for(NSString *t in parsedArticleTypes)
                {
                    Context *ctxt=[contexts objectForKey:t];
                    if(ctxt==nil)
                    {
                        ctxt=[Context createObjectInContext:context];
                        [context assignObject:ctxt toPersistentStore:self.appDelegate.globalStore];
                        ctxt.articletype=t;
                    }
                    ctxt.grouped_by=item;
                }
            }
            
            item.id_from_import=[NSNumber numberWithUnsignedLongLong:identifier];
            item.orderindex=[NSNumber numberWithUnsignedInt:orderindex];
            item.show_in_planner=[NSNumber numberWithBool:show_in_planner!=0];
            item.title=[[NSString alloc] initWithCString:title encoding:NSUTF8StringEncoding];
            item.type=[[NSString alloc] initWithCString:type encoding:NSUTF8StringEncoding];
        }
        sqlite3_finalize(stmt);
        
        stmt=NULL;
        query=@"select criterion_id,default_value,description,id,orderindex,parentOption_id,title from criteria_options where deleted=0 order by parentOption_id desc";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        
        NSMutableDictionary *criterion_options=[NSMutableDictionary dictionary];
        for(CriteriaOption *option in [CriteriaOption fetchObjectsWithPredicate:nil inContext:context])
        {
            [criterion_options setObject:option forKey:option.id_from_import];
        }
        NSMutableArray *optionsToKeep=[NSMutableArray array];
        
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long criterion_id=sqlite3_column_int64(stmt, 0);
            unsigned int default_value=sqlite3_column_int(stmt, 1);
            char *description=(char*)sqlite3_column_text(stmt, 2);
            unsigned long identifier=sqlite3_column_int64(stmt, 3);
            unsigned int sortorder=sqlite3_column_int(stmt, 4);
            unsigned long parent=sqlite3_column_int64(stmt, 5);
            char *title=(char*)sqlite3_column_text(stmt, 6);
            
            CriteriaOption *option=[criterion_options objectForKey:[NSNumber numberWithUnsignedLongLong:identifier]];
            if(option==nil)
            {
                option=[CriteriaOption createObjectInContext:context];
                [context assignObject:option toPersistentStore:self.appDelegate.globalStore];
                [criterion_options setObject:option forKey:[NSNumber numberWithUnsignedLongLong:identifier]];
                [optionsToKeep addObject:option];
            }
            else
            {
                [optionsToKeep addObject:option];
            }
            
            option.id_from_import=[NSNumber numberWithUnsignedLongLong:identifier];
            option.criterion=[criteria objectForKey:[NSNumber numberWithUnsignedLongLong:criterion_id]];
            option.default_value=[NSNumber numberWithInt:default_value];
            if(description!=NULL)
                option.optionDescription=[[NSString alloc] initWithCString:description encoding:NSUTF8StringEncoding];
            option.orderindex=[NSNumber numberWithInt:sortorder];
            option.parent=[criterion_options objectForKey:[NSNumber numberWithUnsignedLongLong:parent]];
            if(title!=NULL)
                option.title=[[NSString alloc] initWithCString:title encoding:NSUTF8StringEncoding];
        }
        sqlite3_finalize(stmt);
        
        //TODO: import user
        stmt=NULL;
        query=@"select id,email,first_name,last_name,is_editor,is_admin,is_active,dbloptin,is_deleted from users";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        NSMutableDictionary *users=[NSMutableDictionary dictionary];
        for(User *u in [User fetchObjectsWithPredicate:nil inContext:context])
        {
            [users setObject:u forKey:u.id_from_import];
        }
        NSMutableArray *usersToKeep=[NSMutableArray array];
        
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long long _identifier=sqlite3_column_int64(stmt, 0);
            char *_email=(char*)sqlite3_column_text(stmt, 1);
            char *_first_name=(char*)sqlite3_column_text(stmt, 2);
            char *_last_name=(char*)sqlite3_column_text(stmt, 3);
            unsigned int _is_editor=sqlite3_column_int(stmt, 4);
            unsigned int _is_admin=sqlite3_column_int(stmt, 5);
            unsigned int _is_active=sqlite3_column_int(stmt, 6);
            unsigned int _dbloptin=sqlite3_column_int(stmt, 7);
            unsigned int _is_deleted=sqlite3_column_int(stmt, 8);
            
            NSNumber *identifier=[NSNumber numberWithUnsignedLongLong:_identifier];
            User *user=[users objectForKey:identifier];
            if (user==nil) {
                user=[User createObjectInContext:context];
                [context assignObject:user toPersistentStore:self.appDelegate.globalStore];
                user.id_from_import=identifier;
                [users setObject:user forKey:user.id_from_import];
            }
            [usersToKeep addObject:user];
            if(_email!=nil)
            {
                user.email=[[NSString alloc] initWithCString:_email encoding:NSUTF8StringEncoding];
            }
            if(_first_name!=nil)
            {
                user.first_name=[[NSString alloc] initWithCString:_first_name encoding:NSUTF8StringEncoding];
            }
            if(_last_name!=nil)
            {
                user.last_name=[[NSString alloc] initWithCString:_last_name encoding:NSUTF8StringEncoding];
            }
            
            user.is_editor=[NSNumber numberWithInt:_is_editor];
            user.is_admin=[NSNumber numberWithInt:_is_admin];
            user.is_active=[NSNumber numberWithInt:_is_active];
            user.dbloptin=[NSNumber numberWithInt:_dbloptin];
            user.is_deleted=[NSNumber numberWithInt:_is_deleted];
        }
        sqlite3_finalize(stmt);
        
        //TODO: import files
        stmt=NULL;
        query=@"select id,md5,filename,mime,ext,size from files";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        
        NSMutableDictionary *files=[NSMutableDictionary dictionary];
        for(File *f in [File fetchObjectsWithPredicate:nil inContext:context])
        {
            [files setObject:f forKey:f.id_from_import];
        }
        NSMutableArray *filesToKeep=[NSMutableArray array];
        
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long long _identifier=sqlite3_column_int64(stmt, 0);
            char *_md5=(char*)sqlite3_column_text(stmt, 1);
            char *_filename=(char*)sqlite3_column_text(stmt, 2);
            char *_mime=(char*)sqlite3_column_text(stmt, 3);
            char *_ext=(char*)sqlite3_column_text(stmt, 4);
            unsigned long long _size=sqlite3_column_int64(stmt, 5);
            
            NSNumber *identifier=[NSNumber numberWithUnsignedLongLong:_identifier];
            File *file=[files objectForKey:identifier];
            if(file==nil)
            {
                file=[File createObjectInContext:context];
                [context assignObject:file toPersistentStore:self.appDelegate.globalStore];
                file.id_from_import=identifier;
                [files setObject:file forKey:file.id_from_import];
            }
            [filesToKeep addObject:file];
            
            file.md5=[[NSString alloc] initWithCString:_md5 encoding:NSUTF8StringEncoding];
            file.filename=[[NSString alloc] initWithCString:_filename encoding:NSUTF8StringEncoding];
            file.mime=[[NSString alloc] initWithCString:_mime encoding:NSUTF8StringEncoding];
            file.ext=[[NSString alloc] initWithCString:_ext encoding:NSUTF8StringEncoding];
            file.size=[NSNumber numberWithUnsignedLongLong:_size];
        }
        
        NSArray *fields=[NSArray arrayWithObjects:
                         [NSDictionary dictionaryWithObjectsAndKeys:@"active",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"address",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"aim",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"answer",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"author",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"author_answer",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"background",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"city",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"contact",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"contact_person",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"costs",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"countrycode",@"name",@"string",@"type", @"country",@"map", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"created",@"name",@"datetime",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"date",@"name",@"date",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"deadline",@"name",@"date",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"description",@"name",@"string",@"type",@"long_description",@"map", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"used_for",@"name",@"string",@"type",@"used_for",@"map", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"listdescription_plaintext",@"name",@"string",@"type",@"plaintext",@"map", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"description_institution",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"email",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"end_date",@"name",@"datetime",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"end_month",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"end_year",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"external_links",@"name",@"external_links",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"fax",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"fee",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"firstname",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"images",@"name",@"images",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"institution",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"intro",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"lastname",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"link",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"more_information",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"number_of_participants",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"organized_by",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"origin",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"participants",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"participation",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"process",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"projectstatus",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"publisher",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"question",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"ready_for_publish",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"restrictions",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"results",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"short_description",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"short_description_expert",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"start_date",@"name",@"datetime",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"start_month",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"start_year",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"sticky",@"name",@"datetime",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"street",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"street_nr",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"strengths",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"subtitle",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"text",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"time_expense",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"title",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"type",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"updated",@"name",@"datetime",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"user_id",@"name",@"user",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"venue",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"name",@"videos",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"weaknesses",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"when_not_to_use",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"when_to_use",@"name",@"string",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"year",@"name",@"int",@"type", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"zip",@"name",@"string",@"type", nil],
                         nil];
        
        stmt=NULL;
        NSMutableString *string=[NSMutableString string];
        [string appendString:@"select id"];
        for(id elem in fields)
        {
            [string appendFormat:@",%@",[elem objectForKey:@"name"]];
        }
        [string appendString:@" from articles where deleted=0"];
        query=string;
        code = sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        NSMutableDictionary *articles=[NSMutableDictionary dictionary];
        for(Article *art in [Article fetchObjectsWithPredicate:nil inContext:context])
        {
            [articles setObject:art forKey:art.id_from_import];
        }
        NSMutableArray *articlesToKeep=[NSMutableArray array];
        
        NSDateFormatter *datetimefmt=[[NSDateFormatter alloc] init];
        [datetimefmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [datetimefmt setTimeZone:[NSTimeZone defaultTimeZone]];//TODO: replace with server timezone after call
        
        NSDateFormatter *datefmt=[[NSDateFormatter alloc] init];
        [datefmt setDateFormat:@"yyyy-MM-dd"];
        [datefmt setTimeZone:[NSTimeZone defaultTimeZone]];//TODO: replace with server timezone after call
        
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {  
            unsigned long long _identifier=sqlite3_column_int64(stmt, 0);
            NSNumber *identifier=[NSNumber numberWithUnsignedLongLong:_identifier];
            Article *article=[articles objectForKey:identifier];
            if(article==nil)
            {
                article=[Article createObjectInContext:context];
                [context assignObject:article toPersistentStore:self.appDelegate.globalStore];
                article.id_from_import=identifier;
                [articles setObject:article forKey:article.id_from_import];
                [articlesToKeep addObject:article];
            }
            else
            {
                [article setLinked_articles:[NSSet set]];
                [articlesToKeep addObject:article];
            }
            
            for(int i=0;i<fields.count;i++)
            {
                id elem=[fields objectAtIndex:i];
                NSString *name=[elem objectForKey:@"name"];
                NSString *type=[elem objectForKey:@"type"];
                if([type isEqualToString:@"string"])
                {
                    char *content=(char*)sqlite3_column_text(stmt, i+1);
                    if(content!=NULL)
                    {
                        if([elem objectForKey:@"map"]!=nil)
                        {
                            name=[elem objectForKey:@"map"];
                        }
                        NSString *body=[[NSString alloc] initWithCString:content encoding:NSUTF8StringEncoding];
                        body=[body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [article setValue:body forKey:name];
                    }
                }
                else if([type isEqualToString:@"int"])
                {
                    if(sqlite3_column_type(stmt, i+1)!=SQLITE_NULL)
                    {
                        int content=sqlite3_column_int(stmt, i+1);
                        [article setValue:[NSNumber numberWithInt:content] forKey:name];
                    }
                }
                else if([type isEqualToString:@"datetime"])
                {
                    char *content=(char*)sqlite3_column_text(stmt, i+1);
                    if(content!=NULL)
                    {
                        NSString *encoded=[[NSString alloc] initWithCString:content encoding:NSUTF8StringEncoding];
                        [article setValue:[datetimefmt dateFromString:encoded] forKey:name];
                    }
                }
                else if([type isEqualToString:@"date"])
                {
                    char *content=(char*)sqlite3_column_text(stmt, i+1);
                    if(content!=NULL)
                    {
                        NSString *encoded=[[NSString alloc] initWithCString:content encoding:NSUTF8StringEncoding];
                        [article setValue:[datefmt dateFromString:encoded] forKey:name];
                    }
                }
                else if([type isEqualToString:@"external_links"])
                {
                    for(External_Link *link in [article.external_links copy])
                    {
                        link.article=nil;
                        [context deleteObject:link];
                    }
                    char *_content=(char*)sqlite3_column_text(stmt, i+1);
                    if(_content!=NULL)
                    {
                        NSString *content=[[NSString alloc] initWithCString:_content encoding:NSUTF8StringEncoding];
                        NSArray *links=[content JSONValue];
                        for(int i=0;i<links.count;i++)
                        {
                            id elem=[links objectAtIndex:i];
                            External_Link *link=[External_Link createObjectInContext:context];
                            [context assignObject:link toPersistentStore:self.appDelegate.globalStore];
                            link.order=[NSNumber numberWithInt:i];
                            link.url=[elem objectForKey:@"url"];
                            link.show_link=[elem objectForKey:@"show_link"];
                            link.article=article;
                        }
                    }
                }
                else if([type isEqualToString:@"videos"])
                {
                    for(Video *video in [article.videos copy])
                    {
                        video.article=nil;
                        [context deleteObject:video];
                    }
                    char *_content=(char*)sqlite3_column_text(stmt, i+1);
                    if(_content!=NULL)
                    {
                        NSString *content=[[NSString alloc] initWithCString:_content encoding:NSUTF8StringEncoding];
                        NSArray *videos=[content JSONValue];
                        for(int i=0;i<videos.count;i++)
                        {
                            id elem=[videos objectAtIndex:i];
                            Video *video=[Video createObjectInContext:context];
                            [context assignObject:video toPersistentStore:self.appDelegate.globalStore];
                            video.order=[NSNumber numberWithInt:i];
                            video.url=[elem objectForKey:@"url"];
                            video.featured=[elem objectForKey:@"featured"];
                            video.article=article;
                        }
                    }
                }
                else if([type isEqualToString:@"images"])
                {
                    for(Image *img in [article.images copy])
                    {
                        img.article=nil;
                        [context deleteObject:img];
                    }
                    for(Linked_file *file in [article.files copy])
                    {
                        file.article=nil;
                        [context deleteObject:file];
                    }
                    char *_content=(char*)sqlite3_column_text(stmt, i+1);
                    if(_content!=NULL)
                    {
                        NSString *content=[[NSString alloc] initWithCString:_content encoding:NSUTF8StringEncoding];
                        NSArray *images=[content JSONValue];
                        for(int i=0;i<images.count;i++)
                        {
                            id elem=[images objectAtIndex:i];
                            File *file=[files objectForKey:[NSNumber numberWithInt:[[elem objectForKey:@"id"] intValue]]];
                            if([file.mime hasPrefix:@"image/"])
                            {
                                Image *img=[Image createObjectInContext:context];
                                [context assignObject:img toPersistentStore:self.appDelegate.globalStore];
                                img.order=[NSNumber numberWithInt:i];
                                img.article=article;
                                img.imageDescription=[elem objectForKey:@"description"];
                                img.file=file;
                            }
                            else
                            {
                                Linked_file *fl=[Linked_file createObjectInContext:context];
                                [context assignObject:fl toPersistentStore:self.appDelegate.globalStore];
                                fl.order=[NSNumber numberWithInt:i];
                                fl.article=article;
                                fl.fileDescription=[elem objectForKey:@"description"];
                                fl.file=file;
                            }
                        }
                    }
                }
                else if([type isEqualToString:@"user"])
                {
                    if(sqlite3_column_type(stmt, i+1)!=SQLITE_NULL)
                    {
                        NSNumber *user=[NSNumber numberWithUnsignedLongLong:sqlite3_column_int64(stmt, i+1)];
                        User *object=[users objectForKey:user];
                        article.originating_user=object;
                    }
                }
                else
                {
                    NSLog(@"Unknown Type!");
                }
            }
        }
        sqlite3_finalize(stmt);
        
        stmt=NULL;
        query=@"select article_id,article_linked_id from article_links where article_id in (select id from articles) and article_linked_id in (select id from articles)";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long long _parent=sqlite3_column_int64(stmt, 0);
            unsigned long long _child=sqlite3_column_int64(stmt, 1);
            Article *parent=[articles objectForKey:[NSNumber numberWithUnsignedLongLong:_parent]];
            Article *child=[articles objectForKey:[NSNumber numberWithUnsignedLongLong:_child]];
            [parent addLinked_articlesObject:child];
        }
        sqlite3_finalize(stmt);
        
        stmt=NULL;
        query=@"select model_article_id,model_criterion_option_id from articles_options where model_article_id in (select id from articles) and model_criterion_option_id in (select id from criteria_options)";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long long _article=sqlite3_column_int64(stmt, 0);
            unsigned long long _option=sqlite3_column_int64(stmt, 1);
            Article *article=[articles objectForKey:[NSNumber numberWithUnsignedLongLong:_article]];
            CriteriaOption *option=[criterion_options objectForKey:[NSNumber numberWithUnsignedLongLong:_option]];
            [article addOptionsObject:option];
        }
        sqlite3_finalize(stmt);
        

        
        stmt=NULL;
        query=@"select id,title,content,type,short_title from pages";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        NSMutableDictionary *pages=[NSMutableDictionary dictionary];
        for(Page *page in [Page fetchObjectsWithPredicate:nil inContext:context])
        {
            [pages setObject:page forKey:page.id_from_import];
        }
        NSMutableArray *pagesToKeep=[NSMutableArray array];
        if(static_basics!=nil)
            [pagesToKeep addObject:static_basics];
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long long _identifier=sqlite3_column_int64(stmt, 0);
            char *_pagetitle=(char*)sqlite3_column_text(stmt, 1);
            char *_content=(char*)sqlite3_column_text(stmt, 2);
            char *_type=(char*)sqlite3_column_text(stmt, 3);
            char *_short_title=(char*)sqlite3_column_text(stmt, 4);
            NSNumber *identifier=[NSNumber numberWithUnsignedLongLong:_identifier];
            Page *page=[pages objectForKey:identifier];
            if(page==nil)
            {
                page=[Page createObjectInContext:context];
                [context assignObject:page toPersistentStore:self.appDelegate.globalStore];
                page.id_from_import=identifier;
                [pages setObject:page forKey:page.id_from_import];
            }
            [pagesToKeep addObject:page];
            page.title=[[NSString alloc] initWithCString:_pagetitle encoding:NSUTF8StringEncoding];
            page.content=[[NSString alloc] initWithCString:_content encoding:NSUTF8StringEncoding];
            page.type=[[NSString alloc] initWithCString:_type encoding:NSUTF8StringEncoding];
            if(_short_title!=NULL)
                page.short_title=[[NSString alloc] initWithCString:_short_title encoding:NSUTF8StringEncoding];
        }
        sqlite3_finalize(stmt);
        
        stmt=NULL;
        query=@"select id,title,content from partnerlinks";
        code=sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
        if(code>0)
        {
            NSLog(@"Query failed");
            failed=YES;
        }
        NSMutableDictionary *partner_links=[NSMutableDictionary dictionary];
        for(PartnerLink *plink in [PartnerLink fetchObjectsWithPredicate:nil inContext:context])
        {
            [partner_links setObject:plink forKey:plink.id_from_import];
        }
        NSMutableArray *partnerlinksToKeep=[NSMutableArray array];
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            unsigned long long _identifier=sqlite3_column_int64(stmt, 0);
            char *_linktitle=(char*)sqlite3_column_text(stmt, 1);
            char *_content=(char*)sqlite3_column_text(stmt, 2);
            NSNumber *identifier=[NSNumber numberWithUnsignedLongLong:_identifier];
            PartnerLink *plink=[partner_links objectForKey:identifier];
            if(plink==nil)
            {
                plink=[PartnerLink createObjectInContext:context];
                [context assignObject:plink toPersistentStore:self.appDelegate.globalStore];
                plink.id_from_import=identifier;
                [partner_links setObject:plink forKey:plink.id_from_import];
            }
            [partnerlinksToKeep addObject:plink];
            plink.title=[[NSString alloc] initWithCString:_linktitle encoding:NSUTF8StringEncoding];
            plink.content=[[NSString alloc] initWithCString:_content encoding:NSUTF8StringEncoding];
        }
        sqlite3_finalize(stmt);
        sqlite3_close(database);
        if(!failed && !_cancelImport)
        {
            NSFileManager *fm=[NSFileManager defaultManager];
            [fm removeItemAtPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] error:nil];
            [fm moveItemAtPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails_new"] toPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] error:nil];
            [context save:nil];
            // Delete items not in keep lists
            NSMutableArray *allItems = [NSMutableArray arrayWithArray: [criteria allValues]];
            [allItems addObjectsFromArray: [criterion_options allValues]];
            [allItems addObjectsFromArray: [users allValues]];
            [allItems addObjectsFromArray: [files allValues]];
            [allItems addObjectsFromArray: [articles allValues]];
            [allItems addObjectsFromArray: [pages allValues]];
            [allItems addObjectsFromArray: [partner_links allValues]];
            
            [allItems removeObjectsInArray: optionsToKeep];
            [allItems removeObjectsInArray: criteriaToKeep];
            [allItems removeObjectsInArray: usersToKeep];
            [allItems removeObjectsInArray: filesToKeep];
            [allItems removeObjectsInArray: articlesToKeep];
            [allItems removeObjectsInArray: pagesToKeep];
            [allItems removeObjectsInArray: partnerlinksToKeep];
            
            [allItems enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL *stop){
                [context deleteObject: obj];
            }];
            [context save:nil];
        }
        else
        {
            [context rollback];
            NSFileManager *fm=[NSFileManager defaultManager];
            [fm removeItemAtPath:[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails_new"] error:nil];

        }
        void (^function)()=^{
            [self.appDelegate.comm getModuleStateAndCall:^(id settings) {
                [[RCModuleManagement instance] updateModuleState:settings];
            }];
            [self.appDelegate.comm getBaseConfigAndCall:^(id result) {
                [[RCBaseSettings instance] updateState:result];
            }];
            [self.appDelegate.comm getHashesAndCall:^(id response){
                if(response!=nil)
                {
                    id subelem=[response objectForKey:@"response"];
                    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:[subelem objectForKey:@"data.sqlite"] forKey:@"sqliteHash"];
                    [userDefaults setObject:[subelem objectForKey:@"thumb.zip"] forKey:@"thumbnailHash"];
                    [userDefaults synchronize];
                }
            }];
            [self.appDelegate.comm getStringsAndCall:^(id response){
                for(NSManagedObject *obj in [Localization fetchObjectsWithPredicate:nil inContext:context])
                {
                    [context deleteObject:obj];
                }
                
                id texts=response[@"response"];
                for(NSString *key in [texts allKeys])
                {
                    Localization *localization=[Localization createObjectInContext:context];
                    [context assignObject:localization toPersistentStore:self.appDelegate.globalStore];
                    localization.key=key;
                    localization.value=texts[key];
                }
                
                [context save:nil];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.appDelegate buildCriteria];
                    [self.appDelegate buildList];
                });
            }];
        };
        
        if(self.appDelegate.comm.isAuthenticated)
            [RCImportViewController syncFavoritesAndCall:function];
        else
            function();
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSync];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

+ (void)syncFavoritesAndCall:(void (^)())callback
{
    NSObject *helper=[[NSObject alloc] init];
    [helper.appDelegate.comm performGetFavoritesAndCall:^(id response){
        if([response class] == [NSError class] || !response)
            return;
        
        NSArray *favorites=[[[response objectForKey:@"response"] objectForKey:@"favoriteInfo"] objectForKey:@"allFavorites"];
        NSMutableDictionary *faventries=[NSMutableDictionary dictionary];
        NSMutableDictionary *articles=[NSMutableDictionary dictionary];
        for(Favorite_Entry *entry in [Favorite_Entry fetchObjectsWithPredicate:nil inContext:helper.appDelegate.managedObjectContext])
        {
            [helper.appDelegate.managedObjectContext deleteObject:entry];
        }
        for(Favorite_Group *group in [Favorite_Group fetchObjectsWithPredicate:nil inContext:helper.appDelegate.managedObjectContext])
        {
            [helper.appDelegate.managedObjectContext deleteObject:group];
        }
        for(Article *article in [Article fetchObjectsWithPredicate:nil inContext:helper.appDelegate.managedObjectContext])
        {
            [articles setObject:article forKey:article.id_from_import];
        }
        for(NSNumber *number in favorites)
        {
            id article=[articles objectForKey:number];
            if(article!=nil)
            {
                Favorite_Entry *entry=[Favorite_Entry createObjectInContext:helper.appDelegate.managedObjectContext];
                [helper.appDelegate.managedObjectContext assignObject:entry toPersistentStore:helper.appDelegate.globalStore];
                entry.article=article;
                [faventries setObject:entry forKey:number];
            }
        }
        NSDictionary *groups=[[[response objectForKey:@"response"] objectForKey:@"favoriteInfo"] objectForKey:@"favoriteGroups"];
        for(NSString *groupName in [groups allKeys])
        {
            Favorite_Group *group=[Favorite_Group createObjectInContext:helper.appDelegate.managedObjectContext];
            [helper.appDelegate.managedObjectContext assignObject:group toPersistentStore:helper.appDelegate.globalStore];
            group.title=groupName;
            group.sharingurl=[[groups objectForKey:groupName] objectForKey:@"sharelink"];
            group.id_from_import=[[groups objectForKey:groupName] objectForKey:@"id"];
            for(NSNumber *item in [[groups objectForKey:groupName] objectForKey:@"articles"])
            {
                id entry=[faventries objectForKey:item];
                if(entry!=nil)
                    [group addEntriesObject:entry];
            }
        }
        [helper.appDelegate.managedObjectContext save:nil];
        if(callback!=nil)
            callback();
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FavSyncComplete" object:nil];
    }];
}

- (IBAction)cancelImport:(id)sender {
    _cancelImport=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
