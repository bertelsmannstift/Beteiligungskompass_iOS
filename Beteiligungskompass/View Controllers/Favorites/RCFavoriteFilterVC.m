//
//  RCFavoriteFilterVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCFavoriteFilterVC.h"
#import "RCFavoritesVC.h"
#import "RCImportViewController.h"
#import "RCModuleManagement.h"

@interface RCFavoriteFilterVC ()

@end

@implementation RCFavoriteFilterVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)keyboardDidShow: (NSNotification *)notification
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [self.tableView numberOfRowsInSection: 2] - 1 inSection: 2]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated: YES];
}   

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.tableView.scrollsToTop=NO;
    }
    self.title=RCLocalizedString(@"Filtern", @"label.filtern");
    [self buildSections];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFavSync:) name:@"FavSyncComplete" object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)onFavSync:(NSNotification *)notification
{
    [self buildSections];
}

- (void)buildSections
{
    self.favoriteGroups=[[Favorite_Group fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];

    NSMutableArray *scratchbook=[NSMutableArray array];
    if(self.parent.showOwnArticles)
    {
        [scratchbook addObjectsFromArray:[Article fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"originating_user.id_from_import=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"auth.userid"]] inContext:self.appDelegate.managedObjectContext]];
    }
    else if(self.parent.showEditing)
    {
        [scratchbook addObjectsFromArray:[Article fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"is_custom==YES"] inContext:self.appDelegate.managedObjectContext]];
    }
    else
    {
        for(Favorite_Entry *entry in [Favorite_Entry fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext])
        {
            if(entry.article!=nil)
                [scratchbook addObject:entry.article];
        }
    }
    [scratchbook sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
    NSMutableDictionary *typeBased=[NSMutableDictionary dictionary];
    for(Article *article in scratchbook)
    {
        NSMutableArray *items=[typeBased objectForKey:article.type];
        if(items==nil)
        {
            items=[NSMutableArray array];
            [typeBased setObject:items forKey:article.type];
        }
        [items addObject:article];
    }
    
    //build sections
    NSMutableArray *sections=[NSMutableArray array];
    NSArray *items=[typeBased objectForKey:@"study"];
    if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"study"])
        [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Projekte", @"module.studies.title"),@"title",@"study",@"type", nil]];
    
    items=[typeBased objectForKey:@"method"];
    if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"method"])
        [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Methoden", @"module.methods.title"),@"title",@"method",@"type", nil]];
    
    items=[typeBased objectForKey:@"qa"];
    if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"qa"])
        [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Praxiswissen", @"module.qa.title"),@"title",@"qa",@"type", nil]];
    
    items=[typeBased objectForKey:@"expert"];
    if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"expert"])
        [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Experten", @"module.experts.title"),@"title",@"expert",@"type", nil]];
    
    items=[typeBased objectForKey:@"event"];
    if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"event"])
        [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"Veranstaltungen", @"module.events.title"),@"title",@"event",@"type", nil]];
    
    items=[typeBased objectForKey:@"news"];
    if(items!=nil && [[RCModuleManagement instance] isModuleEnabled:@"news"])
        [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:items,@"content",RCLocalizedString(@"News", @"module.news.title"),@"title",@"news",@"type", nil]];
    
    self.sections=sections;
    [self.tableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self buildSections];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.parent.showOwnArticles || self.parent.showEditing)
        return 2;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 3;
    else if(section==1)
        return self.sections.count+1;
    else if(section==2)
        return self.favoriteGroups.count+3;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 0.0;
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[[NSBundle mainBundle] loadNibNamed:@"FavoriteFilterSection" owner:self options:nil] lastObject];
    UILabel *label=(UILabel *)[view viewWithTag:1];
    if(section==0)
        return nil;
    else if(section==1)
        label.text=RCLocalizedString(@"Kategorie", @"label.category");
    else if(section==2)
        label.text=RCLocalizedString(@"Favoritengruppen", @"label.favorite_groups");
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2 && indexPath.row==self.favoriteGroups.count+2)
        return 73;
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"allFavoritesCell"];
            if(self.parent.showOwnArticles || self.parent.showEditing)
            {
                cell.accessoryType=UITableViewCellAccessoryNone;
            }
            else
            {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
            return cell;
        }
        else if(indexPath.row==1)
        {
            UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"ownArticlesCell"];
            if(self.parent.showOwnArticles)
            {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType=UITableViewCellAccessoryNone;
            }
            return cell;
        }
        else// if(indexPath.row==2)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"favorite_group"];
            cell.textLabel.text=RCLocalizedString(@"Artikel in Bearbeitung", @"label.article_in_edit_modus");
            if(self.parent.showEditing)
            {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType=UITableViewCellAccessoryNone;
            return cell;
        }
    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"all"];
            if(self.parent.typeFilter==nil)
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType=UITableViewCellAccessoryNone;
            return cell;
        }
        else
        {
            NSString *type=[[self.sections objectAtIndex:indexPath.row-1] objectForKey:@"type"];
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:type];
            if([self.parent.typeFilter isEqualToString:type])
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType=UITableViewCellAccessoryNone;
            return cell;
        }
    }
    else// if(indexPath.section==2)
    {
        if(indexPath.row==0)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"favorite_group"];
            NSArray *items=[Favorite_Entry fetchObjectsWithPredicate:nil inContext:self.appDelegate.managedObjectContext];
            items=[items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                Favorite_Entry *casted=evaluatedObject;
                return [[RCModuleManagement instance] isModuleEnabled:casted.article.type];
            }]];
            cell.textLabel.text=[NSString stringWithFormat:@"%@ (%d)",RCLocalizedString(@"Alle Gruppen", @"label.all_groups"),items.count];
            if(self.parent.favFilter==nil && !self.parent.showNotAssigned)
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType=UITableViewCellAccessoryNone;
            return cell;
        }
        else if(indexPath.row==1)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"favorite_group"];
            NSArray *items=[Favorite_Entry fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"groups.@count==0"] inContext:self.appDelegate.managedObjectContext];
            items=[items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                Favorite_Entry *casted=evaluatedObject;
                return [[RCModuleManagement instance] isModuleEnabled:casted.article.type];
            }]];
            cell.textLabel.text=[NSString stringWithFormat:@"%@ (%d)",RCLocalizedString(@"Nicht zugewiesen", @"favorites.not_assigned"),items.count];
            if(self.parent.showNotAssigned)
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType=UITableViewCellAccessoryNone;
            return cell;
        }
        else
        {
            if(indexPath.row-2==self.favoriteGroups.count)
            {
                return [tableView dequeueReusableCellWithIdentifier:@"add_group"];
            }
            else
            {
                Favorite_Group *group=[self.favoriteGroups objectAtIndex:indexPath.row-2];
                UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"favorite_group"];
                NSArray *items=[group.entries allObjects];
                items=[items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    Favorite_Entry *casted=evaluatedObject;
                    return [[RCModuleManagement instance] isModuleEnabled:casted.article.type];
                }]];
                cell.textLabel.text=[NSString stringWithFormat:@"%@ (%d)",group.title,items.count];
                if(self.parent.favFilter==group)
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType=UITableViewCellAccessoryNone;
                return cell;
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2)
    {
        if(indexPath.row>1 && indexPath.row-2<self.favoriteGroups.count)
        {
            Favorite_Group *group=[self.favoriteGroups objectAtIndex:indexPath.row-2];
            if([group.id_from_import intValue]==0 || self.parent.favFilter==group)return UITableViewCellEditingStyleNone;
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Favorite_Group *group=[self.favoriteGroups objectAtIndex:indexPath.row-2];
    [self.appDelegate.comm removeFavoriteGroup:group.id_from_import andCall:^(id response){
        [self.appDelegate.managedObjectContext deleteObject:group];
        [self.appDelegate.managedObjectContext save:nil];
        [self.parent updateMe];
        [self buildSections];
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Searchfield Cell - Return
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if([cell.reuseIdentifier isEqualToString: @"add_group"])
        return;
    
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            self.parent.showOwnArticles=NO;
            self.parent.showEditing=NO;
        }
        else if(indexPath.row==1)
        {
            self.parent.showOwnArticles=YES;
            self.parent.showEditing=NO;
        }
        else// if(indexPath.row==2)
        {
            self.parent.showOwnArticles=NO;
            self.parent.showEditing=YES;
        }
        [self buildSections];
    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
            self.parent.typeFilter=nil;
        else
            self.parent.typeFilter=[[self.sections objectAtIndex:indexPath.row-1] objectForKey:@"type"];
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
        {
            self.parent.favFilter=nil;
            self.parent.showNotAssigned=NO;
        }
        else if(indexPath.row==1)
        {
            self.parent.favFilter=nil;
            self.parent.showNotAssigned=YES;
        }
        else
        {
            self.parent.favFilter=[self.favoriteGroups objectAtIndex:indexPath.row-2];
            self.parent.showNotAssigned=NO;
        }
    }
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        [self.parent updateMe];
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *string = textField.text;
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *wString = [string stringByTrimmingCharactersInSet: whitespaces];

    if(wString.length > 0)
    {
        textField.enabled=NO;
        
        [self.appDelegate.comm addFavoriteGroup:textField.text andCall:^(id response){
            NSNumber *group_id=[[response objectForKey:@"response"] objectForKey:@"group_id"];
            textField.enabled=YES;
            if(group_id==nil)
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Entfernen nicht möglich", @"label.error_delete_not_possible")
                                                              message:RCLocalizedString(@"Es gab einen Fehler bei der Kommunikation. Bitte versuchen Sie es später erneut", @"label.error_communication")
                                                             delegate:nil cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok") otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [RCImportViewController syncFavoritesAndCall:^{
                    [self buildSections];
                }];
            }
        }];
    }
    
    [textField resignFirstResponder];
    return YES;
}
@end
