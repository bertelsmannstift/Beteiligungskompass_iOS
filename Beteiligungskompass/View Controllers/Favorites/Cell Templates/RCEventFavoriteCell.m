//
//  RCEventFavoriteCell.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCEventFavoriteCell.h"

@implementation RCEventFavoriteCell

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
    __weak RCEventFavoriteCell *me=self;
    
    for(Favorite_Group *group in [Favorite_Group fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext])
    {
        if([group.id_from_import intValue]!=0 && ![entry.groups containsObject:group])
        {
            [self.sheetController addItemWithTitle:group.title callback:^{
                RCEventFavoriteCell *myself=me;
                [myself.appDelegate.comm addArticle:myself.article.id_from_import toGroup:group.id_from_import andCall:^(id response){
                    RCEventFavoriteCell *myinnerself=me;
                    [entry addGroupsObject:group];
                    [myinnerself.appDelegate.managedObjectContext save:nil];
                    [me fill];
                }];
            }];
        }
    }
    self.sheetController.onCancel=^{
        RCEventFavoriteCell *myself=me;
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
