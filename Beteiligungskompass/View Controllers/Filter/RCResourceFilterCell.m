//
//  RCResourceFilterCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCResourceFilterCell.h"
#import "RCArticleSideCell.h"

@implementation RCResourceFilterCell
@synthesize titleLabel=_titleLabel;
@synthesize descriptionLabel=_descriptionLabel;
@synthesize slider=_slider;
@synthesize elem=_elem;

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
    Criterion *criterion=[self.elem objectForKey:@"criterion"];
    self.titleLabel.text=criterion.title;
    self.slider.minimumValue=0;
    self.slider.maximumValue=criterion.options.count - 1;
    CriteriaOption *option=[[[self.elem objectForKey:@"selection"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]] lastObject];
    if(option==nil)
    {
        option=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"default_value=YES"]] anyObject];
    }
    self.slider.value=[option.orderindex intValue];
    if([option.default_value boolValue])
    {
        self.descriptionLabel.textColor=[UIColor colorWithWhite:0.333 alpha:1.000];
    }
    else
    {
        self.descriptionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
    }
    self.descriptionLabel.text=option.title;
}

- (void)onEditingEnded:(id)sender
{
    [self.appDelegate buildList];
}

- (void)onSlider:(id)sender
{
    int value=(int)self.slider.value;
    Criterion *criterion=[self.elem objectForKey:@"criterion"];
    NSArray *options=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"orderindex<=%d",value]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    NSMutableArray *selection=[self.elem objectForKey:@"selection"];
    [selection removeAllObjects];
    [selection addObjectsFromArray:options];
    CriteriaOption *option=[options lastObject];
    if([option.default_value boolValue])
    {
        [selection removeAllObjects];
        self.descriptionLabel.textColor=[UIColor colorWithWhite:0.333 alpha:1.000];
    }
    else
    {
        self.descriptionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
    }
    self.descriptionLabel.text=option.title;
}

@end