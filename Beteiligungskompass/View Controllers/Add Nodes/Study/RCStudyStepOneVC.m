//
//  RCStudyStepOneVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCStudyStepOneVC.h"
#import "RCDateSelectionVC.h"

@interface RCStudyStepOneVC ()

@end

@implementation RCStudyStepOneVC

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

- (void)onCancel:(id)sender
{
    [self.addController closeAndCancel];
}

- (void)applyData
{
    for(id elem in [self mapping])
    {
        if(![[elem objectForKey:@"readonly"] boolValue])
        {
            id control=[[self.controls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=%@",[elem objectForKey:@"tag"]]] lastObject];
            
            if([[elem objectForKey:@"number"] boolValue])
            { 
                [self.addController.article setValue:[NSNumber numberWithInteger:[[control text] integerValue]] forKey:[elem objectForKey:@"key"]];
            }
            else
                [self.addController.article setValue:[control text] forKey:[elem objectForKey:@"key"]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self applyData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    for(id elem in [self mapping])
    {
        id control=[[self.controls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag=%@",[elem objectForKey:@"tag"]]] lastObject];
        if([[elem objectForKey:@"number"] boolValue])
        {
            [control setText:[[self.addController.article valueForKey:[elem objectForKey:@"key"]] stringValue]];
        }
        else
            [control setText:[self.addController.article valueForKey:[elem objectForKey:@"key"]]];
    }
}

- (NSArray *)mapping
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"title",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"city",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"projectstart",@"key",[NSNumber numberWithInt:2],@"tag",[NSNumber numberWithBool:YES],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"projectend",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:YES],@"readonly", nil],
            nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCDateSelectionVC class]])
    {
        RCDateSelectionVC *ctrl=segue.destinationViewController;
        ctrl.article=self.addController.article;
        if([segue.identifier isEqualToString:@"start"])
        {
            ctrl.showContinuousSwitch=NO;
            ctrl.monthKey=@"start_month";
            ctrl.yearKey=@"start_year";
        }
        else if([segue.identifier isEqualToString:@"end"])
        {
            ctrl.showContinuousSwitch=YES;
            ctrl.monthKey=@"end_month";
            ctrl.yearKey=@"end_year";
        }
    }
}

@end
