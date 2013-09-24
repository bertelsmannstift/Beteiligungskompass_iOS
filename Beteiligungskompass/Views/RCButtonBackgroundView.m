//
//  RCButtonBackgroundView.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCButtonBackgroundView.h"

@implementation RCButtonBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)onPress:(id)sender
{
    self.normalView.hidden=YES;
    self.pressedView.hidden=NO;
}

- (void)onUnpress:(id)sender
{
    self.normalView.hidden=NO;
    self.pressedView.hidden=YES;
}

@end
