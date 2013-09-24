//
//  RCEventDetailVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCEventDetailVC.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface RCEventDetailVC ()

@end

@implementation RCEventDetailVC

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSArray *)fieldsForFirstColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"date",@"key",@"eventdate",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"images",@"type",@"plain",@"output", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"long_description",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Bechreibung", @"label.description"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"type",@"full",@"output",RCLocalizedString(@"Videos", @"label.videos"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"external_links",@"key",@"external_links",@"type",@"full",@"output",RCLocalizedString(@"Externe Links", @"label.external_links"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"location",@"key",@"eventplace",@"type",@"full",@"output",RCLocalizedString(@"Veranstaltungsort", @"label.venue"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"",@"key",@"dummy",@"type",@"full",@"output",RCLocalizedString(@"Kontakt", @"label.contact"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact_person",@"key",@"string",@"type",@"labeled",@"output",RCLocalizedString(@"Ansprechpartner", @"label.contact_person"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"email",@"key",@"string",@"type",@"labeled",@"output",RCLocalizedString(@"EMail", @"label.email"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"key",@"string",@"type",@"labeled",@"output",RCLocalizedString(@"Telefon", @"label.phone"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"fax",@"key",@"string",@"type",@"labeled",@"output",RCLocalizedString(@"Fax", @"label.fax"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Kontakt", @"label.contact"),@"title", nil],
            nil];
}

- (NSArray *)fieldsForSecondColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"files",@"type",@"full",@"output",RCLocalizedString(@"Downloads", @"label.downloads"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"linked_articles",@"type",@"full",@"output",RCLocalizedString(@"Zugeordnete Artikel", @"label.linked_articles"),@"title",nil],
            nil];
}

- (NSString*)fetchValueForFieldWithType:(NSString*)type key:(NSString *)key
{
    if([type isEqualToString:@"eventdate"])
    {
        NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
        [fmt setDateStyle:NSDateFormatterShortStyle];
        [fmt setTimeStyle:NSDateFormatterShortStyle];
        return [NSString stringWithFormat:@"<h2>%@ - %@ | %@",[fmt stringFromDate:self.article.start_date],[fmt stringFromDate:self.article.end_date],self.article.city];
    }
    else if([type isEqualToString:@"eventplace"])
    {
        if(self.article.organized_by==nil && self.article.street==nil && self.article.street_nr==nil && self.article.zip==nil && self.article.city==nil)
            return nil;
        return [NSString stringWithFormat:@"%@<br/>%@ %@<br/>%@ %@<br/>",self.article.venue,self.article.street,self.article.street_nr,self.article.zip,self.article.city];
    }
    else
        return [super fetchValueForFieldWithType:type key:key];
}

- (void)createAndDisplayEventInStore:(EKEventStore*)store
{
    EKEvent *event=[EKEvent eventWithEventStore:store];
    event.title=self.article.title;
    event.location=[NSString stringWithFormat:@"%@ %@,%@ %@",self.article.street,self.article.street_nr,self.article.zip,self.article.city];
    event.startDate=self.article.start_date;
    event.endDate=self.article.end_date;
    EKEventEditViewController *edit=[[EKEventEditViewController alloc] init];
    edit.eventStore=store;
    edit.event=event;
    edit.editViewDelegate=self;
    self.calEditor=edit;
    self.store=store;
    self.event=event;
    [self presentViewController:edit animated:YES completion:nil];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.store=nil;
    self.event=nil;
}

- (void)onDetailAction:(id)sender
{
    if(self.sheetController!=nil)
    {
        [self.sheetController.sheet dismissWithClickedButtonIndex:-1 animated:YES];
        self.sheetController=nil;
        return;
    }
    self.sheetController=[[RCActionSheetController alloc] init];
    __weak RCEventDetailVC *me=self;
    
    [self.sheetController addItemWithTitle:RCLocalizedString(@"In Kalender übernehmen", @"label.add_to_calendar") callback:^{
        RCEventDetailVC *mirror=me;
        mirror.sheetController=nil;
        EKEventStore *store=[[EKEventStore alloc] init];
        if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
        {
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *err){
                if(granted)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [mirror createAndDisplayEventInStore:store];
                    });
                }
            }];
        }
        else
        {
            [mirror createAndDisplayEventInStore:store];
        }
    }];
    
    [self.sheetController addItemWithTitle:RCLocalizedString(@"Auf Karte anzeigen", @"label.show_location_on_maps") callback:^{
        RCEventDetailVC *myself=me;
        myself.sheetController=nil;
        NSMutableString *builder=[[NSMutableString alloc] init];
        [builder appendFormat:@"http://maps.google.com/?q=%@+%@,%@+%@",[myself.article.street stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[myself.article.street_nr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[myself.article.zip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[myself.article.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:builder]];
        
    }];
    self.sheetController.sheet=[[UIActionSheet alloc] initWithTitle:RCLocalizedString(@"Weitere Funktionen", @"label.more_features") delegate:self.sheetController cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    self.sheetController.onCancel=^{
        RCEventDetailVC *myself=me;
        myself.sheetController=nil;
    };
    
    [self.sheetController prepareSheet];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.sheetController.sheet showFromBarButtonItem:sender animated:YES];
    }
    else
    {
        [self.sheetController.sheet showFromTabBar:self.tabBarController.tabBar];
    }
}


@end
