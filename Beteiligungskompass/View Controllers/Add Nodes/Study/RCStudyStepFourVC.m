//
//  RCStudyStepThreeVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCStudyStepFourVC.h"
#import "RCAddNodeContainerViewController.h"
#import "SBJson.h"
#import "RCSelectArticlesVC.h"

@interface RCStudyStepFourVC ()

@end

@implementation RCStudyStepFourVC

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id data=[self.addController.article.linking_json JSONValue];
    UILabel *label=[[self.labels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=0"]] lastObject];
    if([[data objectForKey:@"study"] count]==0)
        label.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    else
        label.text=[NSString stringWithFormat:RCLocalizedString(@"%d ausgewählt", @"label.amount"),[[data objectForKey:@"study"] count]];
    
    label=[[self.labels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=1"]] lastObject];
    if([[data objectForKey:@"method"] count]==0)
        label.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    else
        label.text=[NSString stringWithFormat:RCLocalizedString(@"%d ausgewählt", @"label.amount"),[[data objectForKey:@"method"] count]];
    
    label=[[self.labels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=2"]] lastObject];
    if([[data objectForKey:@"qa"] count]==0)
        label.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    else
        label.text=[NSString stringWithFormat:RCLocalizedString(@"%d ausgewählt", @"label.amount"),[[data objectForKey:@"qa"] count]];
    
    label=[[self.labels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=3"]] lastObject];
    if([[data objectForKey:@"expert"] count]==0)
        label.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    else
        label.text=[NSString stringWithFormat:RCLocalizedString(@"%d ausgewählt", @"label.amount"),[[data objectForKey:@"expert"] count]];
    
    label=[[self.labels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=4"]] lastObject];
    if([[data objectForKey:@"news"] count]==0)
        label.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    else
        label.text=[NSString stringWithFormat:RCLocalizedString(@"%d ausgewählt", @"label.amount"),[[data objectForKey:@"news"] count]];
    
    label=[[self.labels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=5"]] lastObject];
    if([[data objectForKey:@"event"] count]==0)
        label.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    else
        label.text=[NSString stringWithFormat:RCLocalizedString(@"%d ausgewählt", @"label.amount"),[[data objectForKey:@"event"] count]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCSelectArticlesVC class]])
    {
        RCSelectArticlesVC *ctrl=segue.destinationViewController;
        ctrl.article=self.addController.article;
        ctrl.typeFilter=segue.identifier;
    }
}
@end
