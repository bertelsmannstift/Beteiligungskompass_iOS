//
//  RCStudyStepThreeVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCStudyStepThreeVC.h"
#import "RCAddNodeContainerViewController.h"
#import "SBJson.h"
#import "RCActionSheetController.h"

@interface RCStudyStepThreeVC ()

@end

@implementation RCStudyStepThreeVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return self.addController.article.images.count+1;
    }
    else if(section==1)
    {
        return [[self.addController.article.external_links_json JSONValue] count]+1;
    }
    else// if(section==2)
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2)
    {
        return [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
    }
    else if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            return [tableView dequeueReusableCellWithIdentifier:@"AddImageCell"];
        }
        else
        {
            int idx=indexPath.row-1;
            Image *img=[[self.addController.article.images sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]] objectAtIndex:idx];
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
            UIImageView *imgView=(UIImageView*)[cell viewWithTag:1];
            imgView.image=[UIImage imageWithData:img.embedded];
            return cell;
        }
    }
    else// if(indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            return [tableView dequeueReusableCellWithIdentifier:@"AddLinkCell"];
        }
        else
        {
            int idx=indexPath.row-1;
            NSString *link=[[self.addController.article.external_links_json JSONValue] objectAtIndex:idx];
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LinkCell"];
            UITextField *textField=(UITextField*)[cell viewWithTag:1];
            textField.delegate=self;
            textField.text=link;
            return cell;
        }
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        int idx=indexPath.row-1;
        Image *image=[self.addController.article.images sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES]]][idx];
        [self.appDelegate.managedObjectContext deleteObject:image];
        [self.appDelegate.managedObjectContext save:nil];
        [self.tableView reloadData];
    }
    else// if(indexPath.section==1)
    {
        int idx=indexPath.row-1;
        NSMutableArray *array=[[self.addController.article.external_links_json JSONValue] mutableCopy];
        [array removeObjectAtIndex:idx];
        self.addController.article.external_links_json=[array JSONRepresentation];
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row>0)
        return 100;
    return 44;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0 && indexPath.section==0)
    {
        void (^showLibrary)()=^{
            UIImagePickerController *pickerController=[[UIImagePickerController alloc] init];
            pickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.delegate=self;
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                UIPopoverController *controller=[[UIPopoverController alloc] initWithContentViewController:pickerController];
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                [controller presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.popover=controller;
            }
            else
            {
                [self presentViewController:pickerController animated:YES completion:nil];
            }
        };
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            RCActionSheetController *ctrl=[[RCActionSheetController alloc] init];
            self.sheetController=ctrl;
            [ctrl addItemWithTitle:RCLocalizedString(@"Foto schießen", @"label.shoot_picture") callback:^{
                UIImagePickerController *pickerController=[[UIImagePickerController alloc] init];
                pickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
                pickerController.delegate=self;
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    UIPopoverController *controller=[[UIPopoverController alloc] initWithContentViewController:pickerController];
                    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                    [controller presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                    self.popover=controller;
                }
                else
                {
                    [self presentViewController:pickerController animated:YES completion:nil];
                }
            }];
            [ctrl addItemWithTitle:RCLocalizedString(@"Foto auswählen", @"label.pick_picture") callback:showLibrary];
            ctrl.sheet=[[UIActionSheet alloc] initWithTitle:RCLocalizedString(@"Fotoquelle auswählen", @"label.select_picture_source")
                                                   delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [ctrl prepareSheet];
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                [ctrl.sheet showFromRect:cell.bounds inView:cell animated:YES];
            }
            else
            {
                [ctrl.sheet showFromTabBar:self.tabBarController.tabBar];
            }
        }
        else
        {
            showLibrary();
        }
        
        
    }
    else if(indexPath.row==0 && indexPath.section==1)
    {
        NSMutableArray *array=[[self.addController.article.external_links_json JSONValue] mutableCopy];
        if(array==nil)
            array=[NSMutableArray array];
        [array addObject:@""];
        self.addController.article.external_links_json=[array JSONRepresentation];
        [self.tableView reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    UIImage *picture=info[UIImagePickerControllerOriginalImage];
    Image *image=[Image createObjectInContext:self.appDelegate.managedObjectContext];
    [self.appDelegate.managedObjectContext assignObject:image toPersistentStore:self.appDelegate.userStore];
    image.embedded=UIImageJPEGRepresentation(picture, 0.9);
    image.order=@(self.addController.article.images.count);
    image.article=self.addController.article;
    [self.appDelegate.managedObjectContext save:nil];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *view=textField.superview;
    UITableViewCell *cell=nil;
    while(![view isKindOfClass:[UITableViewCell class]])
    {
        view=view.superview;
    }
    cell=(UITableViewCell*)view;
    NSIndexPath *path=[self.tableView indexPathForCell:cell];
    int idx=path.row-1;
    NSMutableArray *array=[[self.addController.article.external_links_json JSONValue] mutableCopy];
    array[idx]=textField.text;
    self.addController.article.external_links_json=[array JSONRepresentation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
