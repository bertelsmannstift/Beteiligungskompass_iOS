//
//  RCModuleManagement.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>

/*
 This class persists and provides information about enabled modules.
 It's updated during import (see /View Controllers/Import/RCImportViewController.h)
*/

@interface RCModuleManagement : NSObject

+ (RCModuleManagement*)instance;

- (BOOL)isModuleEnabled:(NSString *)module;
- (void)updateModuleState:(id)states;

@end
