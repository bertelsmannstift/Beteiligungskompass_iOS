//
//  RCArticleCriteriaListSection.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleCriteriaListSection.h"

@implementation RCArticleCriteriaListSection
@synthesize tableView=_tableView;
@synthesize expandedSections=_expandedSections;
@synthesize descriptionLabel=_descriptionLabel;
@synthesize sliderImg=_sliderImg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)fill
{
    if([self.expandedSections containsIndex:self.secIndex])
    {
        self.sliderImg.image=[UIImage imageNamed:@"icon_slider_up.png"];
    }
    else
    {
        self.sliderImg.image=[UIImage imageNamed:@"icon_slider_down.png"];
    }
}

- (void)onPress:(id)sender
{
    if([self.expandedSections containsIndex:self.secIndex])
    {
        [self.expandedSections removeIndex:self.secIndex];
        self.sliderImg.image=[UIImage imageNamed:@"icon_slider_down.png"];
    }
    else
    {
        [self.expandedSections addIndex:self.secIndex];
        self.sliderImg.image=[UIImage imageNamed:@"icon_slider_up.png"];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.secIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
