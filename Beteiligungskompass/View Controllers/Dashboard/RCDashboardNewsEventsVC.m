//
//  RCDashboardNewsEventsVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCDashboardNewsEventsVC.h"
#import "RCArticleCell.h"
#import "RCArticleDetailVC.h"
#import "RCDashBoardViewController.h"
#import "RCModuleManagement.h"
#import "RCBaseSettings.h"

@interface RCDashboardNewsEventsVC ()

@end

@implementation RCDashboardNewsEventsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)buildDataSource
{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:[Article entityInContext:self.appDelegate.managedObjectContext]];
    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval: -(60*60*24*30)];
    [request setPredicate:[NSPredicate predicateWithFormat:@"type=%@ and date > %@",@"news",newDate]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    [request setFetchLimit:2];
    self.newsResults=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.newsResults.delegate=self;
    [self.newsResults performFetch:nil];
    
    request=[[NSFetchRequest alloc] init];
    [request setEntity:[Article entityInContext:self.appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"type=%@ and start_date>%@",@"event",[NSDate date]]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES]]];
    [request setFetchLimit:2];
    self.eventsResults=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.eventsResults.delegate=self;
    [self.eventsResults performFetch:nil];
    
    NSMutableArray *buf=[NSMutableArray array];
    if([[RCModuleManagement instance] isModuleEnabled:@"news"] && [[RCBaseSettings instance] isModuleEnabled:@"newsbox"])
    {
        [buf addObject:self.newsResults];
    }
    if([[RCModuleManagement instance] isModuleEnabled:@"event"] && [[RCBaseSettings instance] isModuleEnabled:@"eventbox"])
    {
        [buf addObject:self.eventsResults];
    }
    self.sections=buf;
    [self.tableView reloadData];
}

- (void)onModuleUpdate:(id)something
{
    [self buildDataSource];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildDataSource];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModuleUpdate:) name:@"ModuleStatesChanged" object:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSFetchedResultsController *ctrl=self.sections[section];
    return ctrl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *ctrl=self.sections[indexPath.section];
    Article *object=ctrl.fetchedObjects[indexPath.row];
    RCArticleCell *cell=[tableView dequeueReusableCellWithIdentifier:object.type];
    cell.article=object;
    [cell fill];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RCArticleDetailVC *ctrl=segue.destinationViewController;
    NSIndexPath *path=[self.tableView indexPathForCell:sender];
    NSFetchedResultsController *results=self.sections[path.section];
    Article *article=results.fetchedObjects[path.row];
    ctrl.article=article;
    ctrl.articles=@[article];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[[NSBundle mainBundle] loadNibNamed:@"DashboardNewsEventsHeader" owner:self options:nil] objectAtIndex:0];
    UILabel *label=view.subviews[0];
    UILabel *detailLabel=view.subviews[1];
    if(self.sections[section]==self.newsResults)
    {
        label.text=RCLocalizedString(@"News", @"module.news.title.dashheader");
        label.tag=1;
        detailLabel.tag=1;
        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval: -(60*60*24*30)];
        detailLabel.text=[NSString stringWithFormat:@"%@ (%d)",RCLocalizedString(@"› weitere News", @"module.news.dashmore"),
                          [Article numberOfObjectsMatchingPredicate:[NSPredicate predicateWithFormat:@"type=%@ and date > %@",@"news",newDate] inContext:self.appDelegate.managedObjectContext]];
    }
    else
    {
        label.text=RCLocalizedString(@"Nächste Veranstaltungen", @"module.events.title.dashheader");
        label.tag=2;
        detailLabel.tag=2;
        detailLabel.text=[NSString stringWithFormat:@"%@ (%d)",RCLocalizedString(@"› weitere Veranstaltungen", @"module.events.dashmore"),
                          [Article numberOfObjectsMatchingPredicate:[NSPredicate predicateWithFormat:@"type=%@ and start_date>%@",@"event",[NSDate date]] inContext:self.appDelegate.managedObjectContext]];
    }
    return view;
}

- (IBAction)onHeaderPress:(UITapGestureRecognizer*)sender
{
    RCDashBoardViewController *dash=(RCDashBoardViewController*)self.parentViewController;
    UILabel *view=(UILabel*)sender.view;
    if(view.tag==1)
        [dash onNews:nil];
    else
        [dash onEvents:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end
