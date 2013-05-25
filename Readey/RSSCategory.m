//
//  RSSCategory.m
//  Readey
//
//  Created by David Barkman on 3/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "RSSCategory.h"

@implementation RSSCategory

@synthesize uuid, name;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
		self.uuid = [dictionary objectForKey:@"uuid"];
        self.name = [dictionary objectForKey:@"name"];
    }
    return self;
}

@end
