//
//  RSSItem.h
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSItem : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *feedTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *date;
@property (nonatomic) Boolean *alreadyRead;
@property (nonatomic, strong) NSString *permalink;
@property (nonatomic, strong) NSString *content;
@property (nonatomic) float wordCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)markAsRead;

@end
