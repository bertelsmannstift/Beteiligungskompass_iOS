//
//  RCAddCriteriaResourceCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCAddCriteriaResourceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) Criterion *criterion;

- (IBAction)onSlider:(id)sender;
- (void)fill;

@end
