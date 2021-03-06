//
//  RCResourceFilterCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCArticleSideCell.h"

@class RCArticleSideCell;

@interface RCResourceFilterCell : RCArticleSideCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) id elem;

- (IBAction)onEditingEnded:(id)sender;
- (IBAction)onSlider:(id)sender;
- (void)fill;

@end