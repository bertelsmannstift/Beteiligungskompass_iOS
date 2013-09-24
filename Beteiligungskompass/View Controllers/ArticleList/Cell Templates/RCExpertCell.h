//
//  RCExpertCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleCell.h"

@interface RCExpertCell : RCArticleCell {
    float x_title;
    float x_facts;
    float x_shortDescription;
}
@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *factsLabel;
@property (strong, nonatomic) IBOutlet UILabel *shortDescription;

@end
