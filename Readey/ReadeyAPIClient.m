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
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/categories?key=%@&appVersion=%@&device=%@&machine=%@&osVersion=%@",
									   kReadeyAPIURL, kReadeyAPIKey, appVersion, device, machine, osVersion]];
	
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
	
	NSString *urlString =[NSString stringWithFormat:@"%@/items?category=%@&key=%@&appVersion=%@&device=%@&machine=%@&osVersion=%@",
						  kReadeyAPIURL, ecodedCategory, kReadeyAPIKey, appVersion, device, machine, osVersion];
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

@end
