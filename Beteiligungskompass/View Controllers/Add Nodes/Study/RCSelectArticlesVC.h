//
//  RCSelectArticlesVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCSelectArticlesVC : UITableViewController
@property (strong, nonatomic) NSString *typeFilter;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) NSMutableArray *selection;
@property (strong, nonatomic) NSArray *articles;

@end
