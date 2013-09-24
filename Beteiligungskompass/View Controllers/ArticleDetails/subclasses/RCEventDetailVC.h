//
//  RCEventDetailVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleDetailVC.h"
#import "RCActionSheetController.h"
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>

@interface RCEventDetailVC : RCArticleDetailVC <EKEventEditViewDelegate>
@property (strong, nonatomic) RCActionSheetController *sheetController;
@property (strong, nonatomic) EKEventEditViewController *calEditor;
@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) EKEvent *event;

- (IBAction)onDetailAction:(id)sender;

@end
