//
//  RCSharingSupport.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCSharingSupport.h"
#import "RCSharingController.h"
#import "RCArticleListVC.h"
#import "RCArticleDetailVC.h"
#import "RCFavoritesVC.h"
#import "RCFavoriteFilterVC.h"

RCSharingSupport *reference;

@implementation RCSharingSupport

- (void)awakeFromNib
{
    reference=self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleSave:) name:RCArticleSavedNotification object:nil];
    for(UIViewController *controller in self.controller.viewControllers)
    {
        UITabBarItem *item=controller.tabBarItem;
        NSMutableDictionary *dictionary=[NSMutableDictionary dictionary];//[[item titleTextAttributesForState:UIControlStateNormal] mutableCopy];
        [dictionary setObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        [item setTitleTextAttributes:dictionary forState:UIControlStateNormal];
        [item setTitleTextAttributes:dictionary forState:UIControlStateSelected];
        
    }
    
    UIViewController *viewController;
    
    viewController=self.controller.viewControllers[0];
    viewController.tabBarItem.title=RCLocalizedString(@"Dashboard", @"label.dashboard");
    
    viewController=self.controller.viewControllers[1];
    viewController.tabBarItem.title=RCLocalizedString(@"Planen", @"label.planning");
    
    viewController=self.controller.viewControllers[2];
    viewController.tabBarItem.title=RCLocalizedString(@"Kategorien", @"label.categories");
    
    viewController=self.controller.viewControllers[3];
    viewController.tabBarItem.title=RCLocalizedString(@"Favoriten", @"global.sortfav");
    
    viewController=self.controller.viewControllers[4];
    viewController.tabBarItem.title=RCLocalizedString(@"Teilen", @"share.title");

}

- (void)onArticleSave:(NSNotification*)notification
{
    self.controller.selectedIndex=3;
    UIViewController *viewController=[self.controller.viewControllers objectAtIndex:3];
    RCSlideInVC *slideInVC=(RCSlideInVC*)viewController;
    viewController=slideInVC.mainViewController;
    UIViewController *sideViewController;
    if([viewController isKindOfClass:[UISplitViewController class]])
    {
        UISplitViewController *split=(UISplitViewController*)viewController;
        viewController=[split.viewControllers objectAtIndex:1];
        sideViewController=[split.viewControllers objectAtIndex:0];
    }
    UINavigationController *nav=(UINavigationController*)viewController;
    RCFavoritesVC *favorites=[nav.viewControllers objectAtIndex:0];
    favorites.showEditing=YES;
    favorites.showNotAssigned=NO;
    favorites.showOwnArticles=NO;
    favorites.typeFilter=nil;
    [favorites updateMe];
    nav=(UINavigationController *)sideViewController;
    RCFavoriteFilterVC *filter=[nav.viewControllers objectAtIndex:0];
    [filter buildSections];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    int idx=[tabBarController.viewControllers indexOfObject:viewController];
    if(idx==4)
    {
        // Fire up sharing. actually there can't be that many sharing cases, as the tabbar is not visible while inside an detail view
        // So... it's basically dashboard, planning and article list. we're not able to encode the currently set filters, so we skip that out.
        
        // NOTE: Tabbar actually IS visible while inside a detail view (iPad)
        int idx=tabBarController.selectedIndex;
        NSURL *reference;
    
        if(idx==0)
        {
            reference=[NSURL URLWithString: baseurl];
        }
        else if(idx==1 || idx==2)
        {  
            NSMutableString *url=[NSMutableString string];
            [url appendFormat:@"%@article/index/%@?sort=%@",baseurl,self.appDelegate.currentType,self.appDelegate.sortField];
            int index=0;
            for(id elem in self.appDelegate.criteria)
            {
                Criterion *criterion=[elem objectForKey:@"criterion"];
                if([[elem objectForKey:@"selection"] count]==0)
                {
                    CriteriaOption *option=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"default_value==YES"]] anyObject];
                    if(option!=nil)
                    {
                        [url appendFormat:@"&criteria[%d]=%@",index,option.id_from_import];
                        index++;
                    }
                }
                else
                {
                    if([criterion.type isEqualToString:@"resource"])
                    {
                        CriteriaOption *option=[[[elem objectForKey:@"selection"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]] lastObject];
                        [url appendFormat:@"&criteria[%d]=%@",index,option.id_from_import];
                        index++;
                    }
                    else
                    {
                        for(CriteriaOption *option in [elem objectForKey:@"selection"])
                        {
                            [url appendFormat:@"&criteria[%d]=%@",index,option.id_from_import];
                            index++;
                        }
                    }
                }
            }
            if(idx==1)
                [url appendFormat:@"#planning"];
            else if(idx==2)
            {
                UIViewController *container=[tabBarController.viewControllers objectAtIndex:idx];
                RCSlideInVC *ctrl=(RCSlideInVC*)container;
                UIViewController *main=ctrl.mainViewController;
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    UISplitViewController *casted=(UISplitViewController*)main;
                    main=[casted.viewControllers objectAtIndex:1];
                }
                UINavigationController *navCtrl=(UINavigationController *)main;
                main=[navCtrl.viewControllers lastObject];
                
                if([main isKindOfClass:[RCArticleDetailVC class]])
                {
                    url=[NSString stringWithFormat: @"%@/article/show/%@",baseurl,((RCArticleDetailVC*)main).article.id_from_import];
                }
            }
            reference=[NSURL URLWithString:url];
        }
        else if(idx==3)
        {
            reference=nil;//[NSURL URLWithString: [NSString stringWithFormat: @"%@/favorites/index", baseurl]];
            UIViewController *container=[tabBarController.viewControllers objectAtIndex:idx];
            RCSlideInVC *slidein=(RCSlideInVC*)container;
            container=slidein.mainViewController;
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                UISplitViewController *casted=(UISplitViewController*)container;
                container=[casted.viewControllers objectAtIndex:1];
            }
            UINavigationController *navCtrl=(UINavigationController *)container;
            container=[navCtrl.viewControllers lastObject];
            if([container isKindOfClass:[RCFavoritesVC class]])
            {
                RCFavoritesVC *casted=(RCFavoritesVC *)container;
                if(casted.favFilter!=nil)
                    reference=[NSString stringWithFormat:@"%@%@", baseurl, casted.favFilter.sharingurl];
                
            }
            else if([container isKindOfClass:[RCArticleDetailVC class]])
            {
                reference=[NSString stringWithFormat:@"%@article/show/%@", baseurl,((RCArticleDetailVC*)container).article.id_from_import];
            }
        }
        if(reference!=nil)
            [[RCSharingController instance] shareURL:reference from:nil];
        return NO;
    }
    return YES;
}
@end
