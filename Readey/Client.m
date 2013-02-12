//
//  Client.m
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "Client.h"
#import "MBP"

@implementation Client

@synthesize usergridClient, user, username, password;

- (id)init
{
    self = [super init];
    if (self) {
        
        //configure the org and app
        NSString * orgName = @"reallysimpleapps";
        NSString * appName = @"readey";
		
        //make new client
        usergridClient = [[UGClient alloc]initWithOrganizationId: orgName withApplicationID: appName];
        [usergridClient setLogging:true]; //uncomment to see debug output in console window
		
		keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ReadeyLogin" accessGroup:nil];
		username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
		password = [keychainItem objectForKey:(__bridge id)kSecValueData];
    }
    return self;
}

- (void)saveLogin
{
	[keychainItem setObject:@"ReadeyLogin" forKey: (__bridge id)kSecAttrService];
	[keychainItem setObject:username forKey:(__bridge id)kSecAttrAccount];
	[keychainItem setObject:password forKey:(__bridge id)kSecValueData];
}

- (void)resetLogin
{
	[keychainItem resetKeychainItem];
	username = @"";
	password = @"";
}

- (NSString *)accessToken
{
	return [usergridClient getAccessToken];
}

- (bool)login
{
    UGClientResponse *response = [usergridClient logInUser:username password:password];
    
    if (response.transactionState == 0) {
        return true;
    } else {
        return false;
    }
}

- (bool)isTokenValid
{
	NSString *orgId = [usergridClient getOrgId];
	NSString *appId = [usergridClient getAppId];
    NSString *token = [usergridClient getAccessToken];
    NSString *uuid = [usergridClient getLoggedInUser].uuid;
	NSString *url = [NSString stringWithFormat:@"http://api.usergrid.com/management/%@/%@/users/%@?access_token=%@", orgId, appId, uuid, token];
    [usergridClient apiRequest:url operation:nil data:nil];
    return true;
}

- (void)logout
{
	[self resetLogin];

	[usergridClient logOut];
}

- (bool)createUser
{
    UGClientResponse *response = [usergridClient addUser:username email:username name:username password:password];
    if (response.transactionState == 0) {
        return [self login];
    }
    return false;
}

- (NSArray *)getArticles
{
    user = [usergridClient getLoggedInUser];
	NSString *userUUID = [user uuid];
	NSString *userQuery = [NSString stringWithFormat:@"select * where user = %@ order by created desc", userUUID];
	
	UGQuery *query = [[UGQuery alloc] init];
	[query addURLTerm:@"ql" equals:userQuery];
	UGClientResponse *response = [usergridClient getEntities:@"articles" query:query];
	
	NSArray *articles;

	switch (response.transactionState) {
		case 0:
			articles = [response.response objectForKey:@"entities"];
			break;
		case 1:
			if ([self login]) {
				UGClientResponse *response = [usergridClient getEntities:@"articles" query:query];
				switch (response.transactionState) {
					case 0:
						articles = [response.response objectForKey:@"entities"];
						break;
					case 1:
						articles = [[NSArray alloc] init];
						[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
						break;
				}
			} else {
				articles = [[NSArray alloc] init];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"shouldLogout"];
			}
			break;
	}
	return articles;
}

- (bool)createArticle:(NSString *)name source:(NSString *)source content:(NSString *)content
{
	NSString *uuid = [user uuid];
	NSMutableDictionary *articleDictionary = [[NSMutableDictionary alloc] init];
	
	[articleDictionary setObject:@"articles" forKey:@"type"];
	[articleDictionary setObject:name forKey:@"name"];
	[articleDictionary setObject:source forKey:@"source"];
	[articleDictionary setObject:content forKey:@"content"];
	[articleDictionary setObject:uuid forKey:@"user"];
	
	UGClientResponse *response = [usergridClient createEntity:articleDictionary];
	
	switch (response.transactionState) {
		case 0:
			return true;
			break;
		case 1:
			if ([self login]) {
				UGClientResponse *response = [usergridClient createEntity:articleDictionary];
				switch (response.transactionState) {
					case 0:
						return true;
						break;
					case 1:
						return false;
						break;
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"shouldLogout"];
				return false;
			}
			break;
	}
	return false;
}

- (bool)removeArticle:(NSString *)uuid
{
	UGClientResponse *response = [usergridClient removeEntity:@"articles" entityID:uuid];
	
	switch (response.transactionState) {
		case 0:
			return true;
			break;
		case 1:
			if ([self login]) {
				UGClientResponse *response = [usergridClient removeEntity:@"articles" entityID:uuid];
				switch (response.transactionState) {
					case 0:
						return true;
						break;
					case 1:
						return false;
						break;
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"shouldLogout"];
				return false;
			}
			break;
	}
	return false;
}

- (bool)createFeedback:(NSString *)feedbackType description:(NSString *)description email:(NSString *)email
{
    user = [usergridClient getLoggedInUser];
	NSString *uuid = [user uuid];
	NSMutableDictionary *feedbackDictionary = [[NSMutableDictionary alloc] init];
	
	[feedbackDictionary setObject:@"feedbacks" forKey:@"type"];
	[feedbackDictionary setObject:feedbackType forKey:@"feedbackType"];
	[feedbackDictionary setObject:description forKey:@"description"];
	[feedbackDictionary setObject:email forKey:@"email"];
	[feedbackDictionary setObject:uuid forKey:@"user"];
	
	UGClientResponse *response = [usergridClient createEntity:feedbackDictionary];
	
	switch (response.transactionState) {
		case 0:
			return true;
			break;
		case 1:
			if ([self login]) {
				UGClientResponse *response = [usergridClient createEntity:feedbackDictionary];
				switch (response.transactionState) {
					case 0:
						return true;
						break;
					case 1:
						return false;
						break;
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"shouldLogout"];
				return false;
			}
			break;
	}
	return false;
}

@end
