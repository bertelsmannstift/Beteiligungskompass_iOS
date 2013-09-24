//
//  RCNewsDateSelectionVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCNewsDateSelectionVC : UIViewController
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) IBOutlet UIDatePicker *picker;

@end
