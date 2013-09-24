//
//  RCExpertFavoriteCell.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCExpertCell.h"
#import "RCActionSheetController.h"

@interface RCExpertFavoriteCell : RCExpertCell {
    float x_btn;
    float x_group;
}
@property (strong, nonatomic) IBOutlet UIView *groupArea;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) RCActionSheetController *sheetController;

- (IBAction)onAdd:(id)sender;
- (IBAction)onRemove:(id)sender;

@end
