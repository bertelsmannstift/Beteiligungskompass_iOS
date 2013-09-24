//
//  RCArticleCriteriaList.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCArticleCriteriaList : UITableViewController
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) NSArray *criteria;
@property (strong, nonatomic) NSMutableIndexSet *expandedSections;

@end
