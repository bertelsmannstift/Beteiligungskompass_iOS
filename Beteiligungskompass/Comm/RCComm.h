//
//  RCComm.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>

/*
 This class contains methods for all needed and defined API calls and handles the basic request setup.
 The result is only parsed on a low level (e.g. NSData to NSString and interpreted as JSON).
 */

@interface RCComm : NSObject
@property (assign, nonatomic) BOOL isAuthenticated;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSOperationQueue *queue;

- (void)performLoginWithEMail:(NSString *)email andPassword:(NSString *)password callback:(void (^)(id response)) callback;
- (void)performGetFavoritesAndCall:(void (^)(id response)) callback;
- (void)getExportAndCall:(void (^)(NSData *data)) callback;
- (void)getThumbnailsAndCall:(void (^)(NSData *data)) callback;
- (void)performGetTermsAndCall:(void (^)(NSString *response)) callback;
- (void)getHashesAndCall:(void (^)(id response))callback;
- (void)addFavorite:(NSNumber *)articleid andCall:(void (^)(id response))callback;
- (void)removeFavorite:(NSNumber *)articleid andCall:(void (^)(id response)) callback;
- (void)addFavoriteGroup:(NSString *)name andCall:(void (^)(id response)) callback;
- (void)removeFavoriteGroup:(NSNumber *)groupId andCall:(void (^)(id response)) callback;
- (void)addArticle:(NSNumber *)article toGroup:(NSNumber *)group andCall:(void (^)(id response)) callback;
- (void)removeArticle:(NSNumber *)article fromGroup:(NSNumber *)group andCall:(void (^)(id response))callback;
- (void)uploadArticle:(NSString *)json onFinished:(void (^)(BOOL done))callback;
- (void)getStringsAndCall:(void (^)(id response))callback;
- (void)getStaticPageAndCall:(void (^)(NSString *response))callback;
- (void)getModuleStateAndCall:(void (^)(id result))callback;
- (void)getBaseConfigAndCall:(void(^)(id result))callback;

@end
