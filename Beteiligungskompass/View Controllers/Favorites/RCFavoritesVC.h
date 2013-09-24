//
//  RCFavoritesVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

/*
 This View Controller contains the article list of items, which are on the favorite list.
 */

@interface RCFavoritesVC : UITableViewController <UISplitViewControllerDelegate> {
    BOOL hideFilder;
}

@property (strong, nonatomic) Favorite_Group *favFilter;
@property (strong, nonatomic) NSString *typeFilter;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) NSMutableIndexSet *expandedSections;
@property (assign, nonatomic) BOOL showOwnArticles;
@property (assign, nonatomic) BOOL showNotAssigned;
@property (assign, nonatomic) BOOL showEditing;

- (IBAction)onSlide:(id)sender;
- (void)updateMe;

@end
