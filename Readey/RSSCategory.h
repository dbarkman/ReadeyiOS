//
//  RSSCategory.h
//  Readey
//
//  Created by David Barkman on 3/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSCategory : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
