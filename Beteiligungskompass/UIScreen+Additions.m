//
//  UIScreen+Additions.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "UIScreen+Additions.h"

@implementation UIScreen (Additions)

-(BOOL)isLongScreen
{
    CGRect aframe = [self bounds];
    return (BOOL)(aframe.size.height > 480) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

@end
