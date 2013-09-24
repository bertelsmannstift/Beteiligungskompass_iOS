//
//  RCSlideInVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCSlideInVC.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDE_OVERLAY_VIEW 10000

@interface RCSlideInVC ()

@end

@implementation RCSlideInVC
@synthesize mainViewController=_mainViewController;
@synthesize sideViewController=_sideViewController;
@synthesize isSideViewControllerVisible=_isSideViewControllerVisible;

- (void)setShowSideViewControllerOnTop:(BOOL)onTop
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        return;
    _onTop=onTop;
    if(onTop)
    {
        [self.view bringSubviewToFront:self.sideView];
        self.sideView.frame=CGRectMake(-320, 0, 320, self.view.frame.size.height);
        self.contentView.center=self.view.center;
        if(self.isSideViewControllerVisible)
        {
            self.sideView.center=CGPointMake(self.sideView.frame.size.width/2.0, self.sideView.frame.size.height/2.0);
        }
    }
    else
    {
        [self.view bringSubviewToFront:self.contentView];
        if(self.isSideViewControllerVisible)
        {
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                self.contentView.center=CGPointMake(self.contentView.frame.size.width/2.0+260, self.contentView.center.y);
            }
            else
            {
                self.contentView.center=CGPointMake(self.view.bounds.size.width+self.mainViewController.view.frame.size.width/2-60, self.mainViewController.view.center.y);
            }
        }
    }
}

- (void)slideIn
{
    _isSideViewControllerVisible=YES;
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        [self.mainViewController viewWillDisappear:YES];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(slideOut)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer: recognizer];
        UIView *overlay = [[UIView alloc] initWithFrame: self.contentView.frame];
        overlay.tag = SLIDE_OVERLAY_VIEW;
        overlay.backgroundColor = [UIColor clearColor];
        [overlay addGestureRecognizer: recognizer];
        [self.contentView.superview addSubview: overlay];
        
        // Want a drop shadow? Uncomment this.
        /*
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect rect = CGRectMake(-2, self.contentView.frame.origin.y, self.contentView.frame.size.width + 4,  self.contentView.frame.size.height);
        CGPathAddRect(path,  NULL, rect);
        self.contentView.layer.masksToBounds = NO;
        self.contentView.layer.shadowOpacity = 0.5;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
        self.contentView.layer.shadowRadius = 4;
        self.contentView.layer.shadowPath = path;
        CGPathRelease(path);
         */
    }
    [self.sideViewController viewWillAppear:YES];
    
    
    [UIView animateWithDuration:0.7 animations:^{
        if(_onTop)
        {
            self.sideView.center=CGPointMake(self.sideView.frame.size.width/2.0, self.sideView.frame.size.height/2.0);
        }
        else
        {
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
               self.contentView.center=CGPointMake(self.contentView.frame.size.width/2.0+260, self.contentView.center.y);
            }
            else
            {
                self.contentView.center=CGPointMake(self.view.bounds.size.width+self.mainViewController.view.frame.size.width/2-60, self.mainViewController.view.center.y);
            }
            
            UIView *hiddenOverlay = [self.contentView.superview viewWithTag: SLIDE_OVERLAY_VIEW];
            if(hiddenOverlay)
                hiddenOverlay.center = self.contentView.center;
        }
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [self.mainViewController viewDidDisappear:YES];
        [self.sideViewController viewDidAppear:YES];
    }];
}

- (void)slideOut
{
    [[self.contentView.superview viewWithTag: SLIDE_OVERLAY_VIEW] removeFromSuperview];
    
    _isSideViewControllerVisible=NO;
    [self.sideViewController viewWillDisappear:YES];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self.mainViewController viewWillAppear:YES];
    [UIView animateWithDuration:0.7 animations:^{
        if(_onTop)
        {
            self.sideView.center=CGPointMake(-self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
        }
        else
        {
            self.contentView.center=CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
        }
        [self.sideViewController viewDidDisappear:YES];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [self.mainViewController viewDidAppear:YES];
    }];
}

- (void)setMainViewController:(UIViewController *)mainViewController
{
    if(_mainViewController!=nil)
    {
        [_mainViewController willMoveToParentViewController:nil];
        [_mainViewController.view removeFromSuperview];
        [_mainViewController removeFromParentViewController];
        [_mainViewController didMoveToParentViewController:nil];
    }
    _mainViewController=mainViewController;
    [_mainViewController willMoveToParentViewController:self];
    [_mainViewController viewWillAppear:NO];
    [[self.contentView.subviews objectAtIndex:0] addSubview:_mainViewController.view];
    _mainViewController.view.frame=self.contentView.bounds;
    [self addChildViewController:_mainViewController];
    [_mainViewController didMoveToParentViewController:self];
    [_mainViewController viewDidAppear:NO];
    _isSideViewControllerVisible=NO;
}

- (void)setSideViewController:(UIViewController *)sideViewController
{
    if(_sideViewController!=nil)
    {
        [_sideViewController willMoveToParentViewController:nil];
        [_sideViewController.view removeFromSuperview];
        [_sideViewController removeFromParentViewController];
        [_sideViewController didMoveToParentViewController:nil];
    }
    _sideViewController=sideViewController;
    [_sideViewController willMoveToParentViewController:self];
    [self.sideView addSubview:_sideViewController.view];
    _sideViewController.view.frame=self.sideView.bounds;
    [self addChildViewController:_sideViewController];
    [_sideViewController didMoveToParentViewController:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.mainViewController==nil)
        [self performSegueWithIdentifier:@"loadmain" sender:nil];
    if(self.sideViewController==nil)
        [self performSegueWithIdentifier:@"loadside" sender:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentView=[[UIView alloc] init];
    self.contentView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    UIView *container=[[UIView alloc]init];
    container.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    container.clipsToBounds=YES;
    [self.contentView addSubview:container];
    
    self.sideView=[[UIView alloc] init];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.sideView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
        self.sideView.frame=CGRectMake(0, 0, 260, self.view.frame.size.height);
    }
    else
    {
        self.sideView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.sideView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.sideView.clipsToBounds=YES;
    [self.view addSubview:self.sideView];
    [self.view addSubview:self.contentView];
    self.sideView.frame=self.view.bounds;
    self.contentView.frame=self.view.bounds;
    container.frame=self.contentView.bounds;
    
    self.separator=[[UIView alloc]init];
    self.separator.autoresizingMask=UIViewAutoresizingNone;
    self.separator.frame=CGRectMake(-1, 44, 1, self.contentView.frame.size.height-44);
    self.separator.backgroundColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    [self.contentView addSubview:self.separator];
    
    self.topSeparator=[[UIView alloc] init];
    self.topSeparator.autoresizingMask=UIViewAutoresizingNone;
    self.topSeparator.frame=CGRectMake(-1, 0, 1, 44);
    self.topSeparator.backgroundColor=[UIColor whiteColor];
    [self.contentView addSubview:self.topSeparator];
    
    
    if(self.mainViewController!=nil)
    {
        [[self.contentView.subviews objectAtIndex:0] addSubview:_mainViewController.view];
        _mainViewController.view.frame=self.contentView.bounds;
    }
    if(self.sideViewController!=nil)
    {
        [self.sideView addSubview:_sideViewController.view];
        _sideViewController.view.frame=self.sideView.bounds;

    }
	// Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        if(_onTop)
        {
            self.contentView.frame=self.view.bounds;
            if(self.isSideViewControllerVisible)
                self.sideView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
            else
                self.sideView.frame=CGRectMake(-320, 0, 320, self.view.frame.size.height);
        }
        else
        {
            self.sideView.frame=CGRectMake(0, 0, 260, self.view.frame.size.height);
            if(self.isSideViewControllerVisible)
                self.contentView.center=CGPointMake(self.contentView.frame.size.width/2.0+260, self.contentView.center.y);
        }
    }
    else
    {
        if(self.isSideViewControllerVisible)
        {
            self.contentView.center=CGPointMake(self.view.bounds.size.width+self.mainViewController.view.frame.size.width/2-60, self.mainViewController.view.center.y);
        }
        
        self.separator.frame=CGRectMake(-1, UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44: 32, 1, self.contentView.frame.size.height-(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 32));
        self.topSeparator.frame=CGRectMake(-1, 0, 1, UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 32);
        
        UIView *hiddenOverlay = [self.contentView.superview viewWithTag: SLIDE_OVERLAY_VIEW];
        if(hiddenOverlay)
            hiddenOverlay.frame = self.contentView.frame;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end

@implementation UIViewController (RCSlideInSupport)

- (RCSlideInVC *)slideViewController
{
    UIViewController *ctrl=self.parentViewController;
    while(![ctrl isKindOfClass:[RCSlideInVC class]] && ctrl!=nil)
    {
        ctrl=ctrl.parentViewController;
    }
    return (RCSlideInVC*)ctrl;
}

@end