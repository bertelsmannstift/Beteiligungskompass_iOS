//
//  RCArticleDetailVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

/*
 this class does two things:
 1. it is the base class for all article detail view controller
 2. it is the direct implementation for study articles
 
 it contains a few functions to render HTML based on data structures provided by subclasses
 (see buildContentForFirstColumn and buildContentForSecondColumn)
 */

@interface RCArticleDetailVC : UIViewController<UIWebViewDelegate> {
    BOOL hideOnNextDisappear;
}
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIWebView *firstColumn;
@property (strong, nonatomic) IBOutlet UIWebView *secondColumn;
@property (strong, nonatomic) IBOutlet UIScrollView *container;
@property (strong, nonatomic) IBOutlet UIView *leftButton;
@property (strong, nonatomic) IBOutlet UIView *rightButton;
@property (weak, nonatomic) UITabBarController *refBackup;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) UIPopoverController *popOver;
@property (strong, nonatomic) IBOutlet UIButton *starBtn;

- (IBAction)onBack:(id)sender;
- (IBAction)slide:(id)sender;
- (IBAction)onLeft:(id)sender;
- (IBAction)onRight:(id)sender;
- (IBAction)onShare:(id)sender;
- (IBAction)onFilterCats:(id)sender;

- (NSString*)fetchValueForFieldWithType:(NSString*)type key:(NSString *)key;
- (NSString *)buildContentForFirstColumn;
- (NSArray *)fieldsForFirstColumn;
- (NSArray *)fieldsForSecondColumn;
- (NSString *)renderField:(NSDictionary*)field;

- (NSString *)buildContentForSecondColumn;
- (void)updateContent;

- (IBAction)onSwipeRight:(UISwipeGestureRecognizer*)sender;
- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer*)sender;

@end
