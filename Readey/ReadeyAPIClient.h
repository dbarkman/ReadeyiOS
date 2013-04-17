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

- (void)requestReturned:(NSArray *)request;

@end

@interface ReadeyAPIClient : NSObject
{
	__weak id <ReadeyClientDelegate> delegate;
	
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
- (void)getItemsForCategory:(NSString *)category;

@end
