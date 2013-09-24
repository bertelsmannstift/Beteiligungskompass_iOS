//
//  RCFilterVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCFilterVC.h"
#import "RCFilterSelectionVC.h"
#import "RCResourceFilterCell.h"
#import "RCFilterCell.h"

@interface RCFilterVC ()

@end

@implementation RCFilterVC
@synthesize criteria=_criteria;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCListUpdatedNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        self.tableView.scrollsToTop=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdate:) name:RCListUpdatedNotification object:nil];
    self.title=RCLocalizedString(@"Filter", @"label.filter");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadFilter
{
    self.criteria=[self.appDelegate.criteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY criterion.contexts.articletype=%@",self.appDelegate.currentType]];
    self.criteria=[self.criteria sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"criterion.orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"show_in_planner" ascending:YES],nil]];
    Criterion *criterion=[[Criterion fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"ANY grouping.articletype=%@",self.appDelegate.currentType] inContext:self.appDelegate.managedObjectContext] lastObject];
    if(criterion!=nil)
    {
        id containment=[[self.criteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"criterion=%@",criterion]] lastObject];
        if(containment!=nil)
        {
            self.criteria=[self.criteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"criterion!=%@",criterion]];
            self.criteria=[[NSArray arrayWithObject:containment] arrayByAddingObjectsFromArray:self.criteria];
        }
    }
    [self.tableView reloadData];
}

- (void)onUpdate:(NSNotification*)notification
{
    [self loadFilter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFilter];
    self.searchBar.text=self.appDelegate.searchTerm;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.criteria.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id elem=[self.criteria objectAtIndex:indexPath.row];
    Criterion *criterion=[elem objectForKey:@"criterion"];
    NSArray *items=[elem objectForKey:@"selection"];
    CGSize base;
    NSMutableString *text=[[NSMutableString alloc] init];
    BOOL first=YES;
    if([criterion.discriminator isEqualToString:@"country"] && items.count>1)
    {
        CriteriaOption *option=items[0];
        [text appendString:option.title];
    }
    else
    {
        for(CriteriaOption *option in items)
        {
            if(first)
                first=NO;
            else
                [text appendString:@"\n"];
            [text appendString:option.title];
        }
    }
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        base=[criterion.title sizeWithFont:[UIFont boldAppFontOfSize:15] constrainedToSize:CGSizeMake(self.view.frame.size.width-40, 2009)];
        if(items.count<2 || [criterion.type isEqualToString:@"resource"])
        {
            base.height+=21;
        }
        else
        {
            CGSize subElem=[text sizeWithFont:[UIFont appFontOfSize:13] constrainedToSize:CGSizeMake(self.view.frame.size.width-40, 2009)];
            base.height+=subElem.height;
        }
    }
    else
    {
        base=[criterion.title sizeWithFont:[UIFont boldAppFontOfSize:15] constrainedToSize:CGSizeMake(280, 2009)];
        if(items.count<2 || [criterion.type isEqualToString:@"resource"])
        {
            base.height+=21;
        }
        else
        {
            CGSize subElem=[text sizeWithFont:[UIFont appFontOfSize:13] constrainedToSize:CGSizeMake(self.view.frame.size.width-40, 2009)];
            base.height+=subElem.height;
        }
    }
    if([criterion.type isEqualToString:@"resource"])
    {
        return 71-21-21+base.height;
    }
    else
    {
        return 44-21-21+base.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id elem=[self.criteria objectAtIndex:indexPath.row];
    Criterion *criterion=[elem objectForKey:@"criterion"];
    if([criterion.type isEqualToString:@"resource"])
    {
        RCResourceFilterCell *cell=(RCResourceFilterCell*)[tableView dequeueReusableCellWithIdentifier:@"Progress"];
        cell.elem=elem;
        [cell fill];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        RCFilterCell *cell = (RCFilterCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.criterion=elem;
        [cell fill];

        return cell;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"filterselect"])
    {
        RCFilterSelectionVC *ctrl=segue.destinationViewController;
        ctrl.criterion=[self.criteria objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

#pragma mark - Table view delegate


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton=YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton=NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.appDelegate.searchTerm=searchBar.text;
    [self.appDelegate buildList];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""])
    {
        self.appDelegate.searchTerm=nil;
        [self.appDelegate buildList];
        [self.tableView reloadData];
    }
}


@end
