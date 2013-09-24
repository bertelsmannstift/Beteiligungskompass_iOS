//
//  EWAlertViewDelegate.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>

@interface RCAlertViewDelegate : NSObject<UIAlertViewDelegate> {
}
@property (nonatomic, retain) NSMutableArray *handlers;

- (void)addButtonWithText:(NSString *)text isCancelButton:(BOOL)isCancel pressedHandler:(void (^)())callback;

- (void)runAlertViewWithTitle:(NSString *)title message:(NSString *)message;
- (UIAlertView *)prepareAlertViewWithTitle:(NSString*)title message:(NSString*)message;

@end
