//
//  RCPlannerSideVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerSideVC.h"

@interface RCPlannerSideVC ()

@end

@implementation RCPlannerSideVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.section<=5)
    {
        int idx=self.parentViewController.tabBarController.selectedIndex;
        self.parentViewController.tabBarController.selectedIndex=2;
        self.parentViewController.tabBarController.selectedIndex=idx;
        [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.parentViewController.tabBarController.selectedIndex=2;
        } completion:nil];
    }
}

@end
