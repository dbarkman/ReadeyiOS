//
//  GoogleReaderClient.m
//  Readey
//
//  Created by David Barkman on 2/4/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderClient.h"
#import "KeychainItemWrapper.h"

@implementation GoogleReaderClient

NSString *source;
NSString *username;
NSString *password;
bool logging;

- (id)init
{
    self = [super init];
    if (self) {
		source = @"RealSimpleApps-Readey-1.0";
		
		KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"GoogleReaderLogin" accessGroup:nil];
		username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
		password = [keychainItem objectForKey:(__bridge id)kSecValueData];
		
		//uncomment these to just test the connection
		username = @"speedreadey@gmail.com";
		password = @"ads0nepa";
		
		//set to true to log events
		logging = true;
    }
    return self;
}

- (NSString *)getAuthToken
{
	NSString *authToken = @"";
	
    NSMutableURLRequest *authReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"]];
    [authReq setTimeoutInterval:30.0];
    [authReq setHTTPMethod:@"POST"];
    [authReq addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *authRequestBody = [[NSString alloc] initWithFormat:@"Email=%@&Passwd=%@&service=reader&accountType=HOSTED_OR_GOOGLE&source=%@", username, password, source];
    [authReq setHTTPBody:[authRequestBody dataUsingEncoding:NSASCIIStringEncoding]];
	
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = nil;
    NSString *responseStr = nil;
    int responseStatus = 0;
    data = [NSURLConnection sendSynchronousRequest:authReq returningResponse:&response error:&error];
	
	if ([data length] > 0) {
        responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        responseStatus = [response statusCode];
		
        if (responseStatus == 200 ) {
			if (logging) NSLog(@"Authentication Successful");
			
			NSArray *responseArray = [responseStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
			NSString *auth = [responseArray objectAtIndex:3];
			NSString *authEncoded1 = [auth stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			NSString *authEncoded2 = [authEncoded1 stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
			authToken = [[NSString alloc]initWithFormat:@"GoogleLogin auth=%@", authEncoded2];
		} else {
			if (logging) NSLog(@"Authentication Failed");
		}
	} else {
		if (logging) NSLog(@"No Auth Data Returned.");
	}
	return authToken;
}

- (NSMutableArray *)getSubscriptionList:(NSString *)authToken
{
	NSMutableArray *subscriptionList = [[NSMutableArray alloc] init];
	NSURL *url = [[NSURL alloc] initWithString:@"https://www.google.com/reader/api/0/subscription/list?output=json"];
	NSMutableURLRequest *subListReq = [[NSMutableURLRequest alloc] initWithURL:url];
	[subListReq setTimeoutInterval:30.0];
	[subListReq setHTTPMethod:@"GET"];
	[subListReq setValue:authToken forHTTPHeaderField:@"Authorization"];
	
	NSHTTPURLResponse *subListResponse = nil;
	NSError *subListError = nil;
	NSData *subListData = nil;
	NSString *subListResponseStr = nil;
	int subListResponseStatus = 0;
	subListData = [NSURLConnection sendSynchronousRequest:subListReq returningResponse:&subListResponse error:&subListError];
	
	if ([subListData length] > 0) {
		subListResponseStr = [[NSString alloc] initWithData:subListData encoding:NSASCIIStringEncoding];
		if (logging) NSLog(@"Response From Google: %@", subListResponseStr);
		
		subListResponseStatus = [subListResponse statusCode];
		
		if (subListResponseStatus == 200 ) {
			if (logging) NSLog(@"Get List Successful");
			
			
			NSDictionary *json = [NSJSONSerialization JSONObjectWithData:subListData options:0 error:nil];
			@try {
				NSArray *subscriptions = [json objectForKey:@"subscriptions"];
				int subCount = [subscriptions count];
				
				for (int i = 0; i < subCount; i++) {
					[subscriptionList addObject:[subscriptions objectAtIndex:i]];
				}
			}
			@catch (NSException *exception) {
				if (logging) NSLog(@"Problem Parsing Data");
			}
			
			
		} else {
			if (logging) NSLog(@"Get List Failed - %d", subListResponseStatus);
		}
	} else {
		if (logging) NSLog(@"No Subscription List Data Returned.");
	}
	return subscriptionList;
}

@end
