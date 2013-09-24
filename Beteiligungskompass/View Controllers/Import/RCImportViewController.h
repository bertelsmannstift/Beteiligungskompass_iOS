//
//  RCImportViewController.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>


/*
 This class performs the data import. The import is divided into serveral phases:
 
 1. download sql file
 2. download thumbnails zip
 3. extract thumbnails to temporary directory
 4. import data from sql file
 5. replace current thumbnails with new thumbnails
 6. update module configuration, basesettings and file hashes
 
 the first two steps are implemented in performSync
 the third,fourth and fifth steps are implemented in import
 and the sixth step is done with a block at the end of import.
 
 optionally, if the user is logged in, the favorites are synced between the fifth and the sixth step.
 */

@interface RCImportViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *context;

+ (void)syncFavoritesAndCall:(void (^)())callback;
- (IBAction)cancelImport:(id)sender;

@end
