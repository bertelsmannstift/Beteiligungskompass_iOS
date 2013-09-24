//
//  RCAddCriteriaOptionsVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCAddCriteriaOptionsVC.h"
#import "SBJson.h"

@interface RCAddCriteriaOptionsVC ()

@end

@implementation RCAddCriteriaOptionsVC

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selection=[[self.article.criteria_json JSONValue] mutableCopy];
    if(self.selection==nil)
        self.selection=[NSMutableArray array];
    self.options=[self.criterion.options sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    if(![self.criterion.type isEqualToString:@"select"])
        self.options=[self.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"default_value=NO"]];
    
    if([self.criterion.discriminator isEqualToString:@"country"])
    {
        //this is tricky. we have to build the resulting array on our own
        NSArray *step=[[self.criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parent = null"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"default_value" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
        self.options=[NSArray array];
        for(CriteriaOption *option in step)
        {
            self.options=[self.options arrayByAddingObject:option];
            step=[[self.criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parent=%@",option]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"default_value" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
            self.options=[self.options arrayByAddingObjectsFromArray:step];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.article.criteria_json=[self.selection JSONRepresentation];
}

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
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CriteriaOption *option=[self.options objectAtIndex:indexPath.row];
    cell.textLabel.text=option.title;
    if(option.parent!=nil)
        cell.textLabel.text=[@"- " stringByAppendingString:option.title];
    if([self.selection containsObject:option.id_from_import])
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.criterion.type isEqualToString:@"select"])
    {
        for(CriteriaOption *option in self.options)
        {
            if([self.selection containsObject:option.id_from_import])
            {
                [self.selection removeObject:option.id_from_import];
            }
        }
        CriteriaOption *option=[self.options objectAtIndex:indexPath.row];
        if(![option.default_value boolValue])
            [self.selection addObject:option.id_from_import];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        CriteriaOption *option=[self.options objectAtIndex:indexPath.row];
        if([self.selection containsObject:option.id_from_import])
            [self.selection removeObject:option.id_from_import];
        else
            [self.selection addObject:option.id_from_import];
        [self.tableView reloadData];
    }
}

@end
