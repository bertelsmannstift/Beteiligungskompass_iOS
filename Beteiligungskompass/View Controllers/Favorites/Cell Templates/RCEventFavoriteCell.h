//
//  RCEventFavoriteCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCEventCell.h"
#import "RCActionSheetController.h"

@interface RCEventFavoriteCell : RCEventCell {
    float x_btn;
    float x_group;
}
@property (strong, nonatomic) IBOutlet UIView *groupArea;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) RCActionSheetController *sheetController;

- (IBAction)onAdd:(id)sender;
- (IBAction)onRemove:(id)sender;

@end
