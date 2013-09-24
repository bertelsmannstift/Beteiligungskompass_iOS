//
//  RCAboutViewController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCBasicsViewController.h"

@interface RCBasicsViewController ()

@end

@implementation RCBasicsViewController

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
    self.webView.delegate = self;
    self.webView.scrollView.decelerationRate=UIScrollViewDecelerationRateNormal;
    Page *page=[[Page fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type=%@",@"basics_static"] inContext:self.appDelegate.managedObjectContext] lastObject];
    if(page!=nil)
    {
        NSMutableString *infoContactHtml=[NSMutableString string];
        [infoContactHtml appendFormat:@"<html><head><link rel=\"stylesheet\" href=\"%@\" type=\"text/css\" /></head><body><div class='container'>",[[NSBundle mainBundle] URLForResource:@"contact" withExtension:@"css"]];
        [infoContactHtml appendString:page.content];
        [infoContactHtml appendString:@"</div></body></html>"];
        [self.webView loadHTMLString:infoContactHtml baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSString *uri = [request.URL absoluteString];
        
        if([[uri lowercaseString] rangeOfString: @"applewebdata://"].location != NSNotFound)
        {
            uri = [uri stringByReplacingOccurrencesOfString: @"applewebdata://" withString: @""];
            NSRange rangeOfFirstSlash = [uri rangeOfString: @"/"];
            uri = [uri stringByReplacingCharactersInRange: NSMakeRange(0, rangeOfFirstSlash.location + 1) withString: @"http://"];
        }
        
        NSURL *url = [NSURL URLWithString: uri];
        [[UIApplication sharedApplication] openURL: url];
        
		return NO;
    }
    
    return YES;
}

@end