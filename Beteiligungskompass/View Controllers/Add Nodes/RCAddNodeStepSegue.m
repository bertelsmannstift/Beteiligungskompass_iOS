//
//  RCAddNodeStepSegue.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCAddNodeStepSegue.h"
#import "RCAddNodeContainerViewController.h"

@implementation RCAddNodeStepSegue

- (void)perform
{
    RCAddNodeContainerViewController *container;
    if([self.sourceViewController isKindOfClass:[RCAddNodeContainerViewController class]])
    {
        container=self.sourceViewController;
    }
    else
        container=(RCAddNodeContainerViewController*)((UIViewController*)self.sourceViewController).parentViewController;
    [container switchToViewController:self.destinationViewController];
}

@end
