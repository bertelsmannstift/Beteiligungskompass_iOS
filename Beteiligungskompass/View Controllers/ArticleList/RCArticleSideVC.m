//
//  RCArticleSideVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleSideVC.h"
#import "RCArticleDetailVC.h"
#import "RCHighlightedBlockableCell.h"
#import "NSString+KeychainAdditions.h"
#import "RCAddNodeContainerViewController.h"
#import "RCModuleManagement.h"
#import "RCBaseSettings.h"

@interface RCArticleSideVC ()

@end

@implementation RCArticleSideVC
@synthesize studyLabel=_studyLabel;
@synthesize methodsLabel=_methodsLabel;
@synthesize qaLabel=_qaLabel;
@synthesize expertsLabel=_expertsLabel;
@synthesize eventsLabel=_eventsLabel;
@synthesize newsLabel=_newsLabel;
@synthesize type=_type;
@synthesize articles=_articles;
@synthesize currentArticle=_currentArticle;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=RCLocalizedString(@"Bereich wählen...", @"label.select_section");
    self.tableView.scrollsToTop=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ArticleCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdate:) name:RCListUpdatedNotification object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCListUpdatedNotification object:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)clearHighlighting
{
    for(int i=0;i<6;i++)
    {
        RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        if([cell isKindOfClass:[RCHighlightedBlockableCell class]])
        {
            cell.ignoreHighlightedCalls=NO;
            [cell setHighlighted:NO];
        }
    }

}

/*
 This method updates the table view content. As this table view contains a huge set of different data from different sources, it's update is quite complex.
 */
- (void)onUpdate:(NSNotification *)sender
{
    [self setArticles: nil forType: self.appDelegate.currentType];
    
    if(self.appDelegate.comm.isAuthenticated)
    {
        self.logOnCell.textLabel.text=RCLocalizedString(@"Abmelden", @"label.logout");
        self.logOnCell.imageView.image=[UIImage imageNamed:@"icon_subnavi_logout.png"];
    }
    else
    {
        self.logOnCell.textLabel.text=RCLocalizedString(@"Anmelden", @"label.login");
        self.logOnCell.imageView.image=[UIImage imageNamed:@"icon_subnavi_login.png"];
    }
    [self.logOnCell setNeedsLayout];
    
    if(self.appDelegate.fetchCounts.count==0)return;
    NSDictionary *countCopy=[self.appDelegate.fetchCounts copy];
    self.context=self.appDelegate.backgroundContext;
    [self.context performBlock:^{
        
        int eventstotal,expertstotal,methodstotal,newstotal,qatotal,studytotal;
        
        NSExpressionDescription *eD=[[NSExpressionDescription alloc] init];
        eD.name=@"count";
        eD.expression=[NSExpression expressionForFunction:@"count:" arguments:@[[NSExpression expressionForKeyPath:@"type"]]];
        NSFetchRequest *request=[[NSFetchRequest alloc] init];
        [request setEntity:[Article entityInContext:self.context]];
        [request setPropertiesToFetch:@[@"type",eD]];
        [request setPropertiesToGroupBy:@[@"type"]];
        [request setResultType:NSDictionaryResultType];
        NSArray *results=[self.context executeFetchRequest:request error:nil];
        for(id elem in results)
        {
            NSString *type=[elem objectForKey:@"type"];
            int count=[[elem objectForKey:@"count"] intValue];
            if([type isEqualToString:@"event"])
            {
                eventstotal=count;
            }
            else if([type isEqualToString:@"expert"])
            {
                expertstotal=count;
            }
            else if([type isEqualToString:@"method"])
            {
                methodstotal=count;
            }
            else if([type isEqualToString:@"news"])
            {
                newstotal=count;
            }
            else if([type isEqualToString:@"qa"])
            {
                qatotal=count;
            }
            else if([type isEqualToString:@"study"])
            {
                studytotal=count;
            }
        }
        
        int studycount =[[countCopy objectForKey:@"study"] intValue];
        
        int methodscount =[[countCopy objectForKey:@"method"] intValue];
        
        int qacount = [[countCopy objectForKey:@"qa"] intValue];
        
        int expertscount = [[countCopy objectForKey:@"expert"] intValue];
        
        eventstotal = [Article numberOfObjectsMatchingPredicate:[NSPredicate predicateWithFormat:@"type==%@ AND start_date > %@",@"event",[NSDate date]]
                                                           inContext:self.context];
        
        int eventscount =[[countCopy objectForKey:@"event"] intValue];
        
        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval: -(60*60*24*30)];
        newstotal = [Article numberOfObjectsMatchingPredicate:[NSPredicate predicateWithFormat:@"type==%@ AND date > %@",@"news",newDate]
                                                         inContext:self.context];
        
        int newscount =[[countCopy objectForKey:@"news"] intValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                self.studyLabel.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Projekte", @"module.studies.title"),studycount,studytotal];
                self.methodsLabel.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Methoden", @"module.methods.title"),methodscount,methodstotal];
                self.qaLabel.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Praxiswissen", @"module.qa.title"),qacount,qatotal];
                self.expertsLabel.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Experten", @"module.experts.title"),expertscount,expertstotal];
                self.eventsLabel.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"Veranstaltungen", @"module.events.title"),eventscount,eventstotal];
                self.newsLabel.text=[NSString stringWithFormat:@"%@ (%d/%d)",RCLocalizedString(@"News", @"module.news.title"),newscount,newstotal];
            }
        });
    }];
    
    [self.tableView reloadData];
    [self clearHighlighting];
    if(self.type!=nil)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 6)] withRowAnimation:UITableViewRowAnimationNone];
        if([self.type isEqualToString:@"study"])
        {
            self.addLabel.text=RCLocalizedString(@"Projekt hinzufügen", @"label.add_project");
            RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell setHighlighted:YES];
            cell.ignoreHighlightedCalls=YES;
            [cell performSelector: @selector(setHighlighted:) withObject: nil afterDelay: 0.15];
        }
        else if([self.type isEqualToString:@"method"])
        {
            self.addLabel.text=RCLocalizedString(@"Methode hinzufügen", @"label.add_method");
            RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [cell setHighlighted:YES];
            cell.ignoreHighlightedCalls=YES;
            [cell performSelector: @selector(setHighlighted:) withObject: nil afterDelay: 0.15];
        }
        else if([self.type isEqualToString:@"qa"])
        {
            self.addLabel.text=RCLocalizedString(@"Praxiswissen hinzufügen", @"label.add_qa");
            RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            [cell setHighlighted:YES];
            cell.ignoreHighlightedCalls=YES;
            [cell performSelector: @selector(setHighlighted:) withObject: nil afterDelay: 0.15];
        }
        else if([self.type isEqualToString:@"expert"])
        {
            self.addLabel.text=RCLocalizedString(@"Experte hinzufügen", @"label.add_expert");
            RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            [cell setHighlighted:YES];
            cell.ignoreHighlightedCalls=YES;
            [cell performSelector: @selector(setHighlighted:) withObject: nil afterDelay: 0.15];
        }
        else if([self.type isEqualToString:@"event"])
        {
            self.addLabel.text=RCLocalizedString(@"Veranstaltung hinzufügen", @"label.add_event");
            RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
            [cell setHighlighted:YES];
            cell.ignoreHighlightedCalls=YES;
            [cell performSelector: @selector(setHighlighted:) withObject: nil afterDelay: 0.15];
        }
        else if([self.type isEqualToString:@"news"])
        {
            self.addLabel.text=RCLocalizedString(@"News hinzufügen", @"label.add_news");
            RCHighlightedBlockableCell *cell=(RCHighlightedBlockableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
            [cell setHighlighted:YES];
            cell.ignoreHighlightedCalls=YES;
            [cell performSelector: @selector(setHighlighted:) withObject: nil afterDelay: 0.15];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *articles=self.articles;
    NSString *type=self.appDelegate.currentType;
    [self onUpdate:nil];
    [self setArticles:articles forType:type];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if(indexPath.section<=5 && indexPath.row==0)
    {
        switch (indexPath.section) {
            case 0:
                self.appDelegate.currentType=@"study";
                self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"study"];//@"created";
                break;
            case 1:
                self.appDelegate.currentType=@"method";
                self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"method"];//@"title";
                break;
            case 2:
                self.appDelegate.currentType=@"qa";
                self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"qa"];//@"title";
                break;
            case 3:
                self.appDelegate.currentType=@"expert";
                self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"expert"];//@"lastname";
                break;
            case 4:
                self.appDelegate.currentType=@"event";
                self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"event"];//@"start_date";
                break;
            case 5:
                self.appDelegate.currentType=@"news";
                self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"news"];//@"date";
                break;
            default:
                break;
        }
        
        [self setArticles: nil forType: self.appDelegate.currentType];
        [self.appDelegate buildList];
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
        [self clearHighlighting];
        [self.tabBarController.view layoutIfNeeded];
        
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
            [self.slideViewController slideOut];
    }
    else if(indexPath.section<=5 && indexPath.row>0)
    {
        UINavigationController *navCtrl;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            UISplitViewController *viewController=(UISplitViewController*)self.slideViewController.mainViewController;
            navCtrl=(UINavigationController *)[viewController.viewControllers objectAtIndex:1];
        }
        else
        {
            navCtrl=(UINavigationController*)self.slideViewController.mainViewController;
        }
        UINavigationController *container=navCtrl;
        RCArticleDetailVC *ctrl=[container.viewControllers lastObject];
        ctrl.article=[self.articles objectAtIndex:indexPath.row-1];
        [ctrl updateContent];
        [tableView reloadSections: [NSIndexSet indexSetWithIndex: indexPath.section] withRowAnimation: UITableViewRowAnimationNone];
        
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
            [self.slideViewController slideOut];
    }
    else if(indexPath.section==7 && self.type!=nil && indexPath.row==0)
    {
        if(self.appDelegate.comm.isAuthenticated)
        {
            UIViewController *ctrl=[RCAddNodeContainerViewController instantiateViewControllerForArticleType:self.type];
            [self presentViewController:ctrl animated:YES completion:nil];
            
            if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
                [self.slideViewController slideOut];
            
        }
        else
        {
            UIViewController *ctrl=[self.storyboard instantiateViewControllerWithIdentifier:@"login"];
            UINavigationController *nctrl=(UINavigationController*)self.slideViewController.mainViewController;
            [nctrl presentViewController:ctrl animated:YES completion:nil];
        }
    }
    else if(indexPath.section==7 && ((self.type!=nil && indexPath.row==1) || (self.type==nil && indexPath.row==0)))
    {
        if(self.appDelegate.comm.isAuthenticated)
        {
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            NSString *user=[defaults stringForKey:@"auth.user"];
            [NSString deletePasswordForAccount:user andServer: baseurl_without_http];
            [defaults removeObjectForKey:@"auth.user"];
            self.appDelegate.comm.token=nil;
            [defaults synchronize];
            for(Favorite_Group *group in [Favorite_Group fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext])
            {
                [self.appDelegate.managedObjectContext deleteObject:group];
            }
            for(Favorite_Entry *entry in [Favorite_Entry fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext])
            {
                [self.appDelegate.managedObjectContext deleteObject:entry];
            }
            
            if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
                [self.slideViewController slideOut];
        }
        else
        {
            UIViewController *ctrl=[self.storyboard instantiateViewControllerWithIdentifier:@"login"];
            UINavigationController *nctrl=(UINavigationController*)self.slideViewController.mainViewController;
            [nctrl presentViewController:ctrl animated:YES completion:nil];
            
            if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
                [self.slideViewController slideOut];
        }
    }
    else if(indexPath.section==7 && ((self.type!=nil && indexPath.row==2) || (self.type==nil && indexPath.row==1)))
    {
        UIViewController *ctrl=[self.storyboard instantiateViewControllerWithIdentifier:@"infocontact"];
        UINavigationController *nctrl=(UINavigationController*)self.slideViewController.mainViewController;
        if([nctrl isKindOfClass:[UISplitViewController class]])
        {
            nctrl=[((UISplitViewController*)nctrl).viewControllers objectAtIndex:1];
        }
        [(UINavigationController*)nctrl popToRootViewControllerAnimated:NO];
        [(UINavigationController*)nctrl setNavigationBarHidden:NO];
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
        [self setArticles:nil forType:nil];
        [self clearHighlighting];
        [self.tabBarController.view layoutIfNeeded];
        [nctrl pushViewController:ctrl animated:NO];
        
        [self.slideViewController slideOut];
    }
}

- (void)onResetFilter:(id)sender
{
    [self.appDelegate buildCriteria];
    [self.appDelegate buildList];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationNone];
    
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        [self.slideViewController slideOut];
}

- (void)setArticles:(NSArray *)articles forType:(NSString *)type
{
    self.type=type;
    self.articles=articles;
    self.studyLabel.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
    self.methodsLabel.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
    self.qaLabel.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
    self.expertsLabel.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
    self.eventsLabel.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
    self.newsLabel.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
    
    if([self.type isEqualToString:@"study"])
    {
        self.studyLabel.textColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    }
    else if([self.type isEqualToString:@"method"])
    {
        self.methodsLabel.textColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    }
    else if([self.type isEqualToString:@"qa"])
    {
        self.qaLabel.textColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    }
    else if([self.type isEqualToString:@"expert"])
    {
        self.expertsLabel.textColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    }
    else if([self.type isEqualToString:@"event"])
    {
        self.eventsLabel.textColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    }
    else if([self.type isEqualToString:@"news"])
    {
        self.newsLabel.textColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section<=5)
    {
        if(section==0 && ![[RCModuleManagement instance] isModuleEnabled:@"study"])
           return 0;
        if(section==1 && ![[RCModuleManagement instance] isModuleEnabled:@"method"])
            return 0;
        if(section==2 && ![[RCModuleManagement instance] isModuleEnabled:@"qa"])
            return 0;
        if(section==3 && ![[RCModuleManagement instance] isModuleEnabled:@"expert"])
            return 0;
        if(section==4 && ![[RCModuleManagement instance] isModuleEnabled:@"event"])
            return 0;
        if(section==5 && ![[RCModuleManagement instance] isModuleEnabled:@"news"])
            return 0;

        if(section==0 && [self.type isEqualToString:@"study"])
        {
            return 1+self.articles.count;
        }
        else if(section==1 && [self.type isEqualToString:@"method"])
        {
            return 1+self.articles.count;
        }
        else if(section==2 && [self.type isEqualToString:@"qa"])
        {
            return 1+self.articles.count;
        }
        else if(section==3 && [self.type isEqualToString:@"expert"])
        {
            return 1+self.articles.count;
        }
        else if(section==4 && [self.type isEqualToString:@"event"])
        {
            return 1+self.articles.count;
        }
        else if(section==5 && [self.type isEqualToString:@"news"])
        {
            return 1+self.articles.count;
        }
        else
            return [super tableView:tableView numberOfRowsInSection:section];
    }
    else if(section==6)
    {
        BOOL filterSet=NO;
        for(id elem in self.appDelegate.criteria)
        {
            if([[elem objectForKey:@"selection"] count]>0)
                filterSet=YES;
        }
        if(filterSet)
            return 1;
        return 0;
    }
    else if(section==7)
    {
        if(self.type==nil)
            return [super tableView:tableView numberOfRowsInSection:section]-1;
        else
            return [super tableView:tableView numberOfRowsInSection:section];
    }
    else
        return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<=5 && indexPath.row>0)
    {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ArticleCell"];
        UILabel *label=(UILabel *)[cell viewWithTag:1];
        Article *article=[self.articles objectAtIndex:indexPath.row-1];
        NSString *finalTitle=article.title;
        if([article.type isEqualToString:@"expert"])
        {
            NSMutableString *title=[NSMutableString string];
            BOOL separatorNeeded=NO;
            if(article.firstname!=nil && article.firstname.length>0)
            {
                [title appendString:article.firstname];
                [title appendString:@" "];
                [title appendString:article.lastname];
                separatorNeeded=YES;
            }
            if(article.institution!=nil && article.institution.length>0)
            {
                if(separatorNeeded)
                    [title appendString:@", "];
                [title appendString:article.institution];
            }
            finalTitle=title;
        }

        label.text=finalTitle;
        if(article==self.currentArticle)
        {
            label.textColor=[UIColor whiteColor];
            cell.contentView.backgroundColor=[UIColor colorWithRed:0.298 green:0.506 blue:0.659 alpha:1.000];
        }
        else
        {
            label.textColor=[UIColor colorWithWhite:0.200 alpha:1.000];
            cell.contentView.backgroundColor=[UIColor whiteColor];
        }
        return cell;
    }
    else if(indexPath.section==7)
    {
        if(self.type==nil)
            return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        else
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<=5 && indexPath.row>0)
        return 44;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<=5 && indexPath.row>0)
        return 0;
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}


@end
