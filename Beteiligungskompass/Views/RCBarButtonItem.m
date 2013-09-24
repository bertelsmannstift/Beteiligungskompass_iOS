//
//  RCBarButtonItem.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCBarButtonItem.h"

@implementation RCBarButtonItem

- (void)awakeFromNib
{
    [super awakeFromNib];
    if([self.title hasPrefix:@"#"])
    {
        self.title=RCLocalizedString(nil, [self.title substringFromIndex:1]);
    }
}
@end
