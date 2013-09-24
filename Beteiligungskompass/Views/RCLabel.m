//
//  RCLabel.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCLabel.h"

@interface RCLabel ()
@property (strong, nonatomic) NSString *localizationKey;

@end


@implementation RCLabel

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
    self.font=[UIFont appFontOfSize:self.font.pointSize];
    if([self.text hasPrefix:@"#"])
    {
        self.localizationKey=[self.text substringFromIndex:1];
        self.text=RCLocalizedString(@"", self.localizationKey);
    }
}

@end
