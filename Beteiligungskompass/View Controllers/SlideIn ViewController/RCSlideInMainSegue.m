//
//  RCSlideInMainSegue.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCSlideInMainSegue.h"
#import "RCSlideInVC.h"

@implementation RCSlideInMainSegue

- (void)perform
{
    RCSlideInVC *ctrl=self.sourceViewController;
    ctrl.mainViewController=self.destinationViewController;
}

@end
