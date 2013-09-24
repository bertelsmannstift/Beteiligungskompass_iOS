//
//  RCLoginVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCLoginVC.h"
#import "NSString+KeychainAdditions.h"
#import "RCImportViewController.h"

@interface RCLoginVC () <UITextFieldDelegate>

@end

@implementation RCLoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=RCLocalizedString(@"Anmelden", @"label.login");
    self.navItem.title = self.title;
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onLogin:nil];
    return YES;
}

- (IBAction)onLogin:(id)sender
{
    self.loadingView.hidden=NO;
    [self.userField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.appDelegate.comm performLoginWithEMail:self.userField.text
                                     andPassword:self.passwordField.text
                                        callback:^(id response){
                                            if(response==nil || [response isKindOfClass:[NSError class]])
                                            {
                                                self.loadingView.hidden=YES;
                                                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Anmeldung fehlgeschlagen", @"label.error_login_title")
                                                                                              message:RCLocalizedString(@"Die Anmeldung ist fehlgeschlagen.", @"label.error_login")
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                                                                     otherButtonTitles:nil];
                                                [alert show];
                                                return;
                                            }
                                            NSString *token=[[response objectForKey:@"response"] objectForKey:@"token"];
                                            NSNumber *userId=[[response objectForKey:@"response"] objectForKey:@"userid"];
                                            self.appDelegate.comm.token=token;
                                            [token storeAsPasswordForAccount:self.userField.text andServer: baseurl_without_http];
                                            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                                            [defaults setObject:self.userField.text forKey:@"auth.user"];
                                            [defaults setObject:userId forKey:@"auth.userid"];
                                            [defaults synchronize];
                                            [RCImportViewController syncFavoritesAndCall:^{
                                                if(self.onLogin!=nil)
                                                    self.onLogin(token);
                                                else
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                            }];

                                            
                                        }];
}

- (IBAction)onCancel:(id)sender
{
    if(self.onCancel!=nil)
        self.onCancel();
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}


@end
