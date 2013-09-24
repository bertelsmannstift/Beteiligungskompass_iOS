//
//  RCNewsStepTwoVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCNewsStepTwoVC.h"

@interface RCNewsStepTwoVC ()

@end

@implementation RCNewsStepTwoVC

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

- (NSArray *)mapping
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"intro",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"text",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            nil];
}

@end
