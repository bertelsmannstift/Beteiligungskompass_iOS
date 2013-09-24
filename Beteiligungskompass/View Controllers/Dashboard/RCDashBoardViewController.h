//
//  RCDashBoardViewController.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <UIKit/UIKit.h>

@interface RCDashBoardViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *headerBlock;
@property (strong, nonatomic) IBOutlet UIView *auxiliaryBlock;
@property (strong, nonatomic) IBOutlet UIView *footerBlock;
@property (strong, nonatomic) IBOutlet UIWebView *firstPartner;
@property (strong, nonatomic) IBOutlet UIWebView *secondPartner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onProjects:(id)sender;
- (IBAction)onMethods:(id)sender;
- (IBAction)onQA:(id)sender;
- (IBAction)onExperts:(id)sender;
- (IBAction)onEvents:(id)sender;
- (IBAction)onNews:(id)sender;
- (IBAction)onPlan:(id)sender;
- (IBAction)onSlide:(id)sender;
- (IBAction)onBasics:(id)sender;

@end
