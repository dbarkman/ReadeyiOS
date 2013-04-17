//
//  MappingProvider.m
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "MappingProvider.h"
#import "RSSCategory.h"
#import "RSSItem.h"

@implementation MappingProvider

+ (RKMapping *)rssCategoryMapping
{
	RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RSSCategory class]];
	[mapping addAttributeMappingsFromArray:@[@"name"]];
	return mapping;
}

+ (RKMapping *)rssItemMapping
{
	RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RSSItem class]];
	[mapping addAttributeMappingsFromArray:@[@"feedTitle", @"title", @"date", @"permalink", @"content", @"wordCount"]];
	return mapping;
}

@end
