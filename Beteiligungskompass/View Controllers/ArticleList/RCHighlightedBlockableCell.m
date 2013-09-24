//
//  RCHighlightedBlockableCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCHighlightedBlockableCell.h"

@implementation RCHighlightedBlockableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if(self.ignoreHighlightedCalls)return;
    [super setHighlighted:highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(self.ignoreHighlightedCalls)return;
    [super setHighlighted:highlighted animated:animated];
}

@end
