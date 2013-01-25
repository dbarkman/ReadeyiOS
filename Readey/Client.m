//
//  Client.m
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "Client.h"
#import "KeychainItemWrapper.h"

@implementation Client

@synthesize usergridClient, user;

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
    }
    return self;
}

- (bool)login:(NSString*)username withPassword:(NSString*)password
{
    [usergridClient logInUser:username password:password];
    user = [usergridClient getLoggedInUser];
    
    if (user.username){
        return true;
    } else {
        return false;
    }
}

- (void)logout
{
	[usergridClient logOut];
}

- (bool)createUser:(NSString*)username
         withName:(NSString*)name
        withEmail:(NSString*)email
     withPassword:(NSString*)password
{
    UGClientResponse *response = [usergridClient addUser:username email:email name:name password:password];
    if (response.transactionState == 0) {
        return [self login:username withPassword:password];
    }
    return false;
}

- (NSArray *)getArticles
{
	NSString *userUUID = [user uuid];
	NSString *userQuery = [NSString stringWithFormat:@"select * where user = %@ order by created desc", userUUID];
	
	UGQuery *query = [[UGQuery alloc] init];
	[query addURLTerm:@"ql" equals:userQuery];
	UGClientResponse *response = [usergridClient getEntities:@"articles" query:query];
	
	NSArray *articles;
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ReaderAppLogin" accessGroup:nil];
	NSString *username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
	NSString *password = [keychainItem objectForKey:(__bridge id)kSecValueData];
	username = @"abc";
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithCapacity:1];

	switch (response.transactionState) {
		case 0:
			articles = [response.response objectForKey:@"entities"];
			break;
		case 1:
			if ([self login:username withPassword:password]) {
				UGClientResponse *response = [usergridClient getEntities:@"articles" query:query];
				switch (response.transactionState) {
					case 0:
						articles = [response.response objectForKey:@"entities"];
						break;
					case 1:
						[tempDict setObject:@"logout" forKey:@"name"];
						articles = [[NSArray alloc] initWithObjects:tempDict, nil];
						break;
				}
			} else {
				[tempDict setObject:@"logout" forKey:@"name"];
				articles = [[NSArray alloc] initWithObjects:tempDict, nil];
			}
			break;
	}

	return articles;
}

@end
