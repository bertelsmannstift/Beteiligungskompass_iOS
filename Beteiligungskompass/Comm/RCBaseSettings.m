//
//  RCBaseSettings.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCBaseSettings.h"

static RCBaseSettings *instance;

@implementation RCBaseSettings {
    id _states;
}

- (id)init
{
    self = [super init];
    if (self) {
        _states=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseSettings"];
        if(_states==nil)
        {
            _states=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"basesettings" ofType:@"json"]] options:0 error:nil];
        }
    }
    return self;
}

+ (RCBaseSettings *)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[RCBaseSettings alloc] init];
    });
    return instance;
}

- (BOOL)isModuleEnabled:(NSString *)module
{
    if(_states==nil)return YES;
    return [_states[[@"module." stringByAppendingString:module]] isEqualToString:@"true"];
}

- (void)updateState:(id)state
{
    NSData *encoded=[NSJSONSerialization dataWithJSONObject:state options:0 error:nil];
    [encoded writeToFile:[[NSString cacheDirectory] stringByAppendingPathComponent:@"basesettings.json"] atomically:YES];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:state forKey:@"baseSettings"];
    [defaults synchronize];
    _states=state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModuleStatesChanged" object:self];
}


- (NSString*)sortForType:(NSString *)type
{
    NSString *sort=_states[[@"sort." stringByAppendingString:type]];
    if(sort==nil)
        return @"created";
    return sort;
}

- (id)setting:(NSString*)key
{
    return _states[key];
}

@end
