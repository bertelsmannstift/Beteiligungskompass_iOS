//
//  RCAddNodeContainerViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCAddNodeContainerViewController.h"

@interface RCAddNodeContainerViewController ()

@end

@implementation RCAddNodeContainerViewController

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
    [self performSegueWithIdentifier:@"init" sender:nil];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *type=self.article.type;
    if([self.article.type isEqualToString:@"study"])
    {
        type=@"project";
    }
    self.title=RCLocalizedString(@"", [@"label.add_" stringByAppendingString:type]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)switchToViewController:(UIViewController *)newViewController
{
    if(self.currentViewController!=nil)
    {
        id<AddStep> casted=(id<AddStep>)self.currentViewController;
        if([casted respondsToSelector:@selector(applyData)])
            [casted applyData];
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
    }
    self.currentViewController=newViewController;
    [self.currentViewController willMoveToParentViewController:self];
    [self.containerView addSubview:self.currentViewController.view];
    self.currentViewController.view.frame=self.containerView.bounds;
    [self addChildViewController:self.currentViewController];
    [self.currentViewController didMoveToParentViewController:self];
    //TODO: switch button.
    int tag=self.currentViewController.view.tag;
    UIButton *btn=[[self.sectionButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag==%d",tag]] lastObject];
    btn.backgroundColor=[UIColor colorWithRed:0.047 green:0.298 blue:0.525 alpha:1.000];
    
}

+ (UIViewController *)instantiateViewControllerForArticleType:(NSString *)type
{
    UINavigationController *ctrl=nil;
    RCAddNodeContainerViewController *cont=nil;
    if([type isEqualToString:@"study"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddArticleStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddArticleStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        cont=[ctrl.viewControllers objectAtIndex:0];
    }
    else if([type isEqualToString:@"method"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddMethodStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddMethodStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        cont=[ctrl.viewControllers objectAtIndex:0];
    }
    else if([type isEqualToString:@"qa"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddQAStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddQAStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        cont=[ctrl.viewControllers objectAtIndex:0];
        
    }
    else if([type isEqualToString:@"expert"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddExpertStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddExpertStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        cont=[ctrl.viewControllers objectAtIndex:0];
        
    }
    else if([type isEqualToString:@"news"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddNewsStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddNewsStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        cont=[ctrl.viewControllers objectAtIndex:0];
        
    }
    else if([type isEqualToString:@"event"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddEventStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddEventStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        cont=[ctrl.viewControllers objectAtIndex:0];
        
    }
    cont.article=[Article createObjectInContext:ctrl.appDelegate.managedObjectContext];
    cont.article.type=type;
    cont.article.is_custom=[NSNumber numberWithBool:YES];
    cont->created=YES;
    [ctrl.appDelegate.managedObjectContext assignObject:cont.article toPersistentStore:ctrl.appDelegate.userStore];
    return ctrl;
}

+ (UIViewController *)instantiateViewControllerForDataSet:(Article *)article
{
    UINavigationController *ctrl=nil;
    if([article.type isEqualToString:@"study"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddArticleStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddArticleStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }
    else if([article.type isEqualToString:@"method"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddMethodStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddMethodStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }
    else if([article.type isEqualToString:@"qa"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddQAStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddQAStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }
    else if([article.type isEqualToString:@"expert"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddExpertStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddExpertStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }
    else if([article.type isEqualToString:@"news"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddNewsStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddNewsStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }
    else if([article.type isEqualToString:@"event"])
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddEventStoryboard~ipad" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else
        {
            ctrl=[[UIStoryboard storyboardWithName:@"AddEventStoryboard~iphone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }
    RCAddNodeContainerViewController *cont=[ctrl.viewControllers objectAtIndex:0];
    cont.article=article;
    cont->created=NO;
    return ctrl;
}

- (void)closeAndCancel
{
    if(created)
        [self.appDelegate.managedObjectContext deleteObject:self.article];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


@implementation UIViewController (AddNodeController)

- (RCAddNodeContainerViewController*)addController
{
    return (RCAddNodeContainerViewController*)self.parentViewController;
}

@end