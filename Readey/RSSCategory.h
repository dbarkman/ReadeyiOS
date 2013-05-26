//
//  RSSCategory.h
//  Readey
//
//  Created by David Barkman on 3/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSCategory : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
