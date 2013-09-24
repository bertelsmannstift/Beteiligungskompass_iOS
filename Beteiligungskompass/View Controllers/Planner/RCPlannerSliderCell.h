//
//  RCPlannerSliderCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCArticleSideCell.h"
@class RCPlannerVC;

@interface RCPlannerSliderCell : RCArticleSideCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *selectionLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) id criterion;
@property (weak, nonatomic) RCPlannerVC *ctrl;

- (void)fill;
- (IBAction)editingEnded:(id)sender;
- (IBAction)onSlider:(id)sender;

@end
