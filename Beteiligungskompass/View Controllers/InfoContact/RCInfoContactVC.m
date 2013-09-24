//
//  RCInfoContactVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCInfoContactVC.h"

@interface RCInfoContactVC ()

@end

@implementation RCInfoContactVC

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
    self.webView.delegate = self;
    self.webView.scrollView.decelerationRate=UIScrollViewDecelerationRateNormal;
    
    [self.appDelegate.comm performGetTermsAndCall: ^(NSString *content){
        
        NSString *phone = @"+49 5241-810";
        NSString *mail = @"<a href=\"mailto:alexander.koop@bertelsmann-stiftung.de\">alexander.koop@bertelsmann-stiftung.de</a>";
        NSString *web = @"<a href=\"http://www.bertelsmann-stiftung.de\">Bertelsmann-Stiftung.de</a>";
        
        NSMutableString *infoContactHtml=[NSMutableString string];
        [infoContactHtml appendFormat:@"<html><head><link rel=\"stylesheet\" href=\"%@\" type=\"text/css\" /></head><body><div class='container'>",[[NSBundle mainBundle] URLForResource:@"contact" withExtension:@"css"]];
        [infoContactHtml appendFormat: @"<div id='details'><h2>%@</h2><p>Bertelsmann Stiftung<br />Carl-Bertelsmann-Str. 256<br />33311 Gütersloh<br />Deutschland</p><h2>%@</h2><p>%@: %@<br />%@: %@<br />Web: %@<br /><br /></p></div>", RCLocalizedString(@"Verantwortlich für den Inhalt", @"label.responsible_for_content"), RCLocalizedString(@"Telefon", @"label.contact"), RCLocalizedString(@"Kontakt", @"label.phone"), phone, RCLocalizedString(@"E-Mail", @"label.email"), mail, web];
        if(content)
            [infoContactHtml appendString:content];
        [infoContactHtml appendString:@"</div></body></html>"];
        [self.webView loadHTMLString:infoContactHtml baseURL:nil];
    }];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
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
