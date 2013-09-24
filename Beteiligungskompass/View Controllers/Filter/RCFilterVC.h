//
//  RCFilterVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCFilterVC : UITableViewController <UISearchBarDelegate>
@property (nonatomic, strong) NSArray *criteria;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end
