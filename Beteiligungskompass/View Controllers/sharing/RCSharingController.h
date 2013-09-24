//
//  RCSharingController.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface RCSharingController : NSObject <UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) NSURL *url;

+ (RCSharingController *)instance;

- (void)shareURL:(NSURL *)url from:(UIView *)view;

@end
