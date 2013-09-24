//
//  RCArticleCriteriaListSection.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCArticleCriteriaListSection : UIView
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) NSMutableIndexSet *expandedSections;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sliderImg;

@property (assign, nonatomic) int secIndex;

- (void)fill;
- (IBAction)onPress:(id)sender;

@end
