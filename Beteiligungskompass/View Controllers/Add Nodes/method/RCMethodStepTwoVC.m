//
//  RCMethodStepTwoVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCMethodStepTwoVC.h"

@interface RCMethodStepTwoVC ()

@end

@implementation RCMethodStepTwoVC

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

- (NSArray*)mapping
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"used_for",@"key",[NSNumber numberWithInt:0],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"participants",@"key",[NSNumber numberWithInt:1],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"costs",@"key",[NSNumber numberWithInt:2],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"time_expense",@"key",[NSNumber numberWithInt:3],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"when_to_use",@"key",[NSNumber numberWithInt:4],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"when_not_to_use",@"key",[NSNumber numberWithInt:5],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"strengths",@"key",[NSNumber numberWithInt:6],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"weaknesses",@"key",[NSNumber numberWithInt:7],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"origin",@"key",[NSNumber numberWithInt:8],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"restrictions",@"key",[NSNumber numberWithInt:9],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact",@"key",[NSNumber numberWithInt:10],@"tag",[NSNumber numberWithBool:NO],@"readonly", nil],
            nil];

}

@end
