//
//  RCButton.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCButton.h"

@implementation RCButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    if([[self titleForState:UIControlStateNormal] hasPrefix:@"#"])
    {
        [self setTitle:RCLocalizedString(nil,[[self titleForState:UIControlStateNormal] substringFromIndex:1]) forState:UIControlStateNormal];
    }
}

@end
