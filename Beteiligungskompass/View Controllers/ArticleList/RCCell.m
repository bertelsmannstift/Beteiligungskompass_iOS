//
//  RCCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCCell.h"
#import <CoreText/CoreText.h>

@implementation RCCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupselection];
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.textLabel.font.fontName, self.textLabel.font.pointSize, NULL);
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
    BOOL isBold = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
    CFRelease(font);
    if(isBold)
    {
        self.textLabel.font=[UIFont boldAppFontOfSize:self.textLabel.font.pointSize];
    }
    else
    {
        self.textLabel.font=[UIFont appFontOfSize:self.textLabel.font.pointSize];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupselection];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupselection
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    view.backgroundColor=[UIColor colorWithRed:0.298 green:0.506 blue:0.659 alpha:1.000];
    self.selectedBackgroundView=view;
}

@end
