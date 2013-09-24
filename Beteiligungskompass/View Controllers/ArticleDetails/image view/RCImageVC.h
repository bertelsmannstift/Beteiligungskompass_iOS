//
//  RCImageVC.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCImageVC : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *imageView;
@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) int currentImage;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)onLeft:(id)sender;
- (IBAction)onRight:(id)sender;

@end
