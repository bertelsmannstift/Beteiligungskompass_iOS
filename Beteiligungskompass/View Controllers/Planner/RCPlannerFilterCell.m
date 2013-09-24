//
//  RCPlannerFilterCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerFilterCell.h"

@implementation RCPlannerFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fill
{
    Criterion *criterion=[self.criterion objectForKey:@"criterion"];
    NSString *title=criterion.criterionDescription;
    title=[title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if([title hasPrefix:@"-"])
    {
        title=[title stringByReplacingOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, 1)];
        title=[title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    }
    self.titleLabel.text=title;
    NSArray *items=[self.criterion objectForKey:@"selection"];
    if(items.count==0)
    {
        self.selectionLabel.textColor=[UIColor colorWithWhite:0.333 alpha:1.000];
        CriteriaOption *option=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"default_value==YES"]] anyObject];
        if(option==nil)
        {
            self.selectionLabel.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
        }
        else
            self.selectionLabel.text=option.title;
    }
    else if(items.count==1)
    {
        self.selectionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
        CriteriaOption *option=[items lastObject];
        self.selectionLabel.text=option.title;
    }
    else if([criterion.discriminator isEqualToString:@"country"])
    {
        self.selectionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
        CriteriaOption *option=[items objectAtIndex:0];
        self.selectionLabel.text=option.title;
    }
    else if(items.count>1)
    {
        NSMutableString *text=[[NSMutableString alloc] init];
        BOOL first=YES;
        for(CriteriaOption *option in items)
        {
            if(first)
                first=NO;
            else
                [text appendString:@"\n"];
            [text appendString:option.title];
        }
        self.selectionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
        self.selectionLabel.text=text;
        self.selectionLabel.numberOfLines=0;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size=[self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, 2009)];
    self.titleLabel.frame=CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, size.height);
    
    size=[self.selectionLabel.text sizeWithFont:self.selectionLabel.font constrainedToSize:CGSizeMake(self.selectionLabel.frame.size.width, 2009)];
    self.selectionLabel.frame=CGRectMake(self.selectionLabel.frame.origin.x, CGRectGetMaxY(self.selectionLabel.frame)-size.height, self.selectionLabel.frame.size.width, size.height);
}

@end
