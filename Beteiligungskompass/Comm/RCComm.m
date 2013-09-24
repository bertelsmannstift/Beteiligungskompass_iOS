//
//  RCComm.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCComm.h"
#import "NSString+KeychainAdditions.h"
#import "SBJSON.h"

@implementation RCComm
@synthesize token;

- (id)init
{
    self = [super init];
    if (self) {
        NSString *username=[[NSUserDefaults standardUserDefaults] stringForKey:@"auth.user"];
        if(username!=nil)
        {
            self.token=[NSString passwordForAccount:username andServer: baseurl_without_http];
        }
        self.queue=[[NSOperationQueue alloc] init];
    }
    return self;
}

- (BOOL) isAuthenticated
{
    return (self.token!=nil);
}

#pragma mark -
#pragma mark Request setup

- (NSURL*)urlForCall:(NSString*)call andParams:(NSDictionary *)params
{
    NSMutableString *query=[NSMutableString stringWithString:API_KEY];
    if(self.isAuthenticated)
    {
        [query appendFormat:@"&token=%@",self.token];
    }
    for(NSString *key in [params allKeys])
    {
        [query appendFormat:@"&%@=%@",key,[[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@api/%@%@",baseurl,call,query]];
}

#pragma mark -
#pragma mark API Methods

- (void)performLoginWithEMail:(NSString *)email andPassword:(NSString *)password callback:(void (^)(id))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"login" andParams:[NSDictionary dictionaryWithObjectsAndKeys:email,@"email",password,@"password", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSHTTPURLResponse *casted=(NSHTTPURLResponse*)response;
            if(casted.statusCode==200)
            {
                NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                id result=[content JSONValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(result);
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(nil);
                });
            }
        }
    }];
}

- (void)performGetFavoritesAndCall:(void (^)(id))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_favorites" andParams:[NSDictionary dictionaryWithObject:self.token forKey:@"token"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)performGetTermsAndCall:(void (^)(NSString *response)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_terms" andParams:[NSDictionary dictionary]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id elem=[content JSONValue];
            content=[[elem objectForKey:@"response"] objectForKey:@"pagecontent"];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(content);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)getExportAndCall:(void (^)(NSData *data)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"export" andParams:[NSDictionary dictionary]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error || ((NSHTTPURLResponse *)response).statusCode!=200)
                callback(nil);
            else
                callback(data);
        });
    }];
}

- (void)getHashesAndCall:(void (^)(id response))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_file_hashes" andParams:[NSDictionary dictionary]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error || ((NSHTTPURLResponse *)response).statusCode!=200)
                callback(nil);
            else
            {
                NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                id result = [content JSONValue];
                callback(result);
            }
        });
    }];
}

- (void)getThumbnailsAndCall:(void (^)(NSData *data)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_thumbnails" andParams:[NSDictionary dictionary]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error || ((NSHTTPURLResponse *)response).statusCode!=200)
                callback(nil);
            else
                callback(data);
        });
    }];
}


- (void)addFavorite:(NSNumber *)articleid andCall:(void (^)(id response))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"add_favorite" andParams:[NSDictionary dictionaryWithObjectsAndKeys:[articleid stringValue],@"article_id", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)removeFavorite:(NSNumber *)articleid andCall:(void (^)(id response)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"remove_favorite" andParams:[NSDictionary dictionaryWithObjectsAndKeys:[articleid stringValue],@"article_id", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)addFavoriteGroup:(NSString *)name andCall:(void (^)(id response)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"add_favorite_group" andParams:[NSDictionary dictionaryWithObjectsAndKeys:name,@"title", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)removeFavoriteGroup:(NSNumber *)groupId andCall:(void (^)(id response)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"remove_favorite_group" andParams:[NSDictionary dictionaryWithObjectsAndKeys:[groupId stringValue],@"group_id", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)addArticle:(NSNumber *)article toGroup:(NSNumber *)group andCall:(void (^)(id response)) callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"add_article_to_favorite_group" andParams:[NSDictionary dictionaryWithObjectsAndKeys:[group stringValue],@"group_id",[article stringValue],@"article_id", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)removeArticle:(NSNumber *)article fromGroup:(NSNumber *)group andCall:(void (^)(id response))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"remove_article_from_favorite_group" andParams:[NSDictionary dictionaryWithObjectsAndKeys:[article stringValue],@"article_id",[group stringValue],@"group_id", nil]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result = [content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)uploadArticle:(NSString *)json onFinished:(void (^)(BOOL done))callback
{
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[self urlForCall:@"add_article" andParams:[NSDictionary dictionary]]];
    request.HTTPMethod=@"POST";
    request.HTTPBody=[json dataUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data,NSError *error){
        NSHTTPURLResponse *httpresponse=(NSHTTPURLResponse*)response;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback([httpresponse statusCode]==200);
        });
    }];
}

- (void)getStringsAndCall:(void (^)(id response))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_strings" andParams:@{}]];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
        else if(data)
        {
            NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            id result=[content JSONValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)getStaticPageAndCall:(void (^)(NSString *))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_static_page" andParams:@{}] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
        if(data!=nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *staticPage=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                id decoded=[staticPage JSONValue];
                staticPage=decoded[@"response"][@"content"];
                callback(staticPage);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)getModuleStateAndCall:(void (^)(id result))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_module_state" andParams:@{}] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *err){
        if(data!=nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                id decoded=[content JSONValue];
                callback(decoded[@"response"]);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

- (void)getBaseConfigAndCall:(void(^)(id result))callback
{
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[self urlForCall:@"get_base_config" andParams:@{}] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *err){
        if(data!=nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *content=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                id decoded=[content JSONValue];
                callback(decoded[@"response"]);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

@end
