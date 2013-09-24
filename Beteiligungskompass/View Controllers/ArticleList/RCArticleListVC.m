//
//  RCArticleListVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleListVC.h"
#import "RCArticleCell.h"
#import "RCArticleSectionHeaderView.h"
#import "RCArticleDetailVC.h"
#import "RCArticleSideVC.h"
#import "RCModuleManagement.h"

#import "Article.h"
#import <QuartzCore/QuartzCore.h>

@interface RCArticleListVC ()
@end

@implementation RCArticleListVC
@synthesize navBtns=_navBtns;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if(self.splitViewController!=nil)
    {
        self.splitViewController.delegate=self;
        self.splitViewController.presentsWithGesture=NO;
    }
}

- (void)viewDidUnload
{
    [self setEmptyResultLabel:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCListUpdatedNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSBundle mainBundle] loadNibNamed:@"NoResultsLabel" owner:self options:nil];
    self.EmptyResultLabel.layer.cornerRadius=6;
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterResetCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FilterReset"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdate:) name:RCListUpdatedNotification object:nil];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.navBtns];
    self.navBtns.barStyle=-1;
    if(self.leftBar!=nil)
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.leftBar];
    self.leftBar.barStyle=-1;
    self.title=RCLocalizedString(@"Kategorien", @"label.categories");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark -
#pragma mark Data Update

- (void)onUpdate:(NSNotification *)notification
{
    NSDictionary *countCopy=[self.appDelegate.fetchCounts copy];
    BOOL filtered = NO;
    for(NSDictionary *dictionary in self.appDelegate.criteria)
    {
        if(((NSArray *)[dictionary valueForKey: @"selection"]).count > 0)
            filtered = YES;
    }

    // Color yellow if filtered
    self.filterBtn.tintColor = filtered ? [UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000] : nil;


    if([countCopy allKeys].count>0  && countCopy!=nil)
    {
        NSExpressionDescription *eD=[[NSExpressionDescription alloc] init];
        eD.name=@"count";
        eD.expression=[NSExpression expressionForFunction:@"count:" arguments:@[[NSExpression expressionForKeyPath:@"type"]]];
        NSFetchRequest *request=[[NSFetchRequest alloc] init];
        [request setEntity:[Article entityInContext:self.appDelegate.managedObjectContext]];
        [request setPropertiesToFetch:@[@"type",eD]];
        [request setPropertiesToGroupBy:@[@"type"]];
        [request setResultType:NSDictionaryResultType];
        NSArray *results=[self.appDelegate.managedObjectContext executeFetchRequest:request error:nil];
        for(id elem in results)
        {
            NSString *type=[elem objectForKey:@"type"];
            int count=[[elem objectForKey:@"count"] intValue];
            if([type isEqualToString:@"event"])
            {
                eventsTotalCache=count;
            }
            else if([type isEqualToString:@"expert"])
            {
                expertsTotalCache=count;
            }
            else if([type isEqualToString:@"method"])
            {
                methodsTotalCache=count;
            }
            else if([type isEqualToString:@"news"])
            {
                newsTotalCache=count;
            }
            else if([type isEqualToString:@"qa"])
            {
                qaTotalCache=count;
            }
            else if([type isEqualToString:@"study"])
            {
                studyTotalCache=count;
            }
        }

        studyCoundCache =[[countCopy objectForKey:@"study"] intValue];

        methodsCoundCache =[[countCopy objectForKey:@"method"] intValue];

        qaCoundCache = [[countCopy objectForKey:@"qa"] intValue];

        expertsCoundCache = [[countCopy objectForKey:@"expert"] intValue];

        eventsTotalCache = [Article numberOfObjectsMatchingPredicate:[NSPredicate predicateWithFormat:@"type==%@ AND start_date > %@",@"event",[NSDate date]]
                                                           inContext:self.appDelegate.managedObjectContext];

        eventsCoundCache =[[countCopy objectForKey:@"event"] intValue];

        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval: -(60*60*24*30)];
        newsTotalCache = [Article numberOfObjectsMatchingPredicate:[NSPredicate predicateWithFormat:@"type==%@ AND date > %@",@"news",newDate]
                                                      inContext:self.appDelegate.managedObjectContext];

        newsCoundCache =[[countCopy objectForKey:@"news"] intValue];


    }
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        UIView *headerView=[[[NSBundle mainBundle] loadNibNamed:@"ArticleListHeader" owner:self options:nil] objectAtIndex:0];
        self.navigationItem.titleView=headerView;
    }
    else
    {
        if([self.appDelegate.currentType isEqualToString:@"study"])
            self.navigationItem.title=RCLocalizedString(@"Projekte", @"module.studies.title");
        else if([self.appDelegate.currentType isEqualToString:@"method"])
            self.navigationItem.title=RCLocalizedString(@"Methoden", @"module.methods.title");
        else if([self.appDelegate.currentType isEqualToString:@"qa"])
            self.navigationItem.title=RCLocalizedString(@"Praxiswissen", @"module.qa.title");
        else if([self.appDelegate.currentType isEqualToString:@"expert"])
            self.navigationItem.title=RCLocalizedString(@"Experten", @"module.experts.title");
        else if([self.appDelegate.currentType isEqualToString:@"event"])
            self.navigationItem.title=RCLocalizedString(@"Veranstaltungen", @"module.events.title");
        else if([self.appDelegate.currentType isEqualToString:@"news"])
            self.navigationItem.title=RCLocalizedString(@"News", @"module.news.title");

    }
    UILabel *label=(UILabel *)[self.navigationItem.titleView viewWithTag:1];
    if([self.appDelegate.currentType isEqualToString:@"study"])
    {
        label.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Projekte", @"module.studies.title"),studyCoundCache,studyTotalCache];
    }
    else if([self.appDelegate.currentType isEqualToString:@"method"])
    {
        label.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Methoden", @"module.methods.title"),methodsCoundCache,methodsTotalCache];
    }
    else if([self.appDelegate.currentType isEqualToString:@"qa"])
    {
        label.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Praxiswissen", @"module.qa.title"),qaCoundCache,qaTotalCache];
    }
    else if([self.appDelegate.currentType isEqualToString:@"expert"])
    {
        label.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Experten", @"module.experts.title"),expertsCoundCache,expertsTotalCache];
    }
    else if([self.appDelegate.currentType isEqualToString:@"event"])
    {
        label.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Veranstaltungen", @"module.events.title"),eventsCoundCache,eventsTotalCache];
    }
    else if([self.appDelegate.currentType isEqualToString:@"news"])
    {
        label.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"News", @"module.news.title"),newsCoundCache,newsTotalCache];
    }
    [(RCArticleSideVC*)[((UINavigationController*)self.slideViewController.sideViewController).viewControllers objectAtIndex:0] setType:self.appDelegate.currentType];
    CGSize size=[label.text sizeWithFont:label.font];
    self.navigationItem.titleView.bounds=CGRectMake(0, 0, size.width+26, 30);

    int count=0;
    if(self.appDelegate.sections==nil)
        count= self.appDelegate.resultList.count;
    else
    {
        for(NSMutableDictionary *dict in self.appDelegate.sections)
        {
            count+=[[dict objectForKey:@"content"] count];
        }
    }

    if(count==0)
    {
        [self.tableView addSubview:self.EmptyResultLabel];
        self.EmptyResultLabel.center=CGPointMake(CGRectGetMidX(self.tableView.bounds), CGRectGetMidY(self.tableView.bounds));
        [self.tableView bringSubviewToFront:self.EmptyResultLabel];
    }
    else
    {
        [self.EmptyResultLabel removeFromSuperview];
    }

    [self.tableView reloadData];
}

#pragma mark -
#pragma mark IB Actions

- (IBAction)onSwitch:(id)sender
{
    if(self.sheetController!=nil)
    {
        [self.sheetController.sheet dismissWithClickedButtonIndex:0 animated:YES];
        self.sheetController=nil;
        return;
    }
    self.sheetController=[[RCActionSheetController alloc] init];
    __weak RCArticleListVC *me=self;
    if([[RCModuleManagement instance] isModuleEnabled:@"study"])
    {
        [self.sheetController addItemWithTitle: [NSString stringWithFormat: @"%@ (%i/%i)", RCLocalizedString(@"Projekte", @"module.studies.title"), studyCoundCache, studyTotalCache] callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.currentType=@"study";
            [myself.appDelegate buildList];
            myself.sheetController=nil;
        }];

    }
    if([[RCModuleManagement instance] isModuleEnabled:@"method"])
    {
        [self.sheetController addItemWithTitle: [NSString stringWithFormat: @"%@ (%i/%i)", RCLocalizedString(@"Methoden", @"module.methods.title"), methodsCoundCache, methodsTotalCache] callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.currentType=@"method";
            [myself.appDelegate buildList];
            myself.sheetController=nil;
        }];

    }
    if([[RCModuleManagement instance] isModuleEnabled:@"qa"])
    {
        [self.sheetController addItemWithTitle: [NSString stringWithFormat: @"%@ (%i/%i)", RCLocalizedString(@"Praxiswissen", @"module.qa.title"), qaCoundCache, qaTotalCache] callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.currentType=@"qa";
            [myself.appDelegate buildList];
            myself.sheetController=nil;
        }];
    }
    if([[RCModuleManagement instance] isModuleEnabled:@"expert"])
    {
        [self.sheetController addItemWithTitle: [NSString stringWithFormat: @"%@ (%i/%i)", RCLocalizedString(@"Experten", @"module.experts.title"), expertsCoundCache, expertsTotalCache] callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.currentType=@"expert";
            [myself.appDelegate buildList];
            myself.sheetController=nil;
        }];
    }
    if([[RCModuleManagement instance] isModuleEnabled:@"event"])
    {
        [self.sheetController addItemWithTitle: [NSString stringWithFormat: @"%@ (%i/%i)", RCLocalizedString(@"Veranstaltungen", @"module.events.title"), eventsCoundCache, eventsTotalCache] callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.currentType=@"event";
            [myself.appDelegate buildList];
            myself.sheetController=nil;
        }];
    }
    if([[RCModuleManagement instance] isModuleEnabled:@"news"])
    {
        [self.sheetController addItemWithTitle: [NSString stringWithFormat: @"%@ (%i/%i)", RCLocalizedString(@"News", @"module.news.title"), newsCoundCache, newsTotalCache] callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.currentType=@"news";
            [myself.appDelegate buildList];
            myself.sheetController=nil;
        }];
    }
    self.sheetController.onCancel=^{
        RCArticleListVC *myself=me;
        myself.sheetController=nil;
    };
    self.sheetController.sheet=[[UIActionSheet alloc] initWithTitle:RCLocalizedString(@"Kategorie wählen", @"label.select_category")
                                                           delegate:self.sheetController
                                                  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self.sheetController prepareSheet];
    [self.sheetController.sheet showFromRect:((UIView*)sender).bounds inView:sender animated:YES];
}

- (void)onSlideBtn:(id)sender
{
    if(self.slideViewController.isSideViewControllerVisible)
    {
        [self.slideViewController slideOut];
    }
    else
    {
        [self.slideViewController slideIn];
    }
}

- (void)onSort:(id)sender
{
    if(self.sheetController!=nil)
    {
        [self.sheetController.sheet dismissWithClickedButtonIndex:0 animated:YES];
        self.sheetController=nil;
        return;
    }
    NSDictionary *sortOptions=[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSArray arrayWithObjects:@"title",@"created",@"study_start", nil],@"study",
                               [NSArray arrayWithObjects:@"title",@"created", nil],@"method",
                               [NSArray arrayWithObjects:@"title",@"created",@"year", nil],@"qa",
                               [NSArray arrayWithObjects:@"lastname",@"institution",@"created",nil],@"expert",
                               [NSArray arrayWithObjects:@"date",@"author",nil],@"news",
                               [NSArray arrayWithObjects:@"start_date", nil],@"event",
                               nil];
    NSArray *currentOptions=[sortOptions objectForKey:self.appDelegate.currentType];
    self.sheetController=[[RCActionSheetController alloc] init];
    self.sheetController.sheet=[[UIActionSheet alloc] initWithTitle:RCLocalizedString(@"Sortierung", @"label.sort") delegate:self.sheetController cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    __weak RCArticleListVC *me=self;
    for(NSString *entry in currentOptions)
    {
        NSString *data=[entry copy];
        [self.sheetController addItemWithTitle:RCLocalizedString(nil,NSLocalizedStringFromTable(data, @"sorting", @"RCArticleListVC")) callback:^{
            RCArticleListVC *myself=me;
            myself.appDelegate.sortField=data;
            [myself.appDelegate buildList];
            [myself.tableView reloadData];
            myself.sheetController=nil;
        }];
    }
    self.sheetController.onCancel=^{
        RCArticleListVC *myself=me;
        myself.sheetController=nil;
    };


    [self.sheetController prepareSheet];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.sheetController.sheet showFromBarButtonItem:sender animated:YES];
    }
    else
    {
        [self.sheetController.sheet showFromTabBar:self.tabBarController.tabBar];
    }
}

#pragma mark -
#pragma mark Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.EmptyResultLabel.center=CGPointMake(CGRectGetMidX(self.tableView.bounds), CGRectGetMidY(self.tableView.bounds));
    [self.view bringSubviewToFront:self.EmptyResultLabel];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView bringSubviewToFront:self.EmptyResultLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.slideViewController setShowSideViewControllerOnTop:YES];
    hideFilter=NO;
    self.splitViewController.delegate=nil;
    self.splitViewController.delegate=self;
    [super viewWillAppear:animated];
    [self.tableView bringSubviewToFront:self.EmptyResultLabel];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.appDelegate buildList];
        [self adjustTopButtonSizes: self.interfaceOrientation];
    }

    [self onUpdate:nil];
    if(self.tableView.contentOffset.y<44 && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        self.tableView.contentOffset=CGPointMake(0, 44);

    //self.navBtns.hidden = NO;
    self.navBtns.alpha = 1;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.slideViewController setShowSideViewControllerOnTop:NO];
    [super viewWillDisappear:animated];
    self.searchBar.text=self.appDelegate.searchTerm;
    self.splitViewController.delegate=nil;
    self.splitViewController.delegate=self;


    self.splitViewController.delegate=nil;
    self.splitViewController.delegate=self;

    [self.splitViewController.view setNeedsLayout];

    [self.splitViewController willRotateToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:self.slideViewController.interfaceOrientation];

    [self.splitViewController willRotateToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft)];


    //self.navBtns.hidden = YES;
    self.navBtns.alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.splitViewController.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.EmptyResultLabel];
    [self.splitViewController.view setNeedsLayout];
    [self.splitViewController willRotateToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:self.slideViewController.interfaceOrientation];

    [self.splitViewController willRotateToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft)];

    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        if(self.leftBar.items.count>1)
            self.leftBar.items=[self.leftBar.items subarrayWithRange:NSMakeRange(0, self.leftBar.items.count-1)];
        [[self.splitViewController.viewControllers objectAtIndex:0] viewDidAppear:animated];
    }
    else
    {
        NSArray *items=self.leftBar.items;
        if(items.count<=1 && self.filterBtn!=nil)
        {
            items=[items arrayByAddingObjectsFromArray:[NSArray arrayWithObject:self.filterBtn]];
            self.leftBar.items=items;
        }
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        if([self.navigationController.viewControllers lastObject]==self && !hideFilter)
            return NO;
        return YES;
    }
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setImage:[UIImage imageNamed:@"icon_filter.png"]];
    self.filterBtn=barButtonItem;
    NSArray *items=self.leftBar.items;
    if(items.count<=1)
    {
        items=[items arrayByAddingObjectsFromArray:[NSArray arrayWithObject:barButtonItem]];
        self.leftBar.items=items;
    }
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(self.leftBar.items.count>1)
        self.leftBar.items=[self.leftBar.items subarrayWithRange:NSMakeRange(0, self.leftBar.items.count-1)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [self.slideViewController setShowSideViewControllerOnTop:YES];
        }
        else
        {
            [self.slideViewController setShowSideViewControllerOnTop:NO];
        }
    }
    else
        [self adjustTopButtonSizes: toInterfaceOrientation];
}

-(void)adjustTopButtonSizes: (UIInterfaceOrientation)orientation
{
    CGRect aFrame = self.navBtns.frame;
    aFrame.size.height = UIInterfaceOrientationIsLandscape(orientation) ? 32 : 44;
    self.navBtns.frame = aFrame;

    aFrame = self.leftBar.frame;
    aFrame.size.height = UIInterfaceOrientationIsLandscape(orientation) ? 32 : 44;
    self.leftBar.frame = aFrame;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCArticleDetailVC class]])
    {
        if(self.slideViewController && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
            [self.slideViewController slideOut];

        hideFilter=YES;
        self.splitViewController.delegate=nil;
        self.splitViewController.delegate=self;

        [self.splitViewController.view setNeedsLayout];

        [self.splitViewController willRotateToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
        [self.splitViewController willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
        [self.splitViewController didRotateFromInterfaceOrientation:self.slideViewController.interfaceOrientation];

        [self.splitViewController willRotateToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
        [self.splitViewController willAnimateRotationToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
        [self.splitViewController didRotateFromInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft)];

        RCArticleDetailVC *ctrl=segue.destinationViewController;
        NSIndexPath *path=[self.tableView indexPathForCell:sender];
        if(self.appDelegate.sections==nil)
        {
            ctrl.articles=self.appDelegate.resultList;
            ctrl.article=[self.appDelegate.resultList objectAtIndex:path.row];
        }
        else
        {
            NSArray *content=[[self.appDelegate.sections objectAtIndex:path.section-1] objectForKey:@"content"];
            ctrl.articles=content;
            ctrl.article=[content objectAtIndex:path.row];
        }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.appDelegate.sections==nil)
        return 2;//1+(filterSet ? 1 : 0);
    else
        return self.appDelegate.sections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL filterSet=NO;
    for(id elem in self.appDelegate.criteria)
    {
        if([[elem objectForKey:@"selection"] count]>0)
            filterSet=YES;
    }
    if(section==0)
    {
        if(filterSet)
            return 1;
        else
            return 0;
    }
    else
    {
        section--;
    }
    if(self.appDelegate.sections==nil)
        return self.appDelegate.resultList.count;
    NSMutableDictionary *dict=[self.appDelegate.sections objectAtIndex:section];
    if([[dict objectForKey:@"expanded"] boolValue])
        return [[dict objectForKey:@"content"] count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 0.0;
    if(self.appDelegate.sections==nil)
        return 0.0;
    return 44;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0)return nil;
    section--;
    if(self.appDelegate.sections==nil)return nil;
    RCArticleSectionHeaderView *header=[[[NSBundle mainBundle] loadNibNamed:@"ArticleListSection" owner:self options:nil] lastObject];
    header.secIndex=section+1;
    header.section=[self.appDelegate.sections objectAtIndex:section];
    header.tableView=tableView;
    [header fill];
    return header;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)return nil;
    if(self.appDelegate.sections==nil)
        return nil;
    return [[self.appDelegate.sections objectAtIndex:section] objectForKey:@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"FilterReset"];
        return cell;
    }
    else
    {
        indexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    }
    RCArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.appDelegate.currentType];
    if(self.appDelegate.sections==nil)
        cell.article=[self.appDelegate.resultList objectAtIndex:indexPath.row];
    else
        cell.article=[[[self.appDelegate.sections objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    // Configure the cell...
    [cell fill];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return 44;
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        [self.appDelegate buildCriteria];
        [self.appDelegate buildList];
        int count=0;
        if(self.appDelegate.sections==nil)
            count= self.appDelegate.resultList.count;
        else
        {
            for(NSMutableDictionary *dict in self.appDelegate.sections)
            {
                count+=[[dict objectForKey:@"content"] count];
            }
        }

        if(count==0)
        {
            [self.tableView addSubview:self.EmptyResultLabel];
            self.EmptyResultLabel.center=CGPointMake(CGRectGetMidX(self.tableView.bounds), CGRectGetMidY(self.tableView.bounds));
            [self.tableView bringSubviewToFront:self.EmptyResultLabel];
        }
        else
        {
            [self.EmptyResultLabel removeFromSuperview];
        }
        [self.tableView reloadData];

    }
}


@end
