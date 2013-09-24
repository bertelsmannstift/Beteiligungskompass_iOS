//
//  RCStudyStepOneVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCAddNodeContainerViewController.h"

@interface RCStudyStepOneVC : UITableViewController<AddStep>
@property (nonatomic, strong) IBOutletCollection(id) NSArray *controls;

- (NSArray *)mapping;

- (IBAction)onCancel:(id)sender;

@end
