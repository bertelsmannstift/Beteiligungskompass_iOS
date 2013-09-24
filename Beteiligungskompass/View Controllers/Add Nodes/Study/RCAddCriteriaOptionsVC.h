//
//  RCAddCriteriaOptionsVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCAddCriteriaOptionsVC : UITableViewController
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) Criterion *criterion;
@property (strong, nonatomic) NSMutableArray *selection;
@property (strong, nonatomic) NSArray *options;

@end
