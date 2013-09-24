//
//  RCArticleSectionHeaderView.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleSectionHeaderView.h"

@implementation RCArticleSectionHeaderView
@synthesize section=_section;
@synthesize tableView=_tableView;
@synthesize descriptionLabel=_descriptionLabel;
@synthesize secIndex=secIndex;

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
    self.descriptionLabel.text=[self.section objectForKey:@"title"];
    if([[self.section objectForKey:@"expanded"] boolValue])
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
    NSNumber *expanded=[self.section objectForKey:@"expanded"];
    if([expanded boolValue])
    {
        expanded=[NSNumber numberWithBool:NO];
        self.sliderImg.image=[UIImage imageNamed:@"icon_slider_down.png"];
    }
    else
    {
        expanded=[NSNumber numberWithBool:YES];
        self.sliderImg.image=[UIImage imageNamed:@"icon_slider_up.png"];
    }
    [self.section setObject:expanded forKey:@"expanded"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:secIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
