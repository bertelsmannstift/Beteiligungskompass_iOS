//
//  RCArticleCriteriaList.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleCriteriaList.h"
#import "RCArticleCriteriaListSection.h"

@interface RCArticleCriteriaList ()

@end

@implementation RCArticleCriteriaList

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
    self.title=RCLocalizedString(@"Kriterien", @"label.criteria");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated: animated];
    
    self.criteria=[[Criterion fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"ANY options in %@",self.article.options] inContext:self.appDelegate.managedObjectContext] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    self.expandedSections=[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.criteria.count)];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.criteria.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RCArticleCriteriaListSection *sectionView=[[[NSBundle mainBundle] loadNibNamed:@"ArticleCriteriaListSection" owner:self options:nil] objectAtIndex:0];
    sectionView.secIndex=section;
    sectionView.expandedSections=self.expandedSections;
    sectionView.tableView=self.tableView;
    Criterion *criterion=[self.criteria objectAtIndex:section];
    sectionView.descriptionLabel.text=criterion.title;
    [sectionView fill];
    return sectionView;
}


- (NSArray *)optionsForCriterionAtIndex:(int)idx
{
    Criterion *criterion=[self.criteria objectAtIndex:idx];
    NSArray *options=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self in %@",self.article.options]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
    return options;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(![self.expandedSections containsIndex:section])return 0;
    NSArray *options=[self optionsForCriterionAtIndex:section];
    return options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *options=[self optionsForCriterionAtIndex:indexPath.section];
    CriteriaOption *option=[options objectAtIndex:indexPath.row];
    CGSize size=[option.title sizeWithFont:[UIFont appFontOfSize:13] constrainedToSize:CGSizeMake(280, 2009)];
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    UILabel *label=(UILabel*)[cell viewWithTag:1];
    CriteriaOption *option=[[self optionsForCriterionAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    label.text=option.title;
    return cell;
}

@end
