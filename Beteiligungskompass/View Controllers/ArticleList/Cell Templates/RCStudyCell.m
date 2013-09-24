//
//  RCStudyCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCStudyCell.h"

@implementation RCStudyCell

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
    [super fill];
    self.titleLabel.text=self.article.title;
    self.shortDescription.text=self.article.plaintext;
    NSMutableString *string=[NSMutableString string];
    BOOL separatorNeeded=NO;
    CriteriaOption *option=nil;
    
     NSArray *items=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@",@"country"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil]];
    if(items.count>0)
        option=[items objectAtIndex:0];
    
    if(self.article.city!=nil && ![self.article.city isEqualToString: @""])
    {
        [string appendString:self.article.city];
        separatorNeeded=YES;
    }
    else if(option && option.title && ![option.title isEqualToString: @""])
    {
        [string appendString: option.title];
        separatorNeeded=YES;
    }
    else if(self.article.country && ![self.article.country isEqualToString: @""])
    {
        [string appendString: self.article.country];
        separatorNeeded=YES;
    }
    
    NSString *duration=self.article.projectduration;
    
    if(duration!=nil)
    {
        if(separatorNeeded)
            [string appendString:@" | "];
        [string appendString:duration];
    }
    
    if([self.article.end_year intValue]==0)
    {
        [string appendFormat:@" | %@: %@",RCLocalizedString(@"Status", @"label.projectstatus"),RCLocalizedString(@"", @"label.state_ongoing")];
    }
    else
    {
        NSDateComponents *comps=[[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
        if([comps year]>[self.article.end_year intValue] || ([comps year]==[self.article.end_year intValue] && [comps month]>[self.article.end_month intValue]))
        {
            [string appendFormat:@" | %@: %@",RCLocalizedString(@"Status", @"label.projectstatus"),RCLocalizedString(@"", @"label.state_closed")];
        }
        else
        {
            [string appendFormat:@" | %@: %@",RCLocalizedString(@"Status", @"label.projectstatus"),RCLocalizedString(@"", @"label.state_ongoing")];
        }
    }
    
    self.factsLabel.text=string;
    
    self.thumbnail.image=nil;
    NSArray *images=[self.article.images sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    if(images.count>0)
    {
        Image *img=[images objectAtIndex:0];
        NSString *path=[[[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:@"200x"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",img.file.id_from_import,img.file.filename]];
        self.thumbnail.image=[UIImage imageWithContentsOfFile:path];
    }
    if(x_title==0)
    {
        x_title=self.titleLabel.frame.origin.x;
        x_facts=self.factsLabel.frame.origin.x;
        x_shortDescription=self.shortDescription.frame.origin.x;
    }
}

@end
