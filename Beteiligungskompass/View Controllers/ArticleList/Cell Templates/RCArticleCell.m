//
//  RCArticleCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleCell.h"

@implementation RCArticleCell
@synthesize article=_article;
@synthesize authorImage=_authorImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fill
{
    NSNumber *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"auth.userid"];
    if(userId==nil)
        self.authorImage.hidden=YES;
    else if([self.article.originating_user.id_from_import isEqualToNumber:userId])
    {
        self.authorImage.hidden=NO;
    }
    else
    {
        self.authorImage.hidden=YES;
    }
    
    if(self.article.favorites.count>0)
    {
        [self.favButton setImage:[UIImage imageNamed:@"icon_tapbar_fav_oranje.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.favButton setImage:[UIImage imageNamed:@"icon_tapbar_fav_blue.png"] forState:UIControlStateNormal];
        
    }
}

- (void)onFav:(id)sender
{
    if(self.appDelegate.comm.isAuthenticated)
    {
        if(self.article.favorites.count>0)
        {
            [self.appDelegate.comm removeFavorite:self.article.id_from_import andCall:^(id response){
                BOOL success=[response isKindOfClass:[NSDictionary class]] && [[[response objectForKey:@"response"] objectForKey:@"success"] boolValue];
                if(success)
                {
                    for(NSManagedObject *obj in [self.article.favorites copy])
                    {
                        [self.appDelegate.managedObjectContext deleteObject:obj];
                    }
                    [self.appDelegate.managedObjectContext save:nil];
                    [self fill];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Entfernen nicht möglich", @"label.error_delete_not_possible")
                                                                  message:RCLocalizedString(@"Es gab einen Fehler bei der Kommunikation. Bitte versuchen Sie es später erneut", @"label.error_communication")
                                                                 delegate:nil cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                                        otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        else
        {
            [self.appDelegate.comm addFavorite:self.article.id_from_import andCall:^(id response){
                BOOL success=[response isKindOfClass:[NSDictionary class]] && [[[response objectForKey:@"response"] objectForKey:@"success"] boolValue];
                if(success)
                {
                    Favorite_Entry *entry=[Favorite_Entry createObjectInContext:self.appDelegate.managedObjectContext];
                    [self.appDelegate.managedObjectContext assignObject:entry toPersistentStore:self.appDelegate.globalStore];
                    entry.article=self.article;
                    [self.appDelegate.managedObjectContext save:nil];
                    [self fill];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Hinzufügen nicht möglich", @"label.error_add_not_possible")
                                                                  message:RCLocalizedString(@"Es gab einen Fehler bei der Kommunikation. Bitte versuchen Sie es später erneut", @"label.error_communication")
                                                                 delegate:nil cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok")
                                                        otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
    }
    else
    {
        UIViewController *ctrl=[self.appDelegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self.appDelegate.window.rootViewController presentViewController:ctrl animated:YES completion:nil];
    }
}

@end
