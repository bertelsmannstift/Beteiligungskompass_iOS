//
//  RCPlannerVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerVC.h"
#import "RCPlannerFilterCell.h"
#import "RCPlannerSliderCell.h"
#import "RCFilterSelectionVC.h"
#import "RCModuleManagement.h"
#import "RCBaseSettings.h"

@interface RCPlannerVC ()

@end

@implementation RCPlannerVC

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
    self.title=RCLocalizedString(@"Vorhaben planen", @"module.planning.title");
    [[NSBundle mainBundle] loadNibNamed:@"PlanningFooter" owner:self options:nil];
    [self.view addSubview:self.footer];
    self.footer.frame=CGRectMake(0, CGRectGetMaxY(self.view.bounds)-self.footer.frame.size.height, self.view.bounds.size.width, self.footer.frame.size.height);
    [self.view bringSubviewToFront:self.footer];
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, self.footer.frame.size.height, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterResetCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FilterReset"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setFooter:nil];
    [self setMethodsBtn:nil];
    [self setSamplesBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLayoutSubviews
{
    [self.view bringSubviewToFront:self.footer];
    self.footer.frame=CGRectMake(0, CGRectGetMaxY(self.view.bounds)-self.footer.frame.size.height, self.view.bounds.size.width, self.footer.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.footer.frame=CGRectMake(0, CGRectGetMaxY(self.view.bounds)-self.footer.frame.size.height, self.view.bounds.size.width, self.footer.frame.size.height);

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) update
{
    if([self.appDelegate.fetchCounts allKeys].count==0)return;
    int methodCount=[[self.appDelegate.fetchCounts objectForKey:@"method"] intValue];
    int studyCount=[[self.appDelegate.fetchCounts objectForKey:@"study"] intValue];
    int sum =
    studyCount
    + methodCount
    + ([[RCModuleManagement instance] isModuleEnabled:@"qa"] ?[[self.appDelegate.fetchCounts objectForKey:@"qa"] intValue] : 0)
    + ([[RCModuleManagement instance] isModuleEnabled:@"expert"] ? [[self.appDelegate.fetchCounts objectForKey:@"expert"] intValue] : 0)
    + ([[RCModuleManagement instance] isModuleEnabled:@"event"] ? [[self.appDelegate.fetchCounts objectForKey:@"event"] intValue] : 0)
    + ([[RCModuleManagement instance] isModuleEnabled:@"news"] ? [[self.appDelegate.fetchCounts objectForKey:@"news"] intValue] : 0);
    self.sliderBtn.title=[NSString stringWithFormat:@"%@: %d",RCLocalizedString(@"Ergebnisse",@"label.results"),sum];
    
    [self.methodsBtn setTitle:[NSString stringWithFormat:@"%@ (%d)",RCLocalizedString(@"Methoden", @"module.methods.title"),methodCount] forState:UIControlStateNormal];
    [self.samplesBtn setTitle:[NSString stringWithFormat:@"%@ (%d)",RCLocalizedString(@"Beispiele", @"module.studies.title"),studyCount] forState:UIControlStateNormal];
    
    self.appDelegate.numberOfAllPlannedObjects = sum;
}

- (void)onUpdate:(NSNotification*)notification
{
    NSIndexPath *selection=[self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:selection animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self update];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.searchBar.text=self.appDelegate.searchTerm;
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
    [self update];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdate:) name:RCListUpdatedNotification object:nil];

    self.criteria=[[self.appDelegate.criteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.show_in_planner=YES"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"criterion.orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"criterion.title" ascending:YES], nil]];
    [self.tableView reloadData];
    [self scrollViewDidScroll:(id)self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCListUpdatedNotification object:nil];
    [super viewWillDisappear:animated];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.appDelegate buildList];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
        return self.criteria.count;
    else// if(section==0)
    {
        BOOL filterSet=NO;
        for(id elem in self.appDelegate.criteria)
        {
            if([[elem objectForKey:@"selection"] count]>0)
                filterSet=YES;
        }
        return (filterSet ? 1 : 0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return [tableView dequeueReusableCellWithIdentifier:@"FilterReset"];
    }
    indexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    id elem=[self.criteria objectAtIndex:indexPath.row];
    Criterion *criterion=[elem objectForKey:@"criterion"];
    if([criterion.type isEqualToString:@"resource"])
    {
        RCPlannerSliderCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SliderCell"];
        cell.ctrl=self;
        cell.criterion=elem;
        [cell fill];
        return cell;
    }
    else
    {
        RCPlannerFilterCell *cell=[tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
        cell.criterion=elem;
        [cell fill];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
        return 44;
    indexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
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
        base=[criterion.criterionDescription sizeWithFont:[UIFont boldAppFontOfSize:15] constrainedToSize:CGSizeMake(self.view.frame.size.width-40, 2009)];
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
        base=[criterion.criterionDescription sizeWithFont:[UIFont boldAppFontOfSize:15] constrainedToSize:CGSizeMake(280, 2009)];
        if(items.count<1 || [criterion.type isEqualToString:@"resource"])
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    id elem=[self.criteria objectAtIndex:indexPath.row];
    NSMutableArray *items=[elem objectForKey:@"selection"];
    Criterion *criterion=[elem objectForKey:@"criterion"];
    if([criterion.type isEqualToString:@"resource"])
    {
        return UITableViewCellEditingStyleNone;
    }
    if(items.count>0)return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RCLocalizedString(@"Zurücksetzen", @"label.reset");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    id elem=[self.criteria objectAtIndex:indexPath.row];
    NSMutableArray *array=[elem objectForKey:@"selection"];
    [array removeAllObjects];
    [self.appDelegate buildList];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            [self performSegueWithIdentifier:@"loadEmpty" sender:nil];
        [self.appDelegate buildCriteria];
        [self.appDelegate buildList];
        [self update];
        self.criteria=[[self.appDelegate.criteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.show_in_planner=YES"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"criterion.orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"criterion.title" ascending:YES], nil]];
        [self.tableView reloadData];
    }
}

- (void)onSlide:(id)sender
{
    if(self.slideViewController.isSideViewControllerVisible)
        [self.slideViewController slideOut];
    else
        [self.slideViewController slideIn];
}

- (void)showResults
{
    UINavigationController *navCtrl;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        UISplitViewController *viewController=(UISplitViewController*)self.slideViewController.mainViewController;
        if([viewController isKindOfClass:[UINavigationController class]])
            navCtrl=(UINavigationController*)viewController;
        else
            navCtrl=(UINavigationController *)[viewController.viewControllers objectAtIndex:1];
    }
    else
    {
        navCtrl=(UINavigationController*)self.slideViewController.mainViewController;
    }
    [navCtrl popToRootViewControllerAnimated:NO];
    [navCtrl setNavigationBarHidden:NO];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if(self.slideViewController.tabBarController.tabBar.hidden)
        {
            self.slideViewController.tabBarController.tabBar.hidden=NO;
            for(UIView *view in self.slideViewController.tabBarController.view.subviews)
            {
                if(view!=self.slideViewController.tabBarController.tabBar)
                {
                    CGRect frame=view.frame;
                    frame.size.height-=self.slideViewController.tabBarController.tabBar.frame.size.height;
                    view.frame=frame;
                }
            }
        }
    }
    [self.tabBarController.view layoutIfNeeded];
    int idx=self.tabBarController.selectedIndex;
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=idx;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onMethods:(id)sender {
    self.appDelegate.currentType=@"method";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"method"];//@"title";
    [self.appDelegate buildList];
    [self showResults];
}

- (IBAction)onSamples:(id)sender {
    self.appDelegate.currentType=@"study";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"study"];//@"created";
    [self.appDelegate buildList];
    [self showResults];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCFilterSelectionVC class]] && sender!=nil)
    {
        RCFilterSelectionVC *ctrl=segue.destinationViewController;
        ctrl.planningMode=YES;
        NSIndexPath *path=[self.tableView indexPathForCell:(UITableViewCell*)sender];
        ctrl.criterion=[self.criteria objectAtIndex:path.row];
    }
}

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
    [self.appDelegate buildList];
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
