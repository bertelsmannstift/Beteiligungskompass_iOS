//
//  RCMethodDetailVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCMethodDetailVC.h"

@interface RCMethodDetailVC ()

@end

@implementation RCMethodDetailVC

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
            [NSDictionary dictionaryWithObjectsAndKeys:@"short_description",@"key",@"string",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"type",@"full",@"output",RCLocalizedString(@"Videos", @"label.videos"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"long_description",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Ablauf/Eckpunkte", @"label.description"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"used_for",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Ziel/Wirkung", @"label.used_for"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"participants",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Hinweise zur Umsetzung", @"label.participants"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"costs",@"key",@"costs",@"type",@"full",@"output",RCLocalizedString(@"Kosten/Aufwand", @"label.costs"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"time_expense",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Aufwand Teilnehmer", @"label.time_expense"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"when_to_use",@"type",@"full",@"output",RCLocalizedString(@"Sinnvoll einzusetzen, wenn", @"label.when_to_use"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"when_not_to_use",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Nicht sinnvoll einzusetzen, wenn", @"label.when_not_to_use"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"strengths",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Stärken", @"label.strengths"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"weaknesses",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Schwächen", @"label.weaknesses"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"origin",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Ursprung", @"label.origin"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"restrictions",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Nutzungsrechte", @"label.restrictions"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"external_links",@"key",@"external_links",@"type",@"full",@"output",RCLocalizedString(@"Externe Links", @"label.external_links"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Kontakt", @"label.contact"),@"title", nil],
            nil];
}

- (NSArray *)fieldsForSecondColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"files",@"type",@"full",@"output",RCLocalizedString(@"Downloads", @"label.downloads"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"linked_articles",@"type",@"full",@"output",RCLocalizedString(@"Zugeordnete Artikel", @"global.linked_articles"),@"title",nil],
            nil];
}

- (NSString*)fetchValueForFieldWithType:(NSString*)type key:(NSString *)key
{
    if([type isEqualToString:@"costs"])
        return self.article.costs;
    else
        return [super fetchValueForFieldWithType:type key:key];
}


@end
