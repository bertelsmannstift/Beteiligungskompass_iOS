//
//  RCSlideInSideSegue.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCSlideInSideSegue.h"
#import "RCSlideInVC.h"

@implementation RCSlideInSideSegue

- (void)perform
{
    RCSlideInVC *ctrl=self.sourceViewController;
    ctrl.sideViewController=self.destinationViewController;
}


@end
