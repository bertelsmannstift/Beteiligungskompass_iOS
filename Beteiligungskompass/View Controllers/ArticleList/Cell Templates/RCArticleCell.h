//
//  RCArticleCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCArticleSideCell.h"

@interface RCArticleCell : RCArticleSideCell
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) IBOutlet UIImageView *authorImage;
@property (nonatomic, strong) IBOutlet UIButton *favButton;

- (void)fill;

- (IBAction)onFav:(id)sender;


@end
