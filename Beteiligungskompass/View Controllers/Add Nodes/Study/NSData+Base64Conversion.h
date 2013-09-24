//
//  NSData+Base64Conversion.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
#import <UIKit/UIKit.h>

@interface NSData (Base64Conversion)
-(NSString *) EncodeUsingBase64;
+(NSData *) dataFromBase64:(NSString*) data;
-(NSString *) EncodeUsingHex;

@end
