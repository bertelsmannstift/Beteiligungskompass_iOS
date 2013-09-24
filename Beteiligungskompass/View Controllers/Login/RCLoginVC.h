//
//  RCLoginVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCLoginVC : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *userField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;
@property (copy, nonatomic) void (^onCancel)();
@property (copy, nonatomic) void (^onLogin)(NSString *token);

- (IBAction)onLogin:(id)sender;
- (IBAction)onCancel:(id)sender;

@end
