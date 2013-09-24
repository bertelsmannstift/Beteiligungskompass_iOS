//
//  NSString+ApplicationDirectory.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>


@interface NSString (ApplicationDirectory)
+ (NSString *) applicationDocumentsDirectory;
+ (NSString *) cacheDirectory;
@end
