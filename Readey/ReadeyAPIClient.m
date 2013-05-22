//
//  ReadeyAPIClient.m
//  Readey
//
//  Created by David Barkman on 4/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyAPIClient.h"
#import <sys/utsname.h>
#import <RestKit/RestKit.h>
#import "MappingProvider.h"

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
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider rssCategoryMapping];
	
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
												responseDescriptorWithMapping:mapping pathPattern:@"/readeyAPI/categories" keyPath:@"data" statusCodes:statusCodeSet];
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/categories?key=%@&uuid=%@&appVersion=%@&device=%@&machine=%@&osVersion=%@",
									   kReadeyAPIURL, kReadeyAPIKey, uuid, appVersion, device, machine, osVersion]];
	
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rssCategories = mappingResult.array;
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:rssCategories];
		}
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
}

- (void)getItemsForCategory:(NSString *)category
{
	NSString *ecodedCategory = [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider rssItemMapping];
	
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
												responseDescriptorWithMapping:mapping pathPattern:@"/readeyAPI/items" keyPath:@"data" statusCodes:statusCodeSet];
	
	NSString *urlString =[NSString stringWithFormat:@"%@/items?category=%@&key=%@&uuid=%@&appVersion=%@&device=%@&machine=%@&osVersion=%@",
						  kReadeyAPIURL, ecodedCategory, kReadeyAPIKey, uuid, appVersion, device, machine, osVersion];
	NSLog(@"URL: %@", urlString);

    NSURL *url = [NSURL URLWithString:urlString];
	
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rssItems = mappingResult.array;
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:rssItems];
		}
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
}

- (void)createFeedback:(NSString *)feedbackType description:(NSString *)description email:(NSString *)email
{
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
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kReadeyAPIURL]];
	[httpClient setParameterEncoding:AFFormURLParameterEncoding];
	NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:path parameters:feedbackDictionary];
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:[[NSArray alloc] initWithObjects:@"true", nil]];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if ([delegate respondsToSelector:@selector(requestReturned:)]) {
			[delegate requestReturned:[[NSArray alloc] initWithObjects:@"false", nil]];
		}
	}];

	[operation start];
}

- (void)createReadLogWithSpeed:(float)speed andWords:(int)words
{
	NSNumber *speedNumber = [NSNumber numberWithFloat:speed];
	NSNumber *wordsNumber = [NSNumber numberWithFloat:words];
	
	NSMutableDictionary *readLogDictionary = [[NSMutableDictionary alloc] init];
	
	[readLogDictionary setObject:kReadeyAPIKey forKey:@"key"];
	[readLogDictionary setObject:uuid forKey:@"uuid"];
	[readLogDictionary setObject:appVersion forKey:@"appVersion"];
	[readLogDictionary setObject:device forKey:@"device"];
	[readLogDictionary setObject:machine forKey:@"machine"];
	[readLogDictionary setObject:osVersion forKey:@"osVersion"];
	[readLogDictionary setObject:speedNumber forKey:@"speed"];
	[readLogDictionary setObject:wordsNumber forKey:@"words"];

	NSString *path =[NSString stringWithFormat:@"%@/readLog", kReadeyAPIURL];

	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kReadeyAPIURL]];
	[httpClient setParameterEncoding:AFFormURLParameterEncoding];
	NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:path parameters:readLogDictionary];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
	
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
