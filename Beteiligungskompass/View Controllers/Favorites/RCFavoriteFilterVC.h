//
//  RCFavoriteFilterVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

/*
 This class provides the favorites side list with all filter options.
 there is some communication going on between these two view controllers (RCFavoritesVC and RCFavoriteFilterVC)
 */
@class  RCFavoritesVC;

@interface RCFavoriteFilterVC : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) RCFavoritesVC *parent;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *favoriteGroups;

- (void)buildSections;

@end
