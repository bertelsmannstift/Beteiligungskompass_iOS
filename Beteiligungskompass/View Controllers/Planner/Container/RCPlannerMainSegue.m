//
//  RCPlannerMainSegue.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerMainSegue.h"
#import "RCPlannerContainerVC.h"
#import "RCPlannerVC.h"

@implementation RCPlannerMainSegue


- (void)perform
{
    RCPlannerContainerVC *ctrl=self.sourceViewController;
    ctrl.leftController=self.destinationViewController;
    if([self.destinationViewController isKindOfClass:[RCPlannerVC class]])
    {
        RCPlannerVC *casted=self.destinationViewController;
        casted.sliderBtn=ctrl.sliderBtn;
    }
    
    
}
@end
