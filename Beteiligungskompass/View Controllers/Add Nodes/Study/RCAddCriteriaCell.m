//
//  RCAddCriteriaCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCAddCriteriaCell.h"
#import "SBJson.h"

@implementation RCAddCriteriaCell

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
    NSSet *subselect=[self.criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"id_from_import IN %@",selection]];
    if(subselect.count==0)
    {
        self.subtitleLabel.text=RCLocalizedString(@"Keine Auswahl", @"global.select_mone_selected_text");
    }
    else
        self.subtitleLabel.text=[NSString stringWithFormat:RCLocalizedString(@"%d von %d ausgewählt",@"label.amount_range"),subselect.count,self.criterion.options.count];
}

@end
