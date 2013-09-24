//
//  RCBoldLabel.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCBoldLabel.h"

@interface RCBoldLabel ()
@property (strong, nonatomic) NSString *localizationKey;

@end

@implementation RCBoldLabel

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
    self.font=[UIFont boldAppFontOfSize:self.font.pointSize];
    if([self.text hasPrefix:@"#"])
    {
        self.localizationKey=[self.text substringFromIndex:1];
        self.text=RCLocalizedString(@"", self.localizationKey);
    }

}

@end
