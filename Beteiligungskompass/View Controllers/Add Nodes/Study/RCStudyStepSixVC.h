//
//  RCStudyStepSixVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCStudyStepSixVC : UITableViewController
@property (strong, nonatomic) IBOutlet UITableViewCell *storeLocally;
@property (strong, nonatomic) IBOutlet UITableViewCell *publish;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

- (IBAction)deleteArticle:(id)sender;
- (IBAction)saveArticle:(id)sender;

@end
