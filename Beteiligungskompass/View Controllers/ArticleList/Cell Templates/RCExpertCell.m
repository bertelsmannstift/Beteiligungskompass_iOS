//
//  RCExpertCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCExpertCell.h"

@implementation RCExpertCell

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
    NSMutableString *title=[NSMutableString string];
    BOOL separatorNeeded=NO;
    if(self.article.firstname!=nil && self.article.firstname.length>0)
    {
        [title appendString:self.article.firstname];
        if(self.article.lastname!=nil && self.article.lastname.length>0)
        {
            [title appendString:@" "];
            [title appendString:self.article.lastname];
        }
        separatorNeeded=YES;
    }
    if(self.article.institution!=nil && self.article.institution.length>0)
    {
        if(separatorNeeded)
            [title appendString:@", "];
        [title appendString:self.article.institution];
    }
    self.titleLabel.text=title;
    
    self.shortDescription.text=self.article.plaintext;
    NSMutableString *string=[NSMutableString string];
    separatorNeeded=NO;
    if(self.article.city!=nil)
    {
        [string appendString:self.article.city];
        separatorNeeded=YES;
    }
    NSArray *options=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@ AND parent!=NULL",@"country"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
    if(options.count>0)
    {
        if(separatorNeeded)
            [string appendString:@", "];
        [string appendString:((CriteriaOption*)[options objectAtIndex:0]).title];
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
