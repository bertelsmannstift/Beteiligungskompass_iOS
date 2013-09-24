//
//  RCModuleManagement.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCModuleManagement.h"

static RCModuleManagement *instance;

@implementation RCModuleManagement {
    id _states;
}

- (id)init
{
    self = [super init];
    if (self) {
        _states=[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_modules"];
        if(_states==nil)
        {
            _states=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"modules" ofType:@"json"]] options:0 error:nil];
        }
    }
    return self;
}

+ (RCModuleManagement*)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[RCModuleManagement alloc] init];
    });
    return instance;
}

- (BOOL)isModuleEnabled:(NSString *)module
{
    if(_states==nil)return YES;
    return [_states[[@"show_" stringByAppendingString:module]] intValue]==1;
}

- (void)updateModuleState:(id)states
{
    NSData *encoded=[NSJSONSerialization dataWithJSONObject:states options:0 error:nil];
    [encoded writeToFile:[[NSString cacheDirectory] stringByAppendingPathComponent:@"modules.json"] atomically:YES];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:states forKey:@"enabled_modules"];
    [defaults synchronize];
    _states=states;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModuleStatesChanged" object:self];
}

@end
