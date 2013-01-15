//
//  Client.m
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "Client.h"

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
	
	UGQuery *query = [[UGQuery alloc] init];
	[query addURLTerm:@"user" equals:userUUID];
	[query addURLTerm:@"ql" equals:@"order by created desc"];
	UGClientResponse *response = [usergridClient getEntities:@"articles" query:query];
	
	NSArray *articles = [response.response objectForKey:@"entities"];
	
	return articles;
}

@end
