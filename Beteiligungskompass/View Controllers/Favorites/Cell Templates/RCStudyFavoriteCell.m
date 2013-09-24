//
//  RCArticleFavoriteCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCStudyFavoriteCell.h"
#import "RCImportViewController.h"

@implementation RCStudyFavoriteCell {
    RCAlertViewDelegate *alertViewDelegate;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)fill
{
    [super fill];
    NSNumber *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"auth.userid"];
    if(userId==nil)
    {
        self.authorImage.hidden=YES;
        self.addBtn.hidden=NO;
        self.favButton.hidden=NO;
    }
    else if([self.article.originating_user.id_from_import isEqualToNumber:userId])
    {
        self.authorImage.hidden=NO;
        self.addBtn.hidden=YES;
        self.favButton.hidden=YES;
    }
    else
    {
        self.authorImage.hidden=YES;
        self.addBtn.hidden=NO;
        self.favButton.hidden=NO;
    }
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        if(self.thumbnail.image==nil)
        {
            CGRect frame=self.groupArea.frame;
            frame.origin.x = 5;
            frame.size.width = self.frame.size.width - 85;
            self.groupArea.frame = frame;
        }
    }
    for(UIView *view in [[self.groupArea subviews] copy])
    {
        [view removeFromSuperview];
    }
    Favorite_Entry *entry=[self.article.favorites anyObject];
    if(entry!=nil)
    {
        if(entry.groups.count > 0)
        { 
            UILabel *label= [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 85, 30)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize: 13];
            label.text = [NSString stringWithFormat: @"%@:", RCLocalizedString(@"Sammlung", @"label.group")];
            [self. groupArea addSubview: label];
        }
        
        int x=90;
        for(Favorite_Group *group in entry.groups)
        {
            UIView *view=[[[NSBundle mainBundle] loadNibNamed:@"FavoriteElement" owner:self options:nil] objectAtIndex:0];
            UILabel *label=[view.subviews objectAtIndex:0];
            label.text=group.title;
            CGSize size=[label.text sizeWithFont:label.font];
            size.width+=46;
            CGRect frame=view.frame;
            frame.origin.x=x;
            frame.size.width=size.width;
            x+=frame.size.width;
            view.frame=frame;
            
            UIButton *button=[view.subviews objectAtIndex:1];
            button.tag=[group.id_from_import intValue];
            [self.groupArea addSubview:view];
        }
    }
}

- (void)onAdd:(UIView*)sender
{
    if(self.sheetController!=nil)
    {
        [self.sheetController.sheet dismissWithClickedButtonIndex:0 animated:YES];
        self.sheetController=nil;
        return;
    }
    self.sheetController=[[RCActionSheetController alloc] init];
    Favorite_Entry *entry=[self.article.favorites anyObject];
    __weak RCStudyFavoriteCell *me=self;

    for(Favorite_Group *group in [Favorite_Group fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext])
    {
        if([group.id_from_import intValue]!=0 && ![entry.groups containsObject:group])
        {
            [self.sheetController addItemWithTitle:group.title callback:^{
                RCStudyFavoriteCell *myself=me;
                [myself.appDelegate.comm addArticle:myself.article.id_from_import toGroup:group.id_from_import andCall:^(id response){
                    RCStudyFavoriteCell *myinnerself=me;
                    [entry addGroupsObject:group];
                    [myinnerself.appDelegate.managedObjectContext save:nil];
                    [me fill];
                }];
            }];
        }
    }
    [self.sheetController addItemWithTitle:RCLocalizedString(@"Neue Gruppe", @"label.favorites.addgroup.new") callback:^{
        RCStudyFavoriteCell *myself=me;
        myself->alertViewDelegate=[[RCAlertViewDelegate alloc] init];
        __block UIAlertView *alertView=nil;
        [myself->alertViewDelegate addButtonWithText:RCLocalizedString(@"OK", @"label.favorites.addgroup.new.OK") isCancelButton:NO pressedHandler:^{
            //we have to save here
            NSString *groupName=[alertView textFieldAtIndex:0].text;
            RCStudyFavoriteCell *myself=me;
            [myself.appDelegate.comm addFavoriteGroup:groupName andCall:^(id response) {
                NSNumber *group_id=[[response objectForKey:@"response"] objectForKey:@"group_id"];
                if(group_id!=nil)
                {
                    [myself.appDelegate.comm addArticle:myself.article.id_from_import toGroup:group_id andCall:^(id response) {
                        [RCImportViewController syncFavoritesAndCall:^{
                            [me fill];
                        }];
                    }];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Entfernen nicht möglich", @"label.error_delete_not_possible")
                                                                  message:RCLocalizedString(@"Es gab einen Fehler bei der Kommunikation. Bitte versuchen Sie es später erneut", @"label.error_communication")
                                                                 delegate:nil cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok") otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }];
        [myself->alertViewDelegate addButtonWithText:RCLocalizedString(@"Abbruch", @"label.favorites.addgroup.new.Cancel") isCancelButton:YES pressedHandler:^{
            //do ... ah well: nothing :)
        }];
        alertView=[myself->alertViewDelegate prepareAlertViewWithTitle:RCLocalizedString(@"Neue Gruppe", @"label.favorites.addgroup.new.title") message:nil];
        alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
        [alertView show];
    }];
    self.sheetController.onCancel=^{
        RCStudyFavoriteCell *myself=me;
        myself.sheetController=nil;
    };
    
    self.sheetController.sheet=[[UIActionSheet alloc] initWithTitle:RCLocalizedString(@"Zur Gruppe hinzufügen", @"label.add_to_group")
                                                           delegate:self.sheetController
                                                  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self.sheetController prepareSheet];
    [self.sheetController.sheet showFromRect:sender.bounds inView:sender animated:YES];
}

- (void)onRemove:(UIView*)sender
{
    int tag=sender.tag;
    if(tag!=0)
    {
        Favorite_Entry *entry=[self.article.favorites anyObject];

        Favorite_Group *group=[[Favorite_Group fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"id_from_import=%d",tag] inContext:self.appDelegate.managedObjectContext] lastObject];
        [self.appDelegate.comm removeArticle:self.article.id_from_import fromGroup:group.id_from_import andCall:^(id response){
            [entry removeGroupsObject:group];
            [self.appDelegate.managedObjectContext save:nil];
            [self fill];
        }];
    }
}

@end
