//
//  RCArticleSideVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCArticleSideVC : UITableViewController
@property (strong, nonatomic) IBOutlet UILabel *studyLabel;
@property (strong, nonatomic) IBOutlet UILabel *methodsLabel;
@property (strong, nonatomic) IBOutlet UILabel *qaLabel;
@property (strong, nonatomic) IBOutlet UILabel *expertsLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *newsLabel;
@property (strong, nonatomic) IBOutlet UILabel *addLabel;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) Article *currentArticle;
@property (strong, nonatomic) IBOutlet UITableViewCell *logOnCell;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (IBAction)onResetFilter:(id)sender;
- (void)setArticles:(NSArray *)articles forType:(NSString*)type;

@end
