//
//  RCVideoBlockViewController.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCVideoBlockViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIView *preview;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *indexLabel;
@property (nonatomic, strong) IBOutlet UIView *leftBtn;
@property (nonatomic, strong) IBOutlet UIView *rightBtn;
@property (nonatomic, strong) IBOutlet UIWebView *playerView;


@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, assign) int currentIndex;

- (IBAction)onTitle:(id)sender;
- (IBAction)onPrev:(id)sender;
- (IBAction)onNext:(id)sender;

@end
