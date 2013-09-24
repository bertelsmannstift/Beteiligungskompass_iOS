//
//  RCDashboardButtonsVCViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCDashboardButtonsVC.h"
#import "RCDashBoardViewController.h"
#import "RCModuleManagement.h"

@interface RCDashboardButtonsVC ()

@end

@implementation RCDashboardButtonsVC {
    NSArray *buttons;
}

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
    NSMutableArray *tmp=[NSMutableArray array];
    [tmp addObject:@"plan"];
    
    for(NSString *mode in @[@"study",@"method",@"qa",@"expert",@"event",@"news"])
    {
        if([[RCModuleManagement instance] isModuleEnabled:mode])
        {
            [tmp addObject:mode];
        }
    }
    buttons=tmp;
    [self.tableView reloadData];
}

- (void) onModuleUpdate:(id)something
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return buttons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = buttons[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    return cell;
}


- (RCDashBoardViewController*)container
{
    return (RCDashBoardViewController*)self.parentViewController;
}

- (IBAction)onProjects:(id)sender
{
    [[self container] onProjects:sender];
}

- (IBAction)onMethods:(id)sender
{
    [[self container] onMethods:sender];
}

- (IBAction)onQA:(id)sender
{
    [[self container] onQA:sender];
}

- (IBAction)onExperts:(id)sender
{
    [[self container] onExperts:sender];
}

- (IBAction)onEvents:(id)sender
{
    [[self container] onEvents:sender];
}

- (IBAction)onNews:(id)sender
{
    [[self container] onNews:sender];
}

- (IBAction)onPlan:(id)sender
{
    [[self container] onPlan:sender];
}

- (IBAction)onSlide:(id)sender
{
    [[self container] onSlide:sender];
}

- (IBAction)onBasics:(id)sender
{
    [[self container] onBasics:sender];
}

@end
