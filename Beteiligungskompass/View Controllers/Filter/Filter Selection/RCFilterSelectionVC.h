//
//  RCFilterSelectionVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCFilterSelectionVC : UITableViewController
@property (strong, nonatomic) id criterion;
@property (strong, nonatomic) NSArray *options;
@property (assign, nonatomic) BOOL planningMode;

@end
