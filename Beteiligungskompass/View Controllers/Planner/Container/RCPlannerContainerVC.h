//
//  RCPlannerContainerVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCPlannerContainerVC : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sliderBtn;
@property (strong, nonatomic) IBOutlet UIView *leftContainer;
@property (strong, nonatomic) IBOutlet UIView *rightContainer;

@property (strong, nonatomic) UIViewController *leftController;
@property (strong, nonatomic) UIViewController *rightController;

- (IBAction)onSlider:(id)sender;

@end
