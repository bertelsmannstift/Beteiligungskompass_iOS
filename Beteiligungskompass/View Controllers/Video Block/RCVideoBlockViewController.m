//
//  RCVideoBlockViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCVideoBlockViewController.h"
#import "RCArticleDetailVC.h"

@interface RCVideoBlockViewController ()

@end

@implementation RCVideoBlockViewController

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
	// Do any additional setup after loading the view.
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [UIView animateWithDuration:duration animations:^{
            self.descriptionLabel.hidden=YES;
            self.preview.frame=CGRectMake(0, 37, self.view.bounds.size.width, (self.view.bounds.size.height-37));
        }];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            self.descriptionLabel.hidden=NO;
            self.preview.frame=CGRectMake(self.view.bounds.size.width/2, 37, self.view.bounds.size.width/2, self.view.bounds.size.height-37);
        }];
    }
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playerView.mediaPlaybackRequiresUserAction=NO;
    self.playerView.scrollView.scrollEnabled=NO;
    self.videos=[Video fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"featured=YES"] inContext:self.appDelegate.managedObjectContext];
    if(self.currentIndex>=self.videos.count)
        self.currentIndex=0;
    [self updateUI];
}

- (void)updateUI
{
    self.indexLabel.text=[NSString stringWithFormat:@"%d/%d",self.currentIndex+1,self.videos.count];
    if(self.videos.count==0)return;
    Video *video=[self.videos objectAtIndex:self.currentIndex];
    self.titleLabel.text=video.article.title;
    self.descriptionLabel.text=video.article.plaintext;
    self.descriptionLabel.contentOffset=CGPointMake(0, 0);
    NSString *(^getFileName)(Video *video)=^(Video *video)
    {
        NSString *filename=nil;
        NSURL *url=[NSURL URLWithString:video.url];
        NSString *server=url.host;
        if([server isEqualToString:@"www.youtube.com"])
        {
            NSString *query=[url query];
            NSArray *elems=[query componentsSeparatedByString:@"&"];
            for(NSString *elem in elems)
            {
                NSArray *parts=[elem componentsSeparatedByString:@"="];
                if([[parts objectAtIndex:0] isEqualToString:@"v"])
                {
                    filename=[NSString stringWithFormat:@"%@_youtube.jpg",[parts objectAtIndex:1]];
                    break;
                }
            }
        }
        else
        {
            filename=[NSString stringWithFormat:@"%@_vimeo.jpg",[url.path lastPathComponent]];
        }
        return filename;
    };
    NSString *filename=getFileName(video);
    filename=[[[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:filename];

    NSURL *url=[NSURL URLWithString:video.url];
    if([url.host isEqualToString:@"www.youtube.com"])
    {
        NSString *query=[url query];
        NSString *videoid;
        NSArray *elems=[query componentsSeparatedByString:@"&"];
        for(NSString *elem in elems)
        {
            NSArray *parts=[elem componentsSeparatedByString:@"="];
            if([[parts objectAtIndex:0] isEqualToString:@"v"])
            {
                videoid=[parts objectAtIndex:1];
                break;
            }
        }
        
        NSURL *file=[NSURL fileURLWithPath:filename];
        NSString *content=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"youtube" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
        content=[NSString stringWithFormat:content,[[NSBundle mainBundle] URLForResource:@"jquery" withExtension:@"js"],file,self.playerView.frame.size.width,self.playerView.frame.size.height,self.playerView.frame.size.width,self.playerView.frame.size.height,videoid];
        [self.playerView loadHTMLString:content baseURL:nil];
    }
    else if([url.host isEqualToString:@"vimeo.com"])
    {
        NSString *videoid=[url.path lastPathComponent];
        NSURL *file=[NSURL fileURLWithPath:filename];
        NSString *content=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vimeo" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
        content=[NSString stringWithFormat:content,[[NSBundle mainBundle] URLForResource:@"jquery" withExtension:@"js"],file,self.playerView.frame.size.width,self.playerView.frame.size.height,self.playerView.frame.size.width,self.playerView.frame.size.height,videoid];
        [self.playerView loadHTMLString:content baseURL:nil];
    }
    
    if(self.currentIndex==0)
        self.leftBtn.hidden=YES;
    else
        self.leftBtn.hidden=NO;
    if(self.currentIndex+1==self.videos.count)
        self.rightBtn.hidden=YES;
    else
        self.rightBtn.hidden=NO;
}

- (void)continueOnTitle:(UINavigationController *)ctrl
{
    RCSlideInVC *container=[self.tabBarController.viewControllers objectAtIndex:2];
    UINavigationController *controller=nil;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        UISplitViewController *split=(UISplitViewController *)container.mainViewController;
        controller=(UINavigationController*)[split.viewControllers objectAtIndex:1];
    }
    else
    {
        controller=(UINavigationController*)container.mainViewController;
    }
    [controller pushViewController:ctrl animated:YES];
}
- (void)onTitle:(id)sender
{
    Video *video=[self.videos objectAtIndex:self.currentIndex];
    Article *article=video.article;
    self.appDelegate.currentType=article.type;
    [self.appDelegate buildList];
    UITabBarController *tabBarController=self.tabBarController;
    @try {
        RCArticleDetailVC *ctrl=[self.storyboard instantiateViewControllerWithIdentifier:article.type];
        ctrl.article=article;
        tabBarController.selectedIndex=2;
        [self performSelector:@selector(continueOnTitle:) withObject:ctrl afterDelay:0.0];
    }
    @catch (NSException *exception) {
    }
}

- (void)onPrev:(id)sender
{
    self.currentIndex--;
    [self updateUI];
}

- (void)onNext:(id)sender
{
    self.currentIndex++;
    if(self.currentIndex>=self.videos.count)
        self.currentIndex=0;
    [self updateUI];
}

@end
