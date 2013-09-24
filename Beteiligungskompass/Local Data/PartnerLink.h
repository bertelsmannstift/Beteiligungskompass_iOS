//
//  PartnerLink.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PartnerLink : NSManagedObject

@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;

@end
