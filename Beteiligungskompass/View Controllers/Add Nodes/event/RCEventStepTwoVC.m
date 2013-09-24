//
//  RCEventStepTwoVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCEventStepTwoVC.h"
#import "RCNewsDateSelectionVC.h"
#import "RCEventParticipationLimitsVC.h"

@interface RCEventStepTwoVC ()

@end

@implementation RCEventStepTwoVC

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

- (NSArray*)mapping
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"long_description",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"number_of_participants",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"participation",@"key",[NSNumber numberWithInt:2],@"tag",[NSNumber numberWithBool:YES],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"fee",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact_person",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"email",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"key",[NSNumber numberWithInt:2],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"fax",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"link",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"event_deadline",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:YES],@"readonly", nil],
            nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCNewsDateSelectionVC class]])
    {
        RCNewsDateSelectionVC *ctrl=segue.destinationViewController;
        ctrl.key=segue.identifier;
        ctrl.article=self.addController.article;
    }
    else if([segue.destinationViewController isKindOfClass:[RCEventParticipationLimitsVC class]])
    {
        RCEventParticipationLimitsVC *ctrl=segue.destinationViewController;
        ctrl.article=self.addController.article;
    }
}
@end
