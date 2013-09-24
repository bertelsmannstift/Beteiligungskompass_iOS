//
//  RCDashboardNewsEventsVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCDashboardNewsEventsVC : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *newsResults;
@property (strong, nonatomic) NSFetchedResultsController *eventsResults;
@property (strong, nonatomic) NSArray *sections;

- (IBAction)onHeaderPress:(UITapGestureRecognizer*)sender;

@end
