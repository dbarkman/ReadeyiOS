//
//  RSSItem.h
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSItem : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *feedTitle;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *date;
@property (nonatomic) Boolean *alreadyRead;
@property (strong, nonatomic) NSString *permalink;
@property (strong, nonatomic) NSString *content;
@property (nonatomic) float wordCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)markAsRead;

@end
