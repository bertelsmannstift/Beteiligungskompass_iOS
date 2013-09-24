//
//  RCNewsDetailVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCNewsDetailVC.h"

@interface RCNewsDetailVC ()

@end

@implementation RCNewsDetailVC

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

- (NSArray *)fieldsForFirstColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"subtitle",@"key",@"string",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"images",@"type",@"plain",@"output", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"short_description",@"key",@"string",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"type",@"full",@"output",RCLocalizedString(@"Videos", @"label.videos"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"intro",@"key",@"string",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"text",@"key",@"string",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"external_links",@"key",@"external_links",@"type",@"full",@"output",RCLocalizedString(@"Externe Links", @"label.external_links"),@"title", nil],
            nil];
}

- (NSArray *)fieldsForSecondColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"files",@"type",@"full",@"output",RCLocalizedString(@"Downloads", @"label.downloads"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"linked_articles",@"type",@"full",@"output",RCLocalizedString(@"Zugeordnete Artikel", @"global.linked_articles"),@"title",nil],
            nil];
}


@end
