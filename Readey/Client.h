//
//  Client.h
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UGClient.h"
#import "KeychainItemWrapper.h"

@interface Client : NSObject
{
	UGUser *user;
	UGClient *usergridClient;
	KeychainItemWrapper *keychainItem;
}

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

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

- (bool)createFeedback:(NSString *)feedbackType description:(NSString *)description email:(NSString *)email;

@end
