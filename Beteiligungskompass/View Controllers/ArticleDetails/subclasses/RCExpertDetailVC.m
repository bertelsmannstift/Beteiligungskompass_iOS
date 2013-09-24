//
//  RCExpertDetailVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCExpertDetailVC.h"

@interface RCExpertDetailVC ()

@end

@implementation RCExpertDetailVC

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
            [NSDictionary dictionaryWithObjectsAndKeys:@"short_description_expert",@"key",@"string",@"type",@"plain",@"output",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"type",@"full",@"output",RCLocalizedString(@"Videos", @"label.videos"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"description_institution",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Weitere Informationen", @"label.more_information"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Kontakt", @"label.contact"),@"title", nil],
            nil];
}

- (NSArray *)fieldsForSecondColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"files",@"type",@"full",@"output",RCLocalizedString(@"Downloads", @"label.downloads"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"linked_articles",@"type",@"full",@"output",RCLocalizedString(@"Zugeordnete Artikel", @"label.linked_articles"),@"title",nil],
            nil];
}

- (void)updateContent
{
    [super updateContent];
    NSMutableString *title=[NSMutableString string];
    BOOL separatorNeeded=NO;
    if(self.article.firstname!=nil && self.article.firstname.length>0)
    {
        [title appendString:self.article.firstname];
        if(self.article.lastname!=nil && self.article.lastname.length>0)
        {
            [title appendString:@" "];
            [title appendString:self.article.lastname];
        }
        separatorNeeded=YES;
    }
    if(self.article.institution!=nil && self.article.institution.length>0)
    {
        if(separatorNeeded)
            [title appendString:@", "];
        [title appendString:self.article.institution];
    }
    self.titleLabel.text=title;

}

@end
