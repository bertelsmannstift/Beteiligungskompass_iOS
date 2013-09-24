//
//  RCStudyStepThreeVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>
#import "RCActionSheetController.h"

@interface RCStudyStepThreeVC : UITableViewController<UIImagePickerControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) RCActionSheetController *sheetController;

@end
