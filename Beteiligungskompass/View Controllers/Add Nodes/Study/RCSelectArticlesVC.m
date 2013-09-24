//
//  RCSelectArticlesVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCSelectArticlesVC.h"
#import "SBJson.h"

@interface RCSelectArticlesVC ()

@end

@implementation RCSelectArticlesVC

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
    id data=[self.article.linking_json JSONValue];
    self.selection=[[data objectForKey:self.typeFilter] mutableCopy];
    if(self.selection==nil)
        self.selection=[NSMutableArray array];
    self.articles=[Article fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type=%@ and (is_custom=NO or is_custom=nil)",self.typeFilter] inContext:self.appDelegate.managedObjectContext];
    self.articles=[self.articles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"printableName" ascending:YES]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.articles.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Article *article=[self.articles objectAtIndex:indexPath.row];
    cell.textLabel.text=article.printableName;
    if([self.selection containsObject:article.id_from_import])
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article=[self.articles objectAtIndex:indexPath.row];
    if([self.selection containsObject:article.id_from_import])
    {
        [self.selection removeObject:article.id_from_import];
    }
    else
        [self.selection addObject:article.id_from_import];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSMutableDictionary *data=[[self.article.linking_json JSONValue] mutableCopy];
    if(data==nil)
        data=[NSMutableDictionary dictionary];
    [data setObject:self.selection forKey:self.typeFilter];
    self.article.linking_json=[data JSONRepresentation];
}

@end
