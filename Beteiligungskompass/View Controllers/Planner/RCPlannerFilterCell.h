//
//  RCPlannerFilterCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCArticleSideCell.h"

@interface RCPlannerFilterCell : RCArticleSideCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *selectionLabel;
@property (strong, nonatomic) NSDictionary *criterion;

- (void)fill;

@end
