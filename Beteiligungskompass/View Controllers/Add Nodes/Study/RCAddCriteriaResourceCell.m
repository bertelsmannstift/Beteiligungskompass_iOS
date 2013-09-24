//
//  RCAddCriteriaResourceCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCAddCriteriaResourceCell.h"
#import "SBJson.h"

@implementation RCAddCriteriaResourceCell

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
    self.titleLabel.text=self.criterion.title;
    NSArray *selection=[self.article.criteria_json JSONValue];
    CriteriaOption *subselect=[[self.criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"id_from_import in %@",selection]] anyObject];
    if(subselect==nil)
    {
        self.subtitleLabel.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    }
    else
    {
        self.subtitleLabel.text=subselect.title;
    }
    self.slider.minimumValue=0;
    self.slider.maximumValue=self.criterion.options.count-1;
    NSArray *items=[self.criterion.options sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    int idx=[items indexOfObject:subselect];
    if(subselect==nil)
        idx=0;
    self.slider.value=idx;
}

- (void)onSlider:(id)sender
{
    int value=(int)self.slider.value;
    NSArray *items=[self.criterion.options sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    NSMutableArray *selection=[[self.article.criteria_json JSONValue] mutableCopy];
    if(selection==nil)
        selection=[NSMutableArray array];
    for(CriteriaOption *option in items)
    {
        if([selection containsObject:option.id_from_import])
            [selection removeObject:option.id_from_import];
    }
    CriteriaOption *option=[items objectAtIndex:value];
    if(![option.default_value boolValue])
        [selection addObject:option.id_from_import];
    self.article.criteria_json=[selection JSONRepresentation];
    self.subtitleLabel.text=option.title;
}

@end
