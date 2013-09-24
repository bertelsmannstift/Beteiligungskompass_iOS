//
//  EWAlertViewDelegate.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "RCAlertViewDelegate.h"

@implementation RCAlertViewDelegate


- (id)init {
    self = [super init];
    if (self) {
        self.handlers=[NSMutableArray array];
    }
    return self;
}

- (void)addButtonWithText:(NSString *)text isCancelButton:(BOOL)isCancel pressedHandler:(void (^)())callback
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:text forKey:@"text"];
    [dict setObject:[NSNumber numberWithBool:isCancel] forKey:@"isCancel"];
    [dict setObject:[callback copy] forKey:@"callback"];
    [self.handlers addObject:dict];
}

- (UIAlertView *)prepareAlertViewWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:nil otherButtonTitles:nil];
    for(int i=0;i<self.handlers.count;i++)
    {
        NSDictionary *dict=[self.handlers objectAtIndex:i];
        [alertView addButtonWithTitle:[dict objectForKey:@"text"]];
        if([[dict objectForKey:@"isCancel"] boolValue])
        {
            alertView.cancelButtonIndex=i;
        }
    }
    return alertView;
}

- (void)runAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView=[self prepareAlertViewWithTitle:title message:message];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSDictionary *dict=[self.handlers objectAtIndex:buttonIndex];
    void (^callback)()=[dict objectForKey:@"callback"];
    callback();
    alertView.delegate=nil;
}

@end
