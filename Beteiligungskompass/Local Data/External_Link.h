//
//  External_Link.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface External_Link : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * show_link;
@property (nonatomic, retain) NSManagedObject *article;

@end
