//
//  RCMethodCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCMethodCell.h"

@implementation RCMethodCell

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
    NSArray *items=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@",@"limit_search"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil]];
    if(items.count>0)
        option=[items objectAtIndex:0];
    
    if(option!=nil)
    {
        if(separatorNeeded)
            [string appendString:@" | "];
        [string appendFormat:@"%@: %@",RCLocalizedString(@"Medium", @"label.medium"),option.title];
        separatorNeeded=YES;
    }

    option=nil;
    items=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@",@"ressources"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil]];
    if(items.count>0)
        option=[items objectAtIndex:0];
    
    if(option!=nil)
    {
        if(separatorNeeded)
            [string appendString:@" | "];
        [string appendFormat:@"%@: %@",RCLocalizedString(@"Kosten", @"global.cost"),option.title];
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
