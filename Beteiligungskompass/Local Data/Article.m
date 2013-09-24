//
//  Article.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "Article.h"
#import "Article.h"
#import "CriteriaOption.h"


@implementation Article

@dynamic id_from_import;
@dynamic title;
@dynamic deleted;
@dynamic type;
@dynamic country;
@dynamic start_month;
@dynamic start_year;
@dynamic end_month;
@dynamic end_year;
@dynamic short_description;
@dynamic background;
@dynamic aim;
@dynamic process;
@dynamic results;
@dynamic contact;
@dynamic used_for;
@dynamic participants;
@dynamic costs;
@dynamic time_expense;
@dynamic when_to_use;
@dynamic when_not_to_use;
@dynamic strengths;
@dynamic origin;
@dynamic restrictions;
@dynamic author;
@dynamic long_description;
@dynamic answer;
@dynamic author_answer;
@dynamic active;
@dynamic weaknesses;
@dynamic ready_for_publish;
@dynamic question;
@dynamic created;
@dynamic updated;
@dynamic more_information;
@dynamic city;
@dynamic projectstatus;
@dynamic institution;
@dynamic address;
@dynamic lastname;
@dynamic subtitle;
@dynamic intro;
@dynamic text;
@dynamic date;
@dynamic zip;
@dynamic description_institution;
@dynamic firstname;
@dynamic email;
@dynamic phone;
@dynamic fax;
@dynamic short_description_expert;
@dynamic publisher;
@dynamic year;
@dynamic start_date;
@dynamic end_date;
@dynamic deadline;
@dynamic street;
@dynamic street_nr;
@dynamic organized_by;
@dynamic participation;
@dynamic link;
@dynamic contact_person;
@dynamic venue;
@dynamic number_of_participants;
@dynamic fee;
@dynamic sticky;
@dynamic linked_articles;
@dynamic linking_articles;
@dynamic options;
@dynamic fav_marker;
@dynamic originating_user;
@dynamic favorites;
@dynamic external_links;
@dynamic images;
@dynamic videos;
@dynamic files;
@dynamic plaintext;
@dynamic linking_json;
@dynamic criteria_json;
@dynamic is_custom;
@dynamic external_links_json;

- (NSDate *)study_start
{
    NSDateComponents *components=[[NSDateComponents alloc] init];
    [components setYear:[self.start_year longLongValue]];
    [components setMonth:[self.start_month integerValue]];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSNumber *)fav
{
    return [NSNumber numberWithUnsignedLongLong:self.favorites.count];
}

//TODO: here you find all conversion helper methods used by various forms. If it crashes, simply fix here!

- (NSString *)projectduration
{
    if([self.start_month intValue]!=0 && [self.start_year intValue]!=0)
    {
        NSMutableString *string=[NSMutableString string];
        NSArray *months=[NSArray arrayWithObjects:
                         RCLocalizedString(@"Januar", @"label.january"),
                         RCLocalizedString(@"Februar",@"label.feburary"),
                         RCLocalizedString(@"März",@"label.march"),
                         RCLocalizedString(@"April", @"label.april"),
                         RCLocalizedString(@"Mai", @"label.mai"),
                         RCLocalizedString(@"Juni", @"label.june"),
                         RCLocalizedString(@"Juli", @"label.july"),
                         RCLocalizedString(@"August", @"label.august"),
                         RCLocalizedString(@"September", @"label.september"),
                         RCLocalizedString(@"Oktober", @"label.october"),
                         RCLocalizedString(@"November", @"label.november"),
                         RCLocalizedString(@"Dezember", @"label.december"),
                         nil];
        [string appendFormat:@"%@ %d",[months objectAtIndex:[self.start_month intValue]-1],[self.start_year intValue]];
        if([self.end_month intValue]!=0 && [self.end_year intValue]!=0)
        {
            [string appendFormat:@" - %@ %d",[months objectAtIndex:[self.end_month intValue]-1],[self.end_year intValue]];
        }
        return string;
    }
    else if([self.start_year intValue]!=0 && [self.end_year intValue]!=0)
        return [NSString stringWithFormat: @"%d - %d",[self.start_year intValue],[self.end_year intValue]];
    else if ([self.start_year intValue]!=0)
        return [NSString stringWithFormat: @"%@ %d", RCLocalizedString(@"seit", @"global.since"), [self.start_year intValue]];
    
    return nil;

}

- (NSString*)projectstart
{    
    if([self.start_month intValue]!=0 && [self.start_year intValue]!=0)
    {
        NSMutableString *string=[NSMutableString string];
        NSArray *months=[NSArray arrayWithObjects:
                         RCLocalizedString(@"Januar", @"label.january"),
                         RCLocalizedString(@"Februar",@"label.feburary"),
                         RCLocalizedString(@"März",@"label.march"),
                         RCLocalizedString(@"April", @"label.april"),
                         RCLocalizedString(@"Mai", @"label.mai"),
                         RCLocalizedString(@"Juni", @"label.june"),
                         RCLocalizedString(@"Juli", @"label.july"),
                         RCLocalizedString(@"August", @"label.august"),
                         RCLocalizedString(@"September", @"label.september"),
                         RCLocalizedString(@"Oktober", @"label.october"),
                         RCLocalizedString(@"November", @"label.november"),
                         RCLocalizedString(@"Dezember", @"label.december"),
                         nil];
        [string appendFormat:@"%@ %d",[months objectAtIndex:[self.start_month intValue]-1],[self.start_year intValue]];
        return string;
    }
    else if([self.start_year intValue]!=0)
        return [NSString stringWithFormat: @"%d", [self.start_year intValue]];
    
    return nil;
}

- (NSString *)projectend
{
    if([self.end_month intValue]!=0 && [self.end_year intValue]!=0)
    {
        NSMutableString *string=[NSMutableString string];
        NSArray *months=[NSArray arrayWithObjects:
                         RCLocalizedString(@"Januar", @"label.january"),
                         RCLocalizedString(@"Februar",@"label.feburary"),
                         RCLocalizedString(@"März",@"label.march"),
                         RCLocalizedString(@"April", @"label.april"),
                         RCLocalizedString(@"Mai", @"label.mai"),
                         RCLocalizedString(@"Juni", @"label.june"),
                         RCLocalizedString(@"Juli", @"label.july"),
                         RCLocalizedString(@"August", @"label.august"),
                         RCLocalizedString(@"September", @"label.september"),
                         RCLocalizedString(@"Oktober", @"label.october"),
                         RCLocalizedString(@"November", @"label.november"),
                         RCLocalizedString(@"Dezember", @"label.december"),
                         nil];
        [string appendFormat:@"%@ %d",[months objectAtIndex:[self.end_month intValue]-1],[self.end_year intValue]];
        return string;
    }
    else if([self.end_year intValue]!=0)
        return [NSString stringWithFormat: @"%d", [self.end_year intValue]];
    
    return RCLocalizedString(@"andauernd", @"global.ongoing");
}

- (NSString*)printableName
{
    if([self.type isEqualToString:@"expert"])
    {
        NSMutableString *title=[NSMutableString string];
        BOOL separatorNeeded=NO;
        if(self.firstname!=nil && self.firstname.length>0)
        {
            [title appendString:self.firstname];
            [title appendString:@" "];
            [title appendString:self.title];
            separatorNeeded=YES;
        }
        if(self.institution!=nil && self.institution.length>0)
        {
            if(separatorNeeded)
                [title appendString:@", "];
            [title appendString:self.institution];
        }
        return title;
    }
    else
        return self.title;

}

- (NSString *)news_date
{
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
    [fmt setDateStyle:NSDateFormatterShortStyle];
    [fmt setTimeStyle:NSDateFormatterNoStyle];
    return [fmt stringFromDate:self.date];
}

- (NSString *)event_startdate
{
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
    [fmt setDateStyle:NSDateFormatterShortStyle];
    [fmt setTimeStyle:NSDateFormatterNoStyle];
    return [fmt stringFromDate:self.start_date];
}

- (NSString *)event_enddate
{
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
    [fmt setDateStyle:NSDateFormatterShortStyle];
    [fmt setTimeStyle:NSDateFormatterNoStyle];
    return [fmt stringFromDate:self.end_date];
}

- (NSString *)event_deadline
{
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
    [fmt setDateStyle:NSDateFormatterShortStyle];
    [fmt setTimeStyle:NSDateFormatterNoStyle];
    return [fmt stringFromDate:self.deadline];
}

@end
