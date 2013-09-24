//
//  RCPlannerVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCPlannerVC : UITableViewController <UISearchBarDelegate>
@property (strong, nonatomic) NSArray *criteria;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sliderBtn;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIButton *methodsBtn;
@property (weak, nonatomic) IBOutlet UIButton *samplesBtn;

- (IBAction)onSlide:(id)sender;
- (IBAction)onMethods:(id)sender;
- (IBAction)onSamples:(id)sender;

- (void)update;

@end
