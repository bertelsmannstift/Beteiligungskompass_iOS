//
//  RCPlannerSliderCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCPlannerSliderCell.h"
#import "RCPlannerVC.h"

@implementation RCPlannerSliderCell
{
    int _prevSliderValue;
}

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
    
    self.slider.minimumValue=0;
    self.slider.maximumValue=criterion.options.count - 1;
    CriteriaOption *option=[[[self.criterion objectForKey:@"selection"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]] lastObject];
    if(option==nil)
    {
        option=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"default_value=YES"]] anyObject];
    }
    self.slider.value=[option.orderindex intValue];
    self.selectionLabel.text=option.title;
    if([option.default_value boolValue])
    {
        self.selectionLabel.textColor=[UIColor colorWithWhite:0.333 alpha:1.000];
    }
    else
    {
        self.selectionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
    }
}

- (void)editingEnded:(id)sender
{
    [self.appDelegate buildList];
    [self.ctrl update];
    
    // Backtracking if zero results
    if(self.appDelegate.numberOfAllPlannedObjects == 0)
    {
        [(UISlider *)sender setValue: _prevSliderValue animated: YES];
        [self onSlider: sender];
        [self.appDelegate buildList];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                        message: RCLocalizedString(@"Keine Artikel gefunden", @"label.message_no_article_found")
                                                       delegate: nil cancelButtonTitle: RCLocalizedString(@"OK", @"label.ok")
                                              otherButtonTitles: nil];
        [alert show];
    }
    else
        _prevSliderValue = (int)[(UISlider *)sender value];
}
- (void)onSlider:(id)sender
{
    int value=(int)self.slider.value;
    Criterion *criterion=[self.criterion objectForKey:@"criterion"];
    NSArray *options=[[criterion.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"orderindex<=%d",value]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]];
    NSMutableArray *selection=[self.criterion objectForKey:@"selection"];
    [selection removeAllObjects];
    [selection addObjectsFromArray:options];
    CriteriaOption *option=[options lastObject];
    if([option.default_value boolValue])
    {
        [selection removeAllObjects];
        self.selectionLabel.textColor=[UIColor colorWithWhite:0.333 alpha:1.000];
    }
    else
    {
        self.selectionLabel.textColor=[UIColor colorWithRed:0.961 green:0.710 blue:0.176 alpha:1.000];
    }
    self.selectionLabel.text=option.title;
}

@end
