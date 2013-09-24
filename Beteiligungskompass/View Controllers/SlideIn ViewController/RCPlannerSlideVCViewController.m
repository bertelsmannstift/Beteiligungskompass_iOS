//
//  RCPlannerSlideVCViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerSlideVCViewController.h"
#import "RCPlannerVC.h"
#import <QuartzCore/QuartzCore.h>

@interface RCPlannerSlideVC ()

@end

@implementation RCPlannerSlideVC


- (void)slideIn
{
    _isSideViewControllerVisible=YES;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self.mainViewController viewWillDisappear:YES];
    [self.sideViewController viewWillAppear:YES];
    self.contentView.layer.anchorPoint=CGPointMake(1, 0.5);
    self.contentView.bounds=CGRectMake(0, 0, self.view.frame.size.width-260, self.view.frame.size.height);
    self.contentView.center=CGPointMake(self.view.frame.size.width, self.view.frame.size.height/2.0);
    self.contentView.transform=CGAffineTransformMakeScale(self.view.frame.size.width/(self.view.frame.size.width-260), 1);
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            self.contentView.layer.transform=CATransform3DIdentity;
//            self.contentView.center=CGPointMake(self.contentView.frame.size.width/2.0+260, self.contentView.center.y);
//            self.contentView.bounds=CGRectMake(0, 0, self.view.frame.size.width-260, self.view.frame.size.height);
        }
        else
        {
            self.contentView.center=CGPointMake(self.view.bounds.size.width+self.mainViewController.view.frame.size.width/2-60, self.mainViewController.view.center.y);
        }
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [self.mainViewController viewDidDisappear:YES];
        [self.sideViewController viewDidAppear:YES];
    } completion:nil];
}

- (void)slideOut
{
    _isSideViewControllerVisible=NO;
    [self.sideViewController viewWillDisappear:YES];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self.mainViewController viewWillAppear:YES];
    self.contentView.center=CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height/2.0);
    self.contentView.bounds=self.view.bounds;
    self.contentView.transform=CGAffineTransformMakeScale((self.view.frame.size.width-260)/self.view.frame.size.width, 1);
    [UIView animateWithDuration:0.7 animations:^{
        self.contentView.transform=CGAffineTransformIdentity;
        [self.sideViewController viewDidDisappear:YES];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [self.mainViewController viewDidAppear:YES];
    }];
}

- (void)viewDidLayoutSubviews
{
    return;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.sideView.frame=CGRectMake(0, 0, 260, self.view.frame.size.height);
        if(self.isSideViewControllerVisible)
        {
            self.contentView.layer.anchorPoint=CGPointMake(1, 0.5);
            self.contentView.bounds=CGRectMake(0, 0, self.view.frame.size.width-260, self.view.frame.size.height);
            self.contentView.center=CGPointMake(self.view.frame.size.width, self.view.frame.size.height/2.0);
        }
    }
    else
    {
        if(self.isSideViewControllerVisible)
        {
            self.contentView.center=CGPointMake(self.view.bounds.size.width+self.mainViewController.view.frame.size.width/2-60, self.mainViewController.view.center.y);
        }
    }
}


@end
