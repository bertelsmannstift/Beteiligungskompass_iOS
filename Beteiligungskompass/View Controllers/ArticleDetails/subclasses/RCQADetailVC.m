//
//  RCQADetailVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCQADetailVC.h"

@interface RCQADetailVC ()

@end

@implementation RCQADetailVC

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
            [NSDictionary dictionaryWithObjectsAndKeys:@"images",@"type",@"plain",@"output", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"question",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Fragestellung", @"label.question"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"type",@"full",@"output",RCLocalizedString(@"Videos", @"label.videos"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"answer",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Inhalt", @"label.answer"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"publisher",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Herausgeber", @"label.publisher"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"author_answer",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Autor", @"label.author"),@"title", nil],
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
