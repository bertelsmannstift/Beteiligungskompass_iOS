//
//  EWActionSheetController.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "RCActionSheetController.h"

@implementation RCActionSheetItem
@synthesize text = _text;
@synthesize onPressed = _onPressed;


@end

@implementation RCActionSheetController
@synthesize items = _items;
@synthesize sheet = _sheet;


- (id)init {
    self = [super init];
    if (self) {
        self.items=[NSMutableArray array];
    }
    return self;
}

- (void)addItemWithTitle:(NSString *)title callback:(void (^)())callback
{
    RCActionSheetItem *item=[[RCActionSheetItem alloc] init];
    item.text=title;
    item.onPressed=callback;
    [self.items addObject:item];
}

- (void)prepareSheet
{
    for(RCActionSheetItem *item in self.items)
    {
        [self.sheet addButtonWithTitle:item.text];
    }
    int idx=[self.sheet addButtonWithTitle:RCLocalizedString(@"Abbruch", @"label.break")];
    self.sheet.cancelButtonIndex=idx;
    self.sheet.delegate=self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==self.items.count)
    {
        self.onCancel();
        return;
    }
    RCActionSheetItem *item=[self.items objectAtIndex:buttonIndex];
    item.onPressed();
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    self.onCancel();
}

- (void)dealloc
{
    self.sheet.delegate=nil;
}

@end
