//
//  RCEventParticipationLimitsVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCEventParticipationLimitsVC.h"

@interface RCEventParticipationLimitsVC ()

@end

@implementation RCEventParticipationLimitsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=RCLocalizedString(@"Teilnahme", @"label.participation");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        self.article.participation=@"1";//@"Offen/keine Registrierung notwendig"
    }
    else if(indexPath.row==1)
    {
        self.article.participation=@"2";//@"Registrierung notwendig (Teilnahme kostenlos)"
    }
    else if(indexPath.row==2)
    {
        self.article.participation=@"3";//@"Registrierung notwendig (Teilnahme kostenpflichtig)"
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
