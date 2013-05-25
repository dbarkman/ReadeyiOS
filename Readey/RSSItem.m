//
//  RSSItem.m
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "RSSItem.h"

@implementation RSSItem

@synthesize uuid, feedTitle, title, date, alreadyRead, permalink, content, wordCount;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
		self.uuid = [dictionary objectForKey:@"uuid"];
        self.feedTitle = [dictionary objectForKey:@"feedTitle"];
        self.title = [dictionary objectForKey:@"title"];
        self.date = [dictionary objectForKey:@"date"];
		self.alreadyRead = [[dictionary objectForKey:@"alreadyRead"] boolValue];
        self.permalink = [dictionary objectForKey:@"permalink"];
        self.content = [dictionary objectForKey:@"content"];
		self.wordCount = [[dictionary objectForKey:@"wordCount"] floatValue];
    }
    return self;
}

- (void)markAsRead
{
	self.alreadyRead = true;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[RSSItem class]]) {
        return NO;
    }
    
    RSSItem *other = (RSSItem *)object;
	return [other.uuid isEqualToString:self.uuid];
}

@end
