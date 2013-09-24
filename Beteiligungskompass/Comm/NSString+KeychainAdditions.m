//
//  NSString+KeychainAdditions.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "NSString+KeychainAdditions.h"


@implementation NSString (KeychainAdditions)
+ (NSString*) passwordForAccount:(NSString*)account andServer:(NSString*)server
{
	// Whatever you want to retrieve from keychain, you always form a query in form of a dictionary
	NSMutableDictionary *queryDict=[[NSMutableDictionary alloc] init];
    
	// first of all we only want items of type Internet Password
	[queryDict setValue:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
	
    // next we only want accounts for a specific server
	[queryDict setValue:server forKey:(__bridge id)kSecAttrServer];
	
    // last but not least we want only a specific account
	[queryDict setValue:account forKey:(__bridge id)kSecAttrAccount];
	
    // we only want to work with one reply.
	[queryDict setValue:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	
    // If you don't set this to true, the keychain will return the item, not the secured data
	[queryDict setValue:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	NSData *password=nil;
    CFTypeRef container=nil;
	
    // This is similar to executeFetchRequest. The result is stored in password.
	SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, &container);
    password=CFBridgingRelease(container);
	if(password==nil)
		return nil;
	
    // It is then converted to an NSString.
	// IMPORTANT: the store Functions save as UTF-8, so this function loads UTF-8
	NSString *result=[[NSString alloc] initWithBytes:[password bytes] length:[password length] encoding:NSUTF8StringEncoding];
	
	return result;
}

- (void) storeAsPasswordForAccount:(NSString*)account andServer:(NSString*)server
{
    // Storing is done the same way. Fill a dictionary.
	NSMutableDictionary *queryDict=[[NSMutableDictionary alloc] init];
	[queryDict setValue:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
	[queryDict setValue:server forKey:(__bridge id)kSecAttrServer];
	[queryDict setValue:account forKey:(__bridge id)kSecAttrAccount];

	// Adding is only possible, if it is not yet in the keychain. So delete this first if nessecary.
	// The dictionary we use to store the data can also be used to delete them.
	if([NSString passwordForAccount:account andServer:server]!=nil)
	{
		/*OSStatus test=*/SecItemDelete((__bridge CFDictionaryRef)queryDict);
	}
	
    // Convert the password to an NSData object
	const char *buf=[self cStringUsingEncoding:NSUTF8StringEncoding];
	int len=[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData *d=[NSData dataWithBytesNoCopy:(char*)buf length:len freeWhenDone:NO];
	[queryDict setValue:d forKey:(__bridge id)kSecValueData];
	CFTypeRef result=NULL;

	// Last but not least fire it off to keychain
	/*OSStatus returnvalues=*/SecItemAdd((__bridge CFDictionaryRef)queryDict, &result);
}

+ (void) deletePasswordForAccount:(NSString*)account andServer:(NSString*)server
{
    
	NSMutableDictionary *queryDict=[[NSMutableDictionary alloc] init];
    
	// All we need to delete are those properties which identify the object:
    // Type (internet password), username and server
	[queryDict setValue:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
	[queryDict setValue:server forKey:(__bridge id)kSecAttrServer];
	[queryDict setValue:account forKey:(__bridge id)kSecAttrAccount];
	// Fire off the delete command
	/*OSStatus test=*/SecItemDelete((__bridge CFDictionaryRef)queryDict);
	
}

@end
