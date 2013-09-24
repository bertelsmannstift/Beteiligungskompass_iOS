//
//  RCAddCriteriaVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCAddCriteriaVC.h"
#import "RCAddNodeContainerViewController.h"
#import "RCAddCriteriaCell.h"
#import "RCAddCriteriaOptionsVC.h"
#import "RCAddCriteriaResourceCell.h"

@interface RCAddCriteriaVC ()

@end

@implementation RCAddCriteriaVC

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.criteria=[Criterion fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"any contexts.articletype=%@",self.addController.article.type] inContext:self.appDelegate.managedObjectContext];
    self.criteria=[self.criteria sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.criteria.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==self.criteria.count)
        return 44;
    Criterion *criterion=[self.criteria objectAtIndex:indexPath.row];
    if(![criterion.type isEqualToString:@"resource"])
        return 44;
    return 71;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==self.criteria.count)
    {
        return [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
    }
    Criterion *criterion=[self.criteria objectAtIndex:indexPath.row];
    if(![criterion.type isEqualToString:@"resource"])
    {
        RCAddCriteriaCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.criterion=criterion;
        cell.article=self.addController.article;
        [cell fill];
        return cell;
    }
    else
    {
        RCAddCriteriaResourceCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Progress"];
        cell.criterion=criterion;
        cell.article=self.addController.article;
        [cell fill];
        return cell;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCAddCriteriaOptionsVC class]])
    {
        RCAddCriteriaOptionsVC *ctrl=segue.destinationViewController;
        ctrl.article=self.addController.article;
        ctrl.criterion=[self.criteria objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
