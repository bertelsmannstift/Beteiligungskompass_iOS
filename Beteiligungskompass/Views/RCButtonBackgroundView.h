//
//  RCButtonBackgroundView.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCButtonBackgroundView : UIView
@property (strong, nonatomic) IBOutlet UIView *normalView;
@property (strong, nonatomic) IBOutlet UIView *pressedView;

- (IBAction)onPress:(id)sender;
- (IBAction)onUnpress:(id)sender;

@end
