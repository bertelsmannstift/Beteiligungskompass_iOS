//
//  RCDateSelectionVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCDateSelectionVC : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate> {
    
}
@property (nonatomic, strong) NSString *monthKey;
@property (nonatomic, strong) NSString *yearKey;
@property (nonatomic, strong) Article *article;
@property (nonatomic, assign) BOOL showContinuousSwitch;
@property (nonatomic, strong) IBOutlet UIView *continuousSwitch;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic, strong) IBOutlet UISwitch *continuous;
@end
