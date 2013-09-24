//
//  RCDashBoardViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "RCDashBoardViewController.h"
#import "RCBaseSettings.h"
#import "RCModuleManagement.h"

@interface RCDashBoardViewController ()

@end

@implementation RCDashBoardViewController {
    BOOL launched;
}
@synthesize headerBlock=_headerBlock;
@synthesize auxiliaryBlock=_videoBlock;
@synthesize footerBlock=_footerBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)enabledSideBlocks:(BOOL *)videoEnabled_p listEnabled_p:(BOOL *)listEnabled_p
{
    *videoEnabled_p=NO;
    *listEnabled_p=NO;
    
    BOOL *showNewsBox = [[RCModuleManagement instance] isModuleEnabled:@"news"] && [[RCBaseSettings instance] isModuleEnabled:@"newsbox"];
    BOOL *showEventBox = [[RCModuleManagement instance] isModuleEnabled:@"event"] && [[RCBaseSettings instance] isModuleEnabled:@"eventbox"];
    
    if([[[RCBaseSettings instance] setting:@"module.videobox_newsbox_eventbox.mobile"] isEqualToString:@"news_event"] && (showNewsBox || showEventBox))
    {
        *videoEnabled_p=NO;
        *listEnabled_p=YES;
    }
    else if([[[RCBaseSettings instance] setting:@"module.videobox_newsbox_eventbox.mobile"] isEqualToString:@"video"])
    {
        *videoEnabled_p=YES;
        *listEnabled_p=NO;
    }
}

//this method sets up the video or the list block. however, due to the structure and available space, only one should be enabled.
- (void)setupAuxiliaryArea
{
    for(UIViewController *ctrl in self.childViewControllers)
    {
        if(ctrl.view.superview==self.auxiliaryBlock)
        {
            [ctrl.view removeFromSuperview];
            [ctrl removeFromParentViewController];
        }
    }

    BOOL videoEnabled;
    BOOL listEnabled;
    [self enabledSideBlocks:&videoEnabled listEnabled_p:&listEnabled];
    
    if(videoEnabled)
    {
        UIViewController *videoCtrl=[self.storyboard instantiateViewControllerWithIdentifier:@"videoblock"];
        [videoCtrl willMoveToParentViewController:self];
        [self.auxiliaryBlock addSubview:videoCtrl.view];
        if(listEnabled && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            CGRect frame=self.auxiliaryBlock.bounds;
            frame.size.height/=2.0;
            videoCtrl.view.frame=frame;
            videoCtrl.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        }
        else
        {
            videoCtrl.view.frame=self.auxiliaryBlock.bounds;
            videoCtrl.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        [self addChildViewController:videoCtrl];
        [videoCtrl didMoveToParentViewController:self];
        [videoCtrl willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            self.scrollView.contentSize=CGSizeMake(320, 501);
        }
    }
    else if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        self.scrollView.contentSize=CGSizeMake(320, self.scrollView.frame.size.height);
    }
    
    if(listEnabled && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        UIViewController *listCtrl=[self.storyboard instantiateViewControllerWithIdentifier:@"listblock"];
        [listCtrl willMoveToParentViewController:self];
        [self.auxiliaryBlock addSubview:listCtrl.view];
        if(videoEnabled)
        {
            CGRect frame=self.auxiliaryBlock.bounds;
            frame.size.height/=2.0;
            frame.origin.y+=frame.size.height;
            listCtrl.view.frame=frame;
            listCtrl.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        }
        else
        {
            listCtrl.view.frame=self.auxiliaryBlock.bounds;
            listCtrl.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        [self addChildViewController:listCtrl];
        [listCtrl didMoveToParentViewController:self];
    }
}

- (void)onModuleUpdate:(id)notification
{
    [self setupAuxiliaryArea];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=RCLocalizedString(@"Beteiligungskompass", @"label.dashboard_name");
    self.firstPartner.scrollView.scrollEnabled=NO;
    self.firstPartner.userInteractionEnabled=NO;
    self.secondPartner.scrollView.scrollEnabled=NO;
    self.secondPartner.userInteractionEnabled=NO;
    if(self.childViewControllers.count==0)
    {
        [self setupAuxiliaryArea];

        UIViewController *headerCtrl=[self.storyboard instantiateViewControllerWithIdentifier:@"headerblock"];
        [headerCtrl willMoveToParentViewController:self];
        [self.headerBlock addSubview:headerCtrl.view];
        headerCtrl.view.frame=self.headerBlock.bounds;
        [self addChildViewController:headerCtrl];
        [headerCtrl didMoveToParentViewController:self];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModuleUpdate:) name:@"ModuleStatesChanged" object:nil];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    self.headerBlock=nil;
    self.footerBlock=nil;
    self.auxiliaryBlock=nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
    [[self.childViewControllers objectAtIndex:0] willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
    NSArray *partnerLinks=[PartnerLink fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext];
    partnerLinks=[partnerLinks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id_from_import" ascending:YES]]];
    if(partnerLinks.count>0)
    {
        PartnerLink *link=[partnerLinks objectAtIndex:0];
        [self.firstPartner loadHTMLString:link.content baseURL:nil];
        self.firstPartner.hidden=NO;
    }
    else
        self.firstPartner.hidden=YES;
    
    if(partnerLinks.count>1)
    {
        PartnerLink *link=[partnerLinks objectAtIndex:1];
        [self.secondPartner loadHTMLString:link.content baseURL:nil];
        self.secondPartner.hidden=NO;
    }
    else
        self.secondPartner.hidden=YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
    if(!launched)
    {
        BOOL videoEnabled;
        BOOL listEnabled;
        [self enabledSideBlocks:&videoEnabled listEnabled_p:&listEnabled];
        if((!videoEnabled && !listEnabled) ||
           (!videoEnabled && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone))
        {
            self.scrollView.contentSize=self.scrollView.frame.size;
        }
        else if(videoEnabled || listEnabled)
        {
            self.scrollView.contentSize=CGSizeMake(320, 501);
        }
        launched=YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            BOOL video,list;
            [self enabledSideBlocks:&video listEnabled_p:&list];
            if(!video && !list)
            {
                [UIView animateWithDuration:duration animations:^{
                    self.headerBlock.frame=CGRectMake(10, 120, 1004, 400);
                    //self.videoBlock.frame=CGRectMake(10+500, 120, 494, 400);
                    self.auxiliaryBlock.hidden=YES;
                    self.footerBlock.frame=CGRectMake(10, 120+400, 1004, self.view.frame.size.height-400-120);
                    //self.footerBlock.frame=CGRectMake(20, 180, 440, 30);
                }];
                
            }
            else
            {
                [UIView animateWithDuration:duration animations:^{
                    self.headerBlock.frame=CGRectMake(10, 120, 500, 400);
                    self.auxiliaryBlock.hidden=NO;
                    self.auxiliaryBlock.frame=CGRectMake(10+500, 120, 494, 400);
                    self.footerBlock.frame=CGRectMake(10, 120+400, 1004, self.view.frame.size.height-400-120);
                    //self.footerBlock.frame=CGRectMake(20, 180, 440, 30);
                }];
            }
        }
        else
        {
            [UIView animateWithDuration:duration animations:^{
                self.headerBlock.frame=CGRectMake(10, 91, 748, 400);
                self.auxiliaryBlock.frame=CGRectMake(10, 91+400, 748, 310);
                self.footerBlock.frame=CGRectMake(10, 91+400+310, 748, self.view.frame.size.height-91-400-310);
                //self.footerBlock.frame=CGRectMake(20, 307, 280, 50);
            }];
        }
    }
    else
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [UIView animateWithDuration:duration animations:^{
                self.auxiliaryBlock.frame=CGRectMake(0, 362, [[UIScreen mainScreen] isLongScreen] ? 568 : 480, [[UIScreen mainScreen] isLongScreen] ? 426 : 360);
                self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.auxiliaryBlock.frame));
            }];
        }
        else
        {
            [UIView animateWithDuration:duration animations:^{
                self.auxiliaryBlock.frame=CGRectMake(0, 362, 320, 139);
                self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.auxiliaryBlock.frame));
            }];
        }
/*        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [UIView animateWithDuration:duration animations:^{
                self.headerBlock.frame=CGRectMake(10, 10, [[UIScreen mainScreen] isLongScreen] ? 313 : 225, 199);
                self.videoBlock.frame=CGRectMake(10+225+10+([[UIScreen mainScreen] isLongScreen] ? 88 : 0), 10, 225, 199);
                //self.footerBlock.frame=CGRectMake(20, 180, 440, 30);
            }];
        }
        else
        {
            [UIView animateWithDuration:duration animations:^{
                self.headerBlock.frame=CGRectMake(10, 10, 300, 200);
                self.videoBlock.frame=CGRectMake(10, 218, 300, 139);
                //self.footerBlock.frame=CGRectMake(20, 307, 280, 50);
            }];
        }*/
    }
}

- (IBAction)onProjects:(id)sender
{
    self.appDelegate.currentType=@"study";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"study"];//@"created";
    [self.appDelegate buildList];
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onMethods:(id)sender
{
    self.appDelegate.currentType=@"method";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"method"];//@"title";
    [self.appDelegate buildList];
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onQA:(id)sender
{
    self.appDelegate.currentType=@"qa";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"qa"];//@"title";
    [self.appDelegate buildList];
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onExperts:(id)sender
{
    self.appDelegate.currentType=@"expert";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"expert"];//@"lastname";
    [self.appDelegate buildList];
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onEvents:(id)sender
{
    self.appDelegate.currentType=@"event";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"event"];//@"start_date";
    [self.appDelegate buildList];
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onNews:(id)sender
{
    self.appDelegate.currentType=@"news";
    self.appDelegate.sortField=[[RCBaseSettings instance] sortForType:@"news"];//@"date";
    [self.appDelegate buildList];
    self.tabBarController.selectedIndex=2;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=2;
    } completion:nil];
}

- (IBAction)onPlan:(id)sender
{
    self.tabBarController.selectedIndex=1;
    self.tabBarController.selectedIndex=0;
    [UIView transitionWithView:self.view.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.tabBarController.selectedIndex=1;
    } completion:nil];
}

- (IBAction)onSlide:(id)sender
{
    if(self.slideViewController.isSideViewControllerVisible)
        [self.slideViewController slideOut];
    else
        [self.slideViewController slideIn];
}

- (IBAction)onBasics:(id)sender
{
    
}

@end
