//
//  RCPlannerContainerVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerContainerVC.h"

@interface RCPlannerContainerVC ()

@end

@implementation RCPlannerContainerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.sliderBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldAppFontOfSize:15],UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    self.title=RCLocalizedString(@"Vorhaben planen", @"module.planning.title");
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.leftController==nil)
    {
        [self performSegueWithIdentifier:@"loadMain" sender:nil];
    }
}

- (void)setLeftController:(UIViewController *)leftController
{
    if(_leftController!=nil)
    {
        [_leftController willMoveToParentViewController:nil];
        [_leftController.view removeFromSuperview];
        [_leftController didMoveToParentViewController:nil];
        _leftController=nil;
    }
    [leftController willMoveToParentViewController:self];
    [self addChildViewController:leftController];
    [self.leftContainer addSubview:leftController.view];
    [leftController viewWillAppear:NO];
    leftController.view.frame=self.leftContainer.bounds;
    [leftController viewDidAppear:NO];
    [self.leftController didMoveToParentViewController:self];
    _leftController=leftController;
}

- (void)setRightController:(UIViewController *)rightController
{
    if(_rightController!=nil)
    {
        [_rightController willMoveToParentViewController:nil];
        [_rightController.view removeFromSuperview];
        [_rightController didMoveToParentViewController:nil];
        _rightController=nil;
    }
    [rightController willMoveToParentViewController:self];
    [self addChildViewController:rightController];
    [self.rightContainer addSubview:rightController.view];
    [rightController viewWillAppear:NO];
    rightController.view.frame=self.rightContainer.bounds;
    [rightController viewDidAppear:NO];
    [self.leftController didMoveToParentViewController:self];
    _leftController=rightController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onSlider:(id)sender
{
    if(self.slideViewController.isSideViewControllerVisible)
        [self.slideViewController slideOut];
    else
        [self.slideViewController slideIn];
}

@end
