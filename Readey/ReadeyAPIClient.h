//
//  ReadeyAPIClient.h
//  Readey
//
//  Created by David Barkman on 4/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@protocol ReadeyClientDelegate <NSObject>

- (void)requestReturned:(NSDictionary *)request;

@end

@interface ReadeyAPIClient : NSObject
{
	bool logging;
	KeychainItemWrapper *keychainItem;
	NSString *uuid;
	
	NSString *osVersion;
	NSString *device;
	NSString *machine;
	
	NSDictionary *infoDictionary;
    NSString *majorVersion;
    NSString *minorVersion;
    NSString *appVersion;
}

@property (nonatomic, weak)id <ReadeyClientDelegate> delegate;

@property (nonatomic, strong) NSArray *rssCategories;
@property (nonatomic, strong) NSArray *rssItems;

- (void)getCategories;
- (void)getItemsForCategory:(NSString *)category onPage:(int)page;
- (void)createFeedback:(NSString *)feedbackType description:(NSString *)description email:(NSString *)email;
- (void)createReadLogWithSpeed:(float)speed andWords:(int)words forRssItem:(NSString *)rssItemUuid;

//future
- (void)saveLogin;
- (void)resetLogin;
- (NSString *)accessToken;
- (bool)login;
- (bool)isTokenValid;
- (void)logout;

- (bool)createUser;

- (bool)createArticle:(NSString *)name source:(NSString *)source content:(NSString *)content;
- (NSArray *)getArticles;
- (bool)removeArticle:(NSString *)uuid;

@end
