//
//  RCSharingController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCSharingController.h"
#import <Twitter/Twitter.h>

RCSharingController *instance;

@implementation RCSharingController

+ (RCSharingController*)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[RCSharingController alloc] init];
    });
    return instance;
}

- (void)shareURL:(NSURL *)url from:(UIView *)view
{
    self.url=url;
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:RCLocalizedString(@"Teilen", @"share.title")
                                                     delegate:self
                                            cancelButtonTitle:RCLocalizedString(@"Abbruch", @"label.break")
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:RCLocalizedString(@"Twitter", @"label.twitter"),RCLocalizedString(@"E-Mail", @"label.email"),nil];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad && view!=nil)
    {
        [sheet showFromRect:view.bounds inView:view animated:YES];
    }
    else
    {
        [sheet showInView:[UIApplication sharedApplication].keyWindow.subviews[0]];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)//twitter
    {
        TWTweetComposeViewController *ctrl=[[TWTweetComposeViewController alloc] init];
        [ctrl addURL:self.url];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ctrl animated:YES completion:nil];
        
    }
    else if(buttonIndex==1)//email
    {
        MFMailComposeViewController *ctrl=[[MFMailComposeViewController alloc] init];
        [ctrl setMessageBody:[NSString stringWithFormat:@"%@",self.url] isHTML:NO];
        ctrl.mailComposeDelegate=self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ctrl animated:YES completion:nil];
    }
    else if(buttonIndex==2)//cancel
    {
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
