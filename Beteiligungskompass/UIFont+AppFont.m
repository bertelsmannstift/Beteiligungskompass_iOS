//
//  UIFont+AppFont.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "UIFont+AppFont.h"

@implementation UIFont (AppFont)

+ (UIFont *) appFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"DroidSans" size:size];
}

+ (UIFont *) boldAppFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"DroidSans-Bold" size:size];
}


@end
