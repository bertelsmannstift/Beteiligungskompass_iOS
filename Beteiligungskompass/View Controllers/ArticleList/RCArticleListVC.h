//
//  RCArticleListVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCActionSheetController.h"

@interface RCArticleListVC : UITableViewController <UISearchBarDelegate,UISplitViewControllerDelegate> {
    BOOL hideFilter;

    int studyTotalCache;
    int studyCoundCache;

    int methodsTotalCache;
    int methodsCoundCache;

    int qaTotalCache;
    int qaCoundCache;

    int expertsTotalCache;
    int expertsCoundCache;

    int eventsTotalCache;
    int eventsCoundCache;

    int newsTotalCache;
    int newsCoundCache;
}

@property (nonatomic, strong) IBOutlet UIToolbar *navBtns;
@property (nonatomic, strong) IBOutlet UIToolbar *leftBar;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet RCActionSheetController *sheetController;
@property (nonatomic, strong) UIBarButtonItem *filterBtn;
@property (strong, nonatomic) IBOutlet UIView *EmptyResultLabel;

- (IBAction)onSlideBtn:(id)sender;
- (IBAction)onSort:(id)sender;
- (IBAction)onSwitch:(id)sender;

@end
