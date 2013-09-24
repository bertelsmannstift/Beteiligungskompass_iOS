//
//  RCFilterCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCFilterCell.h"

@implementation RCFilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)fill
{
    [super fill];
    Criterion *criterion=[self.criterion objectForKey:@"criterion"];
    self.titleLabel.text=criterion.title;
}

@end
