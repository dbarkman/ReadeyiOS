//
//  ReadeyAPIClient.m
//  Readey
//
//  Created by David Barkman on 4/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyAPIClient.h"
#import <sys/utsname.h>

@implementation ReadeyAPIClient

@synthesize delegate;
@synthesize rssCategories, rssItems;

- (id)init
{
	self = [super init];
	if (self) {
		keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ReadeyAPIClientUUID" accessGroup:nil];
		uuid = [keychainItem objectForKey:(__bridge id)kSecAttrComment];
		if ([uuid length] == 0) {
			uuid = [self generateUUID];
			[keychainItem setObject:uuid forKey:(__bridge id)kSecAttrComment];
		}
		
		logging = true;
		[self getDeviceData];
	}
	return self;
}

- (NSString *)generateUUID
{
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuidString = CFUUIDCreateString(NULL, uuidRef);
	NSString *returnString = (__bridge NSString *)uuidString;
	if (logging) NSLog(@"UUID: %@", returnString);
	return returnString;
}

- (void)getDeviceData
{
	osVersion = [[[UIDevice currentDevice] systemVersion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	device = [[[UIDevice currentDevice] model] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	machine = [self getMachineName];
	
	infoDictionary = [[NSBundle mainBundle] infoDictionary];
    majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    appVersion = [NSString stringWithFormat:@"%@.%@", majorVersion, minorVersion];
}

- (NSString *)getMachineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)getCategories
{
	[Flurry logEvent:@"Get Categories" timed:YES];
	
	NSString *url = [NSString stringWithFormat:
		@"%@/categories?key=%@&uuid=%@&appVersion=%@&device=%@&machine=%@&osVersion=%@",
		kReadeyAPIURL, kReadeyAPIKey, uuid, appVersion, device, machine, osVersion];
	[self makeApiGetCallWithUrl:url];
}

- (void)getItemsForCategory:(NSString *)category onPage:(int)page
{
	[Flurry logEvent:@"Get Items" timed:YES];
	
	NSString *encodedCategory = [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *url = [NSString stringWithFormat:
		@"%@/items?category=%@&key=%@&uuid=%@&appVersion=%@&device=%@&machine=%@&osVersion=%@&page=%d",
		kReadeyAPIURL, encodedCategory, kReadeyAPIKey, uuid, appVersion, device, machine, osVersion, page];
	
	[self makeApiGetCallWithUrl:url];
}

- (void)makeApiGetCallWithUrl:(NSString *)urlString
{
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSLog(@"responseObject %@", responseObject);
		[Flurry logEvent:@"GET Call Succeeded"];
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:responseObject];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[Flurry logEvent:@"GET Call Failed"];
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:false];
		}
	}];
	
    [operation start];
}

- (void)createFeedback:(NSString *)feedbackType description:(NSString *)description email:(NSString *)email
{
	[Flurry logEvent:@"POST Feedback" timed:YES];
	
	NSMutableDictionary *feedbackDictionary = [[NSMutableDictionary alloc] init];
	
	[feedbackDictionary setObject:kReadeyAPIKey forKey:@"key"];
	[feedbackDictionary setObject:uuid forKey:@"uuid"];
	[feedbackDictionary setObject:appVersion forKey:@"appVersion"];
	[feedbackDictionary setObject:device forKey:@"device"];
	[feedbackDictionary setObject:machine forKey:@"machine"];
	[feedbackDictionary setObject:osVersion forKey:@"osVersion"];
	[feedbackDictionary setObject:feedbackType forKey:@"feedbackType"];
	[feedbackDictionary setObject:description forKey:@"description"];
	[feedbackDictionary setObject:email forKey:@"email"];
	
	NSString *path =[NSString stringWithFormat:@"%@/feedback", kReadeyAPIURL];
	
	[self makeApiPostCallWithPath:path andParameters:feedbackDictionary];
}

- (void)createReadLogWithSpeed:(float)speed andWords:(int)words forRssItem:(NSString *)rssItemUuid withCategory:category
{
	[Flurry logEvent:@"POST ReadLog" timed:YES];

	NSNumber *speedNumber = [NSNumber numberWithFloat:speed];
	NSNumber *wordsNumber = [NSNumber numberWithFloat:words];
	
	NSMutableDictionary *readLogDictionary = [[NSMutableDictionary alloc] init];
	
	[readLogDictionary setObject:kReadeyAPIKey forKey:@"key"];
	[readLogDictionary setObject:uuid forKey:@"uuid"];
	[readLogDictionary setObject:appVersion forKey:@"appVersion"];
	[readLogDictionary setObject:device forKey:@"device"];
	[readLogDictionary setObject:machine forKey:@"machine"];
	[readLogDictionary setObject:osVersion forKey:@"osVersion"];
	[readLogDictionary setObject:rssItemUuid forKey:@"rssItemUuid"];
	[readLogDictionary setObject:category forKey:@"rssCategory"];
	[readLogDictionary setObject:speedNumber forKey:@"speed"];
	[readLogDictionary setObject:wordsNumber forKey:@"words"];

	NSString *path =[NSString stringWithFormat:@"%@/readLog", kReadeyAPIURL];

	[self makeApiPostCallWithPath:path andParameters:readLogDictionary];
}

- (void)makeApiPostCallWithPath:(NSString *)path andParameters:(NSDictionary *)parameters
{
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kReadeyAPIURL]];
	[httpClient setParameterEncoding:AFFormURLParameterEncoding];
	NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:path parameters:parameters];
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
		[Flurry logEvent:@"POST Call Succeeded"];
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:[NSDictionary dictionary]];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[Flurry logEvent:@"POST Call Failed"];
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:false];
		}
	}];
	
	[operation start];
}

- (bool)createArticle:(NSString *)name source:(NSString *)source content:(NSString *)content
{
	NSLog(@"Placeholding");
	return false;
}

- (NSArray *)getArticles
{
	NSLog(@"Placeholding");
	NSArray *tempArray = [[NSArray alloc] init];
	return tempArray;
}

- (bool)removeArticle:(NSString *)uuid
{
	NSLog(@"Placeholding");
	return false;
}

- (void)saveLogin
{
	NSLog(@"Placeholding");
}

- (void)resetLogin
{
	NSLog(@"Placeholding");
}

- (NSString *)accessToken
{
	NSLog(@"Placeholding");
	return @"";
}

- (bool)login
{
	NSLog(@"Placeholding");
	return false;
}

- (bool)isTokenValid
{
	NSLog(@"Placeholding");
	return false;
}

- (void)logout
{
	NSLog(@"Placeholding");
}

- (bool)createUser
{
	NSLog(@"Placeholding");
	return false;
}

@end
