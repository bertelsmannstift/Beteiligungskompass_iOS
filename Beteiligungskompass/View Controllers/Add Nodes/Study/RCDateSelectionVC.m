//
//  RCDateSelectionVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCDateSelectionVC.h"

@interface RCDateSelectionVC ()

@end

@implementation RCDateSelectionVC

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.showContinuousSwitch)
        self.continuousSwitch.hidden=NO;
    else
        self.continuousSwitch.hidden=YES;
    if([[self.article valueForKey:self.monthKey] intValue]==0)
    {
        self.continuous.on=YES;
    }
    [self.picker reloadAllComponents];
    if([[self.article valueForKey:self.yearKey] intValue]!=0)
        [self.picker selectRow:[[self.article valueForKey:self.monthKey] intValue]-1 inComponent:0 animated:NO];
    if([[self.article valueForKey:self.yearKey] intValue]!=0)
        [self.picker selectRow:[[self.article valueForKey:self.yearKey] intValue]-1962 inComponent:1 animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.continuous.on && self.showContinuousSwitch)
    {
        [self.article setValue:[NSNumber numberWithInt:0] forKey:self.monthKey];
        [self.article setValue:[NSNumber numberWithInt:0] forKey:self.yearKey];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component==0)
        return 12;
    else
        return 70;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component==0)
    {
        NSArray *months=[NSArray arrayWithObjects:
                         RCLocalizedString(@"Januar", @"label.january"),
                         RCLocalizedString(@"Februar",@"label.february"),
                         RCLocalizedString(@"März",@"label.march"),
                         RCLocalizedString(@"April", @"label.april"),
                         RCLocalizedString(@"Mai", @"label.mai"),
                         RCLocalizedString(@"Juni", @"label.june"),
                         RCLocalizedString(@"Juli", @"label.july"),
                         RCLocalizedString(@"August", @"label.august"),
                         RCLocalizedString(@"September", @"label.september"),
                         RCLocalizedString(@"Oktober", @"label.october"),
                         RCLocalizedString(@"November", @"label.november"),
                         RCLocalizedString(@"Dezember", @"label.december"),
                         nil];
        return [months objectAtIndex:row];
    }
    else
    {
        int val=1962+row;
        return [NSString stringWithFormat:@"%d",val];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component==0)
    {
        [self.article setValue:[NSNumber numberWithInt:row+1] forKey:self.monthKey];
    }
    else if(component==1)
    {
        [self.article setValue:[NSNumber numberWithInt:1962+row] forKey:self.yearKey];
    }
}

@end
