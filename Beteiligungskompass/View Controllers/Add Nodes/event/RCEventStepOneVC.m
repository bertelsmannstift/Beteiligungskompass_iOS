//
//  RCEventStepOneVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCEventStepOneVC.h"
#import "RCNewsDateSelectionVC.h"

@interface RCEventStepOneVC ()

@end

@implementation RCEventStepOneVC

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)mapping
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"title",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"event_startdate",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:YES],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"event_enddate",@"key",[NSNumber numberWithInt:2],@"tag",[NSNumber numberWithBool:YES],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"city",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"zip",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"street",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"street_nr",@"key",[NSNumber numberWithInt:2],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"venue",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"organized_by",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCNewsDateSelectionVC class]])
    {
        RCNewsDateSelectionVC *ctrl=segue.destinationViewController;
        ctrl.article=self.addController.article;
        ctrl.key=segue.identifier;
    }
}

@end
