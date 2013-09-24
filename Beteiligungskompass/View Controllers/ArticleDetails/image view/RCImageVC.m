//
//  RCImageVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCImageVC.h"
#import "RCAlertViewDelegate.h"

@interface RCImageVC ()

@end

@implementation RCImageVC {
    RCAlertViewDelegate *alertDelegate;
}

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
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.toolBar];
    self.toolBar.barStyle=-1;
    self.title=RCLocalizedString(@"Bildansicht", @"label.image_view");
    self.imageView.delegate=self;
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

- (void)updateURL
{
    Image *img=[self.images objectAtIndex:self.currentImage];
    File *file=img.file;
    NSString *url=[NSString stringWithFormat:@"%@media/%@-%@",baseurl,file.id_from_import,file.filename];
    NSURL *encapsulated=[NSURL URLWithString:url];
    [self.imageView loadRequest:[NSURLRequest requestWithURL:encapsulated]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateURL];
}

- (void)onLeft:(id)sender
{
    self.currentImage--;
    if(self.currentImage<0)
        self.currentImage=0;
    [self updateURL];
}

- (void)onRight:(id)sender
{
    self.currentImage++;
    if(self.currentImage>=self.images.count)
        self.currentImage=self.images.count-1;
    [self updateURL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    alertDelegate=[[RCAlertViewDelegate alloc] init];
    __weak RCImageVC *me=self;
    [alertDelegate addButtonWithText:RCLocalizedString(@"OK", @"imageview.loadfailed.OK") isCancelButton:YES pressedHandler:^{
        RCImageVC *myself=me;
        [myself.navigationController popViewControllerAnimated:YES];
    }];
    [alertDelegate runAlertViewWithTitle:RCLocalizedString(@"Verbindungsproblem", @"imageview.loadfailed.title") message:RCLocalizedString(@"Es ist ein Fehler beim Abrufen des Bildes aufgetreten. Bitte versuchen Sie es später erneut.", @"imageview.loadfailed.description")];
    
}

@end
