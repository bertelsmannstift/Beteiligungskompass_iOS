//
//  NSString+KeychainAdditions.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>


@interface NSString (KeychainAdditions)

// Retrieves a password for the given account name on the given server
// We're using keychains "Internet Password" Type
+ (NSString*) passwordForAccount:(NSString*)account andServer:(NSString*)server;

// stores the receiver as a pssword for the given account on the given server
- (void) storeAsPasswordForAccount:(NSString*)account andServer:(NSString*)server;

// deletes the password for the given account on the given server
+ (void) deletePasswordForAccount:(NSString*)account andServer:(NSString*)server;

@end
