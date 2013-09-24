//
//  Article.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article, CriteriaOption, Favorite_marker,User,External_Link,Image,Video;

@interface Article : NSManagedObject

@property (nonatomic, retain) NSNumber * id_from_import;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * start_month;
@property (nonatomic, retain) NSNumber * start_year;
@property (nonatomic, retain) NSNumber * end_month;
@property (nonatomic, retain) NSNumber * end_year;
@property (nonatomic, retain) NSString * short_description;
@property (nonatomic, retain) NSString * background;
@property (nonatomic, retain) NSString * aim;
@property (nonatomic, retain) NSString * process;
@property (nonatomic, retain) NSString * results;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * used_for;
@property (nonatomic, retain) NSString * participants;
@property (nonatomic, retain) NSString * costs;
@property (nonatomic, retain) NSString * time_expense;
@property (nonatomic, retain) NSString * when_to_use;
@property (nonatomic, retain) NSString * when_not_to_use;
@property (nonatomic, retain) NSString * strengths;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSString * restrictions;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * long_description;
@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSString * author_answer;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * weaknesses;
@property (nonatomic, retain) NSNumber * ready_for_publish;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * more_information;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * projectstatus;
@property (nonatomic, retain) NSString * institution;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * description_institution;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * short_description_expert;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSDate * deadline;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * street_nr;
@property (nonatomic, retain) NSString * organized_by;
@property (nonatomic, retain) NSString * participation;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * contact_person;
@property (nonatomic, retain) NSString * venue;
@property (nonatomic, retain) NSString * number_of_participants;
@property (nonatomic, retain) NSString * fee;
@property (nonatomic, retain) NSDate * sticky;
@property (nonatomic, retain) NSSet *linked_articles;
@property (nonatomic, retain) NSSet *linking_articles;
@property (nonatomic, retain) NSSet *options;
@property (nonatomic, retain) NSSet *fav_marker;
@property (nonatomic, retain) User *originating_user;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSSet *external_links;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *videos;
@property (nonatomic, retain) NSString * plaintext;

@property (nonatomic, readonly) NSString *projectduration;
@property (nonatomic, readonly) NSString *projectstart;
@property (nonatomic, readonly) NSString *projectend;


@property (nonatomic, retain) NSSet *files;

@property (nonatomic, readonly) NSDate *study_start;
@property (nonatomic, readonly) NSNumber *fav;
@property (nonatomic, retain) NSString * linking_json;
@property (nonatomic, readonly) NSString *printableName;
@property (nonatomic, retain) NSString * criteria_json;
@property (nonatomic, retain) NSNumber * is_custom;
@property (nonatomic, readonly) NSString *news_date;
@property (nonatomic, readonly) NSString *event_startdate;
@property (nonatomic, readonly) NSString *event_enddate;
@property (nonatomic, readonly) NSString *event_deadline;
@property (nonatomic, retain) NSString * external_links_json;

@end

@interface Article (CoreDataGeneratedAccessors)

- (void)addFilesObject:(Linked_file *)value;
- (void)removeFilesObject:(Linked_file *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

- (void)addExternal_linksObject:(External_Link *)value;
- (void)removeExternal_linksObject:(External_Link *)value;
- (void)addExternal_links:(NSSet *)values;
- (void)removeExternal_links:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addVideosObject:(Video *)value;
- (void)removeVideosObject:(Video *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

- (void)addFavoritesObject:(Favorite_Entry *)value;
- (void)removeFavoritesObject:(Favorite_Entry *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

- (void)addLinked_articlesObject:(Article *)value;
- (void)removeLinked_articlesObject:(Article *)value;
- (void)addLinked_articles:(NSSet *)values;
- (void)removeLinked_articles:(NSSet *)values;

- (void)addLinking_articlesObject:(Article *)value;
- (void)removeLinking_articlesObject:(Article *)value;
- (void)addLinking_articles:(NSSet *)values;
- (void)removeLinking_articles:(NSSet *)values;

- (void)addOptionsObject:(CriteriaOption *)value;
- (void)removeOptionsObject:(CriteriaOption *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

- (void)addFav_markerObject:(Favorite_marker *)value;
- (void)removeFav_markerObject:(Favorite_marker *)value;
- (void)addFav_marker:(NSSet *)values;
- (void)removeFav_marker:(NSSet *)values;

@end
