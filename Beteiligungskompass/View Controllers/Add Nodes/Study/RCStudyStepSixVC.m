//
//  RCStudyStepSixVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCStudyStepSixVC.h"
#import "RCAddNodeContainerViewController.h"
#import "SBJson.h"
#import "NSData+Base64Conversion.h"

@interface RCStudyStepSixVC ()

@end

@implementation RCStudyStepSixVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deleteArticle:(id)sender
{
    [self.appDelegate.managedObjectContext deleteObject:self.addController.article];
    [self.appDelegate.managedObjectContext save:nil];
    [self.addController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:RCEditingClosedNotification object:self];

}

- (void)saveArticle:(id)sender
{
    if(self.storeLocally.accessoryType==UITableViewCellAccessoryCheckmark)
    {
        [self.appDelegate.managedObjectContext save:nil];
        [self.addController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:RCArticleSavedNotification object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:RCEditingClosedNotification object:self];
        [[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Artikelstatus", @"label.dialog_send_article_title")
                                    message:RCLocalizedString(@"Der Artikel wurde versendet.\nBis zur Veröffentlichung wird dieser nicht auf dem Gerät angezeigt.", @"label.dialog_send_article_for_editing")
                                   delegate:nil
                          cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                          otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *body=[NSMutableDictionary dictionary];
        NSMutableDictionary *article=[NSMutableDictionary dictionary];
        [body setObject:article forKey:@"article"];
        Article *base=self.addController.article;
        if([base.type isEqualToString:@"study"])
        {
            if(base.title==nil || base.title.length==0)
            {
                [[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Validierung fehlgeschlagen", @"label.error_validation_title")
                                            message:RCLocalizedString(@"Sie müssen einen Titel im ersten Schritt angeben", @"label.error_validation")
                                           delegate:nil
                                  cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                  otherButtonTitles:nil] show];
                return;
            }
        }
        //TODO: you may add more validations here using else ifs and the pattern above!
        
        if(base.phone!=nil)
            [article setObject:base.phone forKey:@"phone"];
        if(base.restrictions!=nil)
            [article setObject:base.restrictions forKey:@"restrictions"];
        if(base.start_month!=nil)
            [article setObject:base.start_month forKey:@"start_month"];
        if(base.street!=nil)
            [article setObject:base.street forKey:@"street"];
        if(base.start_year!=nil)
            [article setObject:base.start_year forKey:@"start_year"];
        if(base.type!=nil)
            [article setObject:base.type forKey:@"type"];
        if(base.participants!=nil)
            [article setObject:base.participants forKey:@"participants"];
        if(base.city!=nil)
            [article setObject:base.city forKey:@"city"];
        if(base.criteria_json!=nil)
            [article setObject:[base.criteria_json JSONValue] forKey:@"criteriaOptions"];
        if(base.results!=nil)
            [article setObject:base.results forKey:@"results"];
//        [article setObject:base.updated forKey:@"updated"];
        if(base.participation!=nil)
            [article setObject:base.participation forKey:@"participation"];
        if(base.long_description!=nil)
            [article setObject:base.long_description forKey:@"description"];
        if(base.number_of_participants!=nil)
            [article setObject:base.number_of_participants forKey:@"number_of_participants"];
        if(base.strengths!=nil)
            [article setObject:base.strengths forKey:@"strengths"];
        
        NSMutableArray *array=[NSMutableArray array];
        id data=[base.linking_json JSONValue];
        for(NSArray *subarr in [data allValues])
        {
            [array addObjectsFromArray:subarr];
        }
        [article setObject:array forKey:@"linked_articles"];
        if(base.text!=nil)
            [article setObject:base.text forKey:@"text"];
        if(base.fax!=nil)
            [article setObject:base.fax forKey:@"fax"];
        if(base.more_information!=nil)
            [article setObject:base.more_information forKey:@"more_information"];
        if(base.organized_by!=nil)
            [article setObject:base.organized_by forKey:@"organized_by"];
        if(base.contact_person!=nil)
            [article setObject:base.contact_person forKey:@"contact_person"];
        if(base.when_not_to_use!=nil)
            [article setObject:base.when_not_to_use forKey:@"when_not_to_use"];
        [article setObject:[NSNumber numberWithBool:NO] forKey:@"deleted"];
        if(base.country!=nil)
            [article setObject:base.country forKey:@"country"];
        if(base.fee!=nil)
            [article setObject:base.fee forKey:@"fee"];
        if(base.end_month!=nil)
            [article setObject:base.end_month forKey:@"end_month"];
        if(base.description_institution!=nil)
            [article setObject:base.description_institution forKey:@"description_institution"];
        if(base.author_answer!=nil)
            [article setObject:base.author_answer forKey:@"author_answer"];
        if(base.email!=nil)
            [article setObject:base.email forKey:@"email"];
        if(base.aim!=nil)
            [article setObject:base.aim forKey:@"aim"];
        if(base.used_for!=nil)
            [article setObject:base.used_for forKey:@"used_for"];
        if(base.active!=nil)
            [article setObject:base.active forKey:@"active"];
        if(base.projectstatus!=nil)
            [article setObject:base.projectstatus forKey:@"projectstatus"];
        if(base.deadline!=nil)
            [article setObject:base.deadline forKey:@"deadline"];
        if(base.link!=nil)
            [article setObject:base.link forKey:@"link"];
        if(base.weaknesses!=nil)
            [article setObject:base.weaknesses forKey:@"weaknesses"];
        if(base.lastname!=nil)
            [article setObject:base.lastname forKey:@"lastname"];
        if(base.date!=nil)
            [article setObject:base.date forKey:@"date"];
        if(base.contact!=nil)
            [article setObject:base.contact forKey:@"contact"];
        if(base.ready_for_publish!=nil)
            [article setObject:base.ready_for_publish forKey:@"ready_for_publish"];
        if(base.street_nr!=nil)
            [article setObject:base.street_nr forKey:@"street_nr"];
        if(base.author!=nil)
            [article setObject:base.author forKey:@"author"];
        if(base.title!=nil)
            [article setObject:base.title forKey:@"title"];
        if(base.end_date!=nil)
            [article setObject:base.end_date forKey:@"end_date"];
        if(base.short_description!=nil)
            [article setObject:base.short_description forKey:@"short_description"];
        if(base.when_to_use!=nil)
            [article setObject:base.when_to_use forKey:@"when_to_use"];
        if(base.plaintext!=nil)
            [article setObject:base.plaintext forKey:@"listdescription_plaintext"];
        [article setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"auth.userid"] forKey:@"user_id"];
        if(base.question!=nil)
            [article setObject:base.question forKey:@"question"];
        if(base.institution!=nil)
            [article setObject:base.institution forKey:@"institution"];
        if(base.zip!=nil)
            [article setObject:base.zip forKey:@"zip"];
        if(base.end_year!=nil)
            [article setObject:base.end_year forKey:@"end_year"];
        if(base.origin!=nil)
            [article setObject:base.origin forKey:@"origin"];
        if(base.venue!=nil)
            [article setObject:base.venue forKey:@"venue"];
        if(base.intro!=nil)
            [article setObject:base.intro forKey:@"intro"];
        if(base.process!=nil)
            [article setObject:base.process forKey:@"process"];
        if(base.sticky!=nil)
            [article setObject:base.sticky forKey:@"sticky"];
        if(base.address!=nil)
            [article setObject:base.address forKey:@"address"];
        if(base.background!=nil)
            [article setObject:base.background forKey:@"background"];
        if(base.subtitle!=nil)
            [article setObject:base.subtitle forKey:@"subtitle"];
        if(base.time_expense!=nil)
            [article setObject:base.time_expense forKey:@"time_expense"];
        if(base.start_date!=nil)
            [article setObject:base.start_date forKey:@"start_date"];
        if(base.external_links_json!=nil)
            [article setObject:[base.external_links_json JSONValue] forKey:@"external_links"];
        NSMutableArray *images=[NSMutableArray array];
        for(Image *image in [base.images sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]])
        {
            [images addObject:@{@"name" : @"foo.jpg",@"content":[image.embedded EncodeUsingBase64]}];
        }
        [article setObject:images forKey:@"images"];
        NSString *json=[body JSONRepresentation];
        [self.parentViewController.view addSubview:self.loadingView];
        self.loadingView.frame=self.parentViewController.view.bounds;
        [self.appDelegate.comm uploadArticle:json onFinished:^(BOOL done){
            [self.loadingView removeFromSuperview];
            if(done)
            {
                for(Image *img in base.images)
                {
                    [self.appDelegate.managedObjectContext deleteObject:img];
                }
                [self.appDelegate.managedObjectContext deleteObject:base];
                [self.appDelegate.managedObjectContext save:nil];
                [self.addController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:RCEditingClosedNotification object:self];
                [[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Artikelstatus", @"label.dialog_send_article_title")
                                            message:RCLocalizedString(@"Der Artikel wurde zur Freigabe versendet.\nBis zur Freigabe wird dieser Artikel nicht angezeigt.", @"label.dialog_send_article_for_publishing")
                                           delegate:nil
                                  cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                  otherButtonTitles:nil] show];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Übertragung fehlgeschlagen", @"label.error_upload_title")
                                           message:RCLocalizedString(@"Bitte versuchen Sie es später erneut.", @"label.error_send_article")
                                          delegate:nil
                                 cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                  otherButtonTitles:nil] show];
            }
        }];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        self.storeLocally.accessoryType=UITableViewCellAccessoryCheckmark;
        self.publish.accessoryType=UITableViewCellAccessoryNone;
    }
    else
    {
        self.storeLocally.accessoryType=UITableViewCellAccessoryNone;
        self.publish.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    [self.tableView reloadData];
}


@end
