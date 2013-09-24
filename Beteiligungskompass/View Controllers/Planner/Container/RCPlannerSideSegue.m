//
//  RCPlannerSideSegue.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerSideSegue.h"
#import "RCPlannerContainerVC.h"

@implementation RCPlannerSideSegue

- (void)perform
{
    RCPlannerContainerVC *ctrl=(RCPlannerContainerVC*)((UIViewController*)self.sourceViewController).parentViewController;
    ctrl.rightController=self.destinationViewController;
}

@end
