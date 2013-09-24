//
//  RCBaseSettings.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>

/*
 This class persists and provides all basic settings. 
 It's updated during import (see /View Controllers/Import/RCImportViewController.h)
*/

@interface RCBaseSettings : NSObject

+ (RCBaseSettings *)instance;

- (void)updateState:(id)state;
- (BOOL)isModuleEnabled:(NSString *)module;
- (NSString*)sortForType:(NSString *)type;
- (id)setting:(NSString*)key;

@end
