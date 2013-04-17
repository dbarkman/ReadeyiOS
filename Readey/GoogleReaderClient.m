//
//  GoogleReaderClient.m
//  Readey
//
//  Created by David Barkman on 2/4/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderClient.h"

@implementation GoogleReaderClient

@synthesize username, password;

- (id)init
{
    self = [super init];
    if (self) {
		source = @"RealSimpleApps-Readey-1.0";
		
		keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"GoogleReaderLogin" accessGroup:nil];
		username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
		password = [keychainItem objectForKey:(__bridge id)kSecValueData];
		authToken = [keychainItem objectForKey:(__bridge id)kSecAttrComment];
		authTokenDate = [NSDate dateWithTimeIntervalSince1970:[[keychainItem objectForKey:(__bridge id)kSecAttrService] doubleValue]];
		
		//set to true to log events
		logging = false;
		logResponses = false;
    }
    return self;
}

- (void)saveLogin
{
	[keychainItem setObject:@"GoogleReaderLogin" forKey: (__bridge id)kSecAttrService];
	[keychainItem setObject:username forKey:(__bridge id)kSecAttrAccount];
	[keychainItem setObject:password forKey:(__bridge id)kSecValueData];
}

- (void)resetLogin
{
	[keychainItem resetKeychainItem];
	username = @"";
	password = @"";
	authToken = @"";
	authTokenDate = nil;
}

- (bool)login
{
	authToken = [self getAuthToken];
	if (authToken.length > 0) {
		[self saveLogin];
		return true;
	}
	return false;
}

- (void)logout
{
    [self resetLogin];
}

- (bool)isLoggedIn
{
	if (username.length > 0 && password.length > 0) {
		return true;
	}
	return false;
}

- (NSString *)getAuthToken
{
	authTokenDate = [NSDate dateWithTimeIntervalSince1970:[[keychainItem objectForKey:(__bridge id)kSecAttrService] doubleValue]];
	NSDate *now = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]];
	if ([now timeIntervalSinceDate:authTokenDate] < 3600) {
		if (logging) NSLog(@"Authtoken Still Valid");
		authToken = [keychainItem objectForKey:(__bridge id)kSecAttrComment];
	} else {
		if (logging) NSLog(@"Retrieving New Authtoken");
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
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[Flurry logEvent:@"Google Reader Authentication" timed:YES];
		data = [NSURLConnection sendSynchronousRequest:authReq returningResponse:&response error:&error];
		[Flurry endTimedEvent:@"Google Reader Authentication" withParameters:nil];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		if ([data length] > 0) {
			responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			if (logResponses) NSLog(@"Response From Google: %@", responseStr);
			
			responseStatus = [response statusCode];
			
			if (responseStatus == 200 ) {
				if (logging) NSLog(@"Authentication Successful");
				
				NSArray *responseArray = [responseStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
				NSString *auth = [responseArray objectAtIndex:3];
				NSString *authEncoded1 = [auth stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
				NSString *authEncoded2 = [authEncoded1 stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
				authToken = [[NSString alloc]initWithFormat:@"GoogleLogin auth=%@", authEncoded2];
				
				NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
				[keychainItem setObject:[NSString stringWithFormat:@"%d", (int)timeStamp] forKey:(__bridge id)kSecAttrService];
				[keychainItem setObject:authToken forKey:(__bridge id)kSecAttrComment];
			} else {
				if (logging) NSLog(@"Authentication Failed");
				
				NSArray *responseLines  = [responseStr componentsSeparatedByString:@"\n"];
				NSString *errorString;
				NSString *authMessage = @"No Auth Message Provided";
				
				int i;
				for (i =0; i < [responseLines count]; i++ ) {
					if ([[responseLines objectAtIndex:i] rangeOfString:@"Error="].length != 0) {
						errorString = [responseLines objectAtIndex:i] ;
					}
				}
				
				errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				/*
				 Official Google clientLogin Error Codes:
				 Error Code Description
				 BadAuthentication  The login request used a username or password that is not recognized.
				 NotVerified    The account email address has not been verified. The user will need to access their Google account directly to resolve the issue before logging in using a non-Google application.
				 TermsNotAgreed The user has not agreed to terms. The user will need to access their Google account directly to resolve the issue before logging in using a non-Google application.
				 CaptchaRequired    A CAPTCHA is required. (A response with this error code will also contain an image URL and a CAPTCHA token.)
				 Unknown    The error is unknown or unspecified; the request contained invalid input or was malformed.
				 AccountDeleted The user account has been deleted.
				 AccountDisabled    The user account has been disabled.
				 ServiceDisabled    The user's access to the specified service has been disabled. (The user account may still be valid.)
				 ServiceUnavailable The service is not available; try again later.
				 */
				
				if ([errorString  rangeOfString:@"BadAuthentication" ].length != 0) {
					authMessage = @"Please Check your Username and Password and try again.";
				}else if ([errorString  rangeOfString:@"NotVerified"].length != 0) {
					authMessage = @"This account has not been verified. You will need to access your Google account directly to resolve this";
				}else if ([errorString  rangeOfString:@"TermsNotAgreed" ].length != 0) {
					authMessage = @"You have not agreed to Google terms of use. You will need to access your Google account directly to resolve this";
				}else if ([errorString  rangeOfString:@"CaptchaRequired" ].length != 0) {
					authMessage = @"Google is requiring a CAPTCHA response to continue. Please complete the CAPTCHA challenge in your browser, and try authenticating again";
				}else if ([errorString  rangeOfString:@"Unknown" ].length != 0) {
					authMessage = @"An Unknow error has occurred; the request contained invalid input or was malformed.";
				}else if ([errorString  rangeOfString:@"AccountDeleted" ].length != 0) {
					authMessage = @"This user account previously has been deleted.";
				}else if ([errorString  rangeOfString:@"AccountDisabled" ].length != 0) {
					authMessage = @"This user account has been disabled.";
				}else if ([errorString  rangeOfString:@"ServiceDisabled" ].length != 0) {
					authMessage = @"Your access to the specified service has been disabled. Please try again later.";
				}else if ([errorString  rangeOfString:@"ServiceUnavailable" ].length != 0) {
					authMessage = @"The service is not available; please try again later.";
				}
				if (logging) NSLog(@"%@", authMessage);
				NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:authMessage, @"authMessage", nil];
				[Flurry logEvent:@"Google Reader Auth Failed" withParameters:flurryParams];
			}
		} else {
			if (logging) NSLog(@"No Auth Data Returned");
			[Flurry logEvent:@"No Google Reader Auth Data Returned"];
		}
	}

	return authToken;
}

- (NSMutableArray *)getSubscriptionList:(NSString *)sentAuthToken
{
	NSMutableArray *subscriptionList = [[NSMutableArray alloc] init];
	NSURL *url = [[NSURL alloc] initWithString:@"https://www.google.com/reader/api/0/subscription/list?output=json"];
	NSMutableURLRequest *subListReq = [[NSMutableURLRequest alloc] initWithURL:url];
	[subListReq setTimeoutInterval:30.0];
	[subListReq setHTTPMethod:@"GET"];
	[subListReq setValue:sentAuthToken forHTTPHeaderField:@"Authorization"];
	
	NSHTTPURLResponse *subListResponse = nil;
	NSError *subListError = nil;
	NSData *subListData = nil;
	NSString *subListResponseStr = nil;
	int subListResponseStatus = 0;

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[Flurry logEvent:@"Google Reader Get Subscription List" timed:YES];
	subListData = [NSURLConnection sendSynchronousRequest:subListReq returningResponse:&subListResponse error:&subListError];
	[Flurry endTimedEvent:@"Google Reader Get Subscription List" withParameters:nil];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([subListData length] > 0) {
		subListResponseStr = [[NSString alloc] initWithData:subListData encoding:NSASCIIStringEncoding];
		if (logResponses) NSLog(@"Response From Google: %@", subListResponseStr);
		
		subListResponseStatus = [subListResponse statusCode];
		
		if (subListResponseStatus == 200) {
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
				if (logging) NSLog(@"Problem Parsing List Data");
			}
			
			
		} else {
			if (logging) NSLog(@"Get List Failed - %d", subListResponseStatus);
			[Flurry logEvent:@"Google Reader Get Subscription List Failed"];
		}
	} else {
		if (logging) NSLog(@"No Subscription List Data Returned");
		[Flurry logEvent:@"No Google Reader Subscription List Data Returned"];
	}
	return subscriptionList;
}

- (NSMutableArray *)getSubscriptionFeed:(NSString *)sentAuthToken fromFeed:(NSString *)feed
{
	NSMutableArray *subscriptionFeed = [[NSMutableArray alloc] init];
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://www.google.com/reader/api/0/stream/contents/%@?output=json&n=20", feed]];
	NSMutableURLRequest *subFeedReq = [[NSMutableURLRequest alloc] initWithURL:url];
	[subFeedReq setTimeoutInterval:30.0];
	[subFeedReq setHTTPMethod:@"GET"];
	[subFeedReq setValue:sentAuthToken forHTTPHeaderField:@"Authorization"];
	
	NSHTTPURLResponse *subFeedResponse = nil;
	NSError *subFeedError = nil;
	NSData *subFeedData = nil;
	NSString *subFeedResponseStr = nil;
	int subFeedResponseStatus = 0;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[Flurry logEvent:@"Google Reader Get Subscription Feed" timed:YES];
	subFeedData = [NSURLConnection sendSynchronousRequest:subFeedReq returningResponse:&subFeedResponse error:&subFeedError];
	[Flurry endTimedEvent:@"Google Reader Get Subscription Feed" withParameters:nil];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([subFeedData length] > 0) {
		subFeedResponseStr = [[NSString alloc] initWithData:subFeedData encoding:NSASCIIStringEncoding];
		if (logResponses) NSLog(@"Response From Google: %@", subFeedResponseStr);
		
		subFeedResponseStatus = [subFeedResponse statusCode];
		
		if (subFeedResponseStatus == 200 ) {
			if (logging) NSLog(@"Get Feeds Successful");
			
			
			NSDictionary *json = [NSJSONSerialization JSONObjectWithData:subFeedData options:0 error:nil];
			@try {
				NSArray *items = [json objectForKey:@"items"];
				int itemCount = [items count];
				
				for (int i = 0; i < itemCount; i++) {
					[subscriptionFeed addObject:[items objectAtIndex:i]];
				}
			}
			@catch (NSException *exception) {
				if (logging) NSLog(@"Problem Parsing Feed Data");
			}
			
			
		} else {
			if (logging) NSLog(@"Get Feeds Failed - %d", subFeedResponseStatus);
			[Flurry logEvent:@"Google Reader Get Subscription Feeds Failed"];
		}
	} else {
		if (logging) NSLog(@"No Subscription Feed Data Returned");
		[Flurry logEvent:@"No Google Reader Subscription Feed Data Returned"];
	}
	return subscriptionFeed;
}

@end
