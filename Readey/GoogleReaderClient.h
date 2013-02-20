//
//  GoogleReaderClient.h
//  Readey
//
//  Created by David Barkman on 2/4/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@interface GoogleReaderClient : NSObject
{
	bool logging;
	bool logResponses;
	NSString *source;
	NSString *username;
	NSString *password;
	NSString *authToken;
	NSDate *authTokenDate;
	KeychainItemWrapper *keychainItem;
}

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (void)saveLogin;
- (void)resetLogin;
- (bool)login;
- (void)logout;
- (bool)isLoggedIn;
- (NSString *)getAuthToken;
- (NSMutableArray *)getSubscriptionList:(NSString *)authToken;
- (NSMutableArray *)getSubscriptionFeed:(NSString *)authToken fromFeed:(NSString *)feed;

@end
