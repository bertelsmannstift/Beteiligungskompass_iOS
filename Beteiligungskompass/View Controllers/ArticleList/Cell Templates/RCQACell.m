//
//  RCQACell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCQACell.h"

@implementation RCQACell

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
    if(self.article.author_answer!=nil)
    {
        [string appendFormat:@"%@: %@",RCLocalizedString(@"Autor", @"label.author"),self.article.author_answer];
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
