//
//  RCFavoritesVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCFavoritesVC.h"
#import "RCLoginVC.h"
#import "NSString+KeychainAdditions.h"
#import "RCArticleCell.h"
#import "RCArticleCriteriaListSection.h"
#import "RCFavoriteFilterVC.h"
#import "RCArticleDetailVC.h"
#import "RCAddNodeContainerViewController.h"
#import "RCModuleManagement.h"

@interface RCFavoritesVC ()

@end

@implementation RCFavoritesVC

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
    self.title=RCLocalizedString(@"Favoriten", @"global.sortfav");
    ((RCFavoriteFilterVC*)[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0]).parent=self;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [self.splitViewController.view layoutIfNeeded];
    [self.slideViewController setShowSideViewControllerOnTop:NO];
    [super viewWillDisappear:animated];
    self.splitViewController.delegate=nil;
    self.splitViewController.delegate=self;
    
    [self.splitViewController willRotateToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:self.slideViewController.interfaceOrientation];
    
    [self.splitViewController willRotateToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft)];
}

- (void)updateMe
{
    NSArray *favoriteEntries=nil;
    if(self.favFilter!=nil)
    {
        favoriteEntries=[self.favFilter.entries allObjects];
    }
    else
    {
        favoriteEntries=[Favorite_Entry fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext];
    }
    self.articles=nil;
    self.sections=nil;
    NSMutableArray *scratchbook=[NSMutableArray array];
    if(self.showOwnArticles)
    {
        for(Article *article in [Article fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"originating_user.id_from_import=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"auth.userid"]] inContext:self.appDelegate.managedObjectContext])
        {
            if(self.typeFilter!=nil)
            {
                if([article.type isEqualToString:self.typeFilter])
                {
                    [scratchbook addObject:article];
                }
            }
            else
            {
                [scratchbook addObject:article];
            }
        }
    }
    else if(self.showEditing)
    {
        for(Article *article in [Article fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"is_custom==YES"] inContext:self.appDelegate.managedObjectContext])
        {
            if(self.typeFilter!=nil)
            {
                if([article.type isEqualToString:self.typeFilter])
                    [scratchbook addObject:article];
            }
            else
                [scratchbook addObject:article];
        }
    }
    else
    {
        for(Favorite_Entry *entry in favoriteEntries)
        {
            if(self.typeFilter!=nil)
            {
                if([entry.article.type isEqualToString:self.typeFilter])
                {
                    if((self.showNotAssigned && entry.groups.count==0) || !self.showNotAssigned)
                        [scratchbook addObject:entry.article];
                }
            }
            else
            {
                if(((self.showNotAssigned && entry.groups.count==0) || !self.showNotAssigned) && entry.article!=nil)
                    [scratchbook addObject:entry.article];
            }
        }
    }
    [scratchbook sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
    NSMutableDictionary *typeBased=[NSMutableDictionary dictionary];
    for(Article *article in scratchbook)
    {
        NSMutableArray *items=[typeBased objectForKey:article.type];
        if(items==nil)
        {
            items=[NSMutableArray array];
            [typeBased setObject:items forKey:article.type];
        }
        [items addObject:article];
    }
    
    if(self.typeFilter==nil)
    {
        //build sections
        NSMutableArray *sections=[NSMutableArray array];
        NSArray *items=[typeBased objectForKey:@"study"];
        if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"study"])
            [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Projekte", @"module.studies.title"),@"title",@"study",@"type", nil]];
        
        items=[typeBased objectForKey:@"method"];
        if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"method"])
            [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Methoden", @"module.methods.title"),@"title",@"method",@"type", nil]];
        
        items=[typeBased objectForKey:@"qa"];
        if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"qa"])
            [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Praxiswissen", @"module.qa.title"),@"title",@"qa",@"type", nil]];
        
        items=[typeBased objectForKey:@"expert"];
        if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"expert"])
            [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Experten", @"module.experts.title"),@"title",@"expert",@"type", nil]];
        
        items=[typeBased objectForKey:@"event"];
        if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"event"])
            [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Veranstaltungen", @"module.events.title"),@"title",@"event",@"type", nil]];
        
        items=[typeBased objectForKey:@"news"];
        if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"news"])
            [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"News", @"module.news.title"),@"title",@"news",@"type", nil]];
        
        self.sections=sections;
        self.expandedSections=[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.sections.count)];
    }
    else
    {
        self.articles=scratchbook;
    }
    [self.tableView reloadData];
}

- (void)onEditingClosed:(NSNotification*)notification
{
    [self updateMe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    hideFilder=NO;
    [self.slideViewController setShowSideViewControllerOnTop:YES];
    self.splitViewController.delegate=nil;
    self.splitViewController.delegate=self;
    [self updateMe];
    if(!self.appDelegate.comm.isAuthenticated)
    {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEditingClosed:) name:RCEditingClosedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.splitViewController.view setNeedsLayout];
    
    [self.splitViewController willRotateToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft) duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:self.slideViewController.interfaceOrientation];
    
    [self.splitViewController willRotateToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController willAnimateRotationToInterfaceOrientation:self.slideViewController.interfaceOrientation duration:0.0];
    [self.splitViewController didRotateFromInterfaceOrientation:(UIInterfaceOrientationIsLandscape(self.slideViewController.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCEditingClosedNotification object:nil];
    [super viewDidDisappear:animated];
    [self.splitViewController.view setNeedsLayout];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    if(hideFilder)
        return YES;
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"login"])
    {
        __weak RCLoginVC *ctrl=segue.destinationViewController;
        ctrl.onCancel=^{
            self.tabBarController.selectedIndex=0;
            [ctrl dismissViewControllerAnimated:YES completion:nil];
        };
        ctrl.onLogin=^(NSString *token){
            [ctrl dismissViewControllerAnimated:YES completion:nil];
            [self updateMe];
            RCFavoriteFilterVC *ctrl=[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
            [ctrl buildSections];
        };
    }
    if([segue.destinationViewController isKindOfClass:[RCFavoriteFilterVC class]])
    {
        RCFavoriteFilterVC *ctrl=segue.destinationViewController;
        ctrl.parent=self;
    }
    if([segue.destinationViewController isKindOfClass:[RCArticleDetailVC class]])
    {
        hideFilder=YES;
        [self.splitViewController.view setNeedsLayout];
        self.splitViewController.delegate=nil;
        self.splitViewController.delegate=self;
        RCArticleDetailVC *ctrl=segue.destinationViewController;
        NSIndexPath *path=[self.tableView indexPathForCell:sender];
        if(self.sections==nil)
        {
            ctrl.article=[self.articles objectAtIndex:path.row];
        }
        else
        {
            ctrl.article=[[[self.sections objectAtIndex:path.section] objectForKey:@"content"] objectAtIndex:path.row];
        }
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.sections!=nil)
        return self.sections.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.sections!=nil)
    {
        if(![self.expandedSections containsIndex:section])
            return 0;
        return [[[self.sections objectAtIndex:section] objectForKey:@"content"] count];
    }
    return self.articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article=nil;
    if(self.sections!=nil)
        article=[[[self.sections objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    else
        article=[self.articles objectAtIndex:indexPath.row];
    
    RCArticleCell *cell = nil;
    if(self.showEditing)
    {
        cell=[tableView dequeueReusableCellWithIdentifier:[article.type stringByAppendingString:@"-edit"]];
    }
    else
        cell=[tableView dequeueReusableCellWithIdentifier:article.type];
    cell.article=article;
    [cell fill];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.sections==nil)
        return 0.0;
    return 44;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.sections==nil)return nil;
    RCArticleCriteriaListSection *header=[[[NSBundle mainBundle] loadNibNamed:@"ArticleCriteriaListSection" owner:self options:nil] lastObject];
    header.secIndex=section;
    header.descriptionLabel.text=[[self.sections objectAtIndex:section] objectForKey:@"title"];
    header.tableView=tableView;
    header.expandedSections=self.expandedSections;
    [header fill];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.showEditing)
    {
        Article *article=nil;
        if(self.sections!=nil)
            article=[[[self.sections objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
        else
            article=[self.articles objectAtIndex:indexPath.row];
        UIViewController *controller=[RCAddNodeContainerViewController instantiateViewControllerForDataSet:article];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)onSlide:(id)sender
{
    if(self.slideViewController.isSideViewControllerVisible)
        [self.slideViewController slideOut];
    else
        [self.slideViewController slideIn];
}

@end
