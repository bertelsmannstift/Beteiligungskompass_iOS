//
//  RCSlideInVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCSlideInVC : UIViewController {
    BOOL _isSideViewControllerVisible;
    BOOL _onTop;
}
@property (strong, nonatomic) UIViewController *mainViewController;
@property (strong, nonatomic) UIViewController *sideViewController;
@property (readonly,assign) BOOL isSideViewControllerVisible;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *sideView;
@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) UIView *topSeparator;

- (void)slideIn;
- (void)slideOut;
- (void)setShowSideViewControllerOnTop:(BOOL)onTop;

@end


@interface UIViewController (RCSlideInSupport)

@property (nonatomic, readonly) RCSlideInVC *slideViewController;

@end