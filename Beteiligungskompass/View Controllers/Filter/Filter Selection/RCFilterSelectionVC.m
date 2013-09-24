//
//  RCFilterSelectionVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCFilterSelectionVC.h"

@interface RCFilterSelectionVC ()

@end

@implementation RCFilterSelectionVC
@synthesize criterion=_criterion;
@synthesize options=_options;

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
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.tableView.scrollsToTop=NO;
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)onUpdate:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Criterion *criterion=[self.criterion objectForKey:@"criterion"];
    self.title=criterion.title;
    if([criterion.discriminator isEqualToString:@"country"])
    {
        //this is tricky. we have to build the resulting array on our own
        NSArray *step=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parent = null"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"default_value" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
        self.options=[NSArray array];
        for(CriteriaOption *option in step)
        {
            if([option.articles filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type==%@",self.appDelegate.currentType]].count>0 || self.planningMode)
            {
                self.options=[self.options arrayByAddingObject:option];
                step=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parent=%@",option]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"default_value" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
                self.options=[self.options arrayByAddingObjectsFromArray:step];
            }
        }
    }
    else
    {
        self.options=[criterion.options sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"default_value" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
        if(!self.planningMode)
        {
            self.options=[self.options filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(CriteriaOption *option, NSDictionary *bindings){
                return (BOOL)([[option.articles filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type==%@",self.appDelegate.currentType]] count]>0);
            }]];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdate:) name:RCListUpdatedNotification object:nil];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCListUpdatedNotification object:nil];
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
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CriteriaOption *option=[self.options objectAtIndex:indexPath.row];
    cell.textLabel.text=option.title;
    if(option.parent!=nil)
    {
        cell.textLabel.text=[NSString stringWithFormat:@"- %@",option.title];
    }
    BOOL isDefaultAndSelected=[option.default_value boolValue] && [[self.criterion objectForKey:@"selection"] count]==0;
    if([[self.criterion objectForKey:@"selection"] containsObject:option] || isDefaultAndSelected)
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CriteriaOption *option=[self.options objectAtIndex:indexPath.row];
    Criterion *criterion=[self.criterion objectForKey:@"criterion"];
    NSMutableArray *selection=[self.criterion objectForKey:@"selection"];
    if([option.default_value boolValue])
    {
        [selection removeAllObjects];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if([criterion.type isEqualToString:@"radio"] || [criterion.type isEqualToString:@"select"])
        {
            BOOL objectContained = [selection containsObject: option];
            [selection removeAllObjects];
            
            if(!objectContained)
                [selection addObject:option];
            
            if(option.childs!=nil && (!objectContained || ![criterion.discriminator isEqualToString:@"country"]))
            {
                [selection addObjectsFromArray:[option.childs allObjects]];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if([criterion.type isEqualToString:@"check"])
        {
            if([selection containsObject:option])
                [selection removeObject:option];
            else
                [selection addObject:option];
            
            [self.tableView reloadData];
        }
    }
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.tableView reloadData];
    }
    [self.appDelegate buildList];
    
    // Backtracking if zero results
    if(self.appDelegate.numberOfAllPlannedObjects == 0)
    {  
        NSMutableArray *selection = [self.criterion objectForKey: @"selection"];
        [selection removeObject: option];
        [self.tableView reloadData];
        [self.appDelegate buildList];
        
        [self.appDelegate buildList];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                        message: RCLocalizedString(@"Keine Artikel gefunden", @"label.message_no_article_found")
                                                       delegate: nil cancelButtonTitle: RCLocalizedString(@"OK", @"label.ok")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

@end