//
//  GoogleReaderViewController.m
//  Readey
//
//  Created by David Barkman on 2/2/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderViewController.h"

@interface GoogleReaderViewController ()

@end

@implementation GoogleReaderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	http://stackoverflow.com/questions/3802008/native-google-reader-iphone-application/3829114#3829114
	
	NSString *username = @"speedreadey@gmail.com";
	NSString *password = @"ads0nepa";
	NSString *source = @"RealSimpleApps-Readey-1.0";

    NSMutableURLRequest *httpReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"] ];
    [httpReq setTimeoutInterval:30.0];
    [httpReq setHTTPMethod:@"POST"];
    [httpReq addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    NSString *requestBody = [[NSString alloc] initWithFormat:@"Email=%@&Passwd=%@&service=reader&accountType=HOSTED_OR_GOOGLE&source=%@", username, password, source];
    [httpReq setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
	
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = nil;
    NSString *responseStr = nil;
    int responseStatus = 0;
    data = [NSURLConnection sendSynchronousRequest:httpReq returningResponse:&response error:&error];
	
	if ([data length] > 0) {
        responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"Response From Google: %@", responseStr);
		
		NSArray *responseArray = [responseStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
		NSLog(@"Auth: %@", [responseArray objectAtIndex:3]);
		
        responseStatus = [response statusCode];

        if (responseStatus == 200 ) {
			NSLog(@"Authentication Successful!!");

            httpReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com/reader/api/0/subscription/list?output=json"] ];
			[httpReq setTimeoutInterval:30.0];
			[httpReq setHTTPMethod:@"POST"];
			[httpReq addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
			
			NSMutableDictionary *headerDict = [[httpReq allHTTPHeaderFields] mutableCopy];
			[headerDict setObject:[responseArray objectAtIndex:3] forKey:@"Auth"];
			[httpReq setAllHTTPHeaderFields:headerDict];
			
			response = nil;
			error = nil;
			data = nil;
			responseStr = nil;
			int responseStatus = 0;
			data = [NSURLConnection sendSynchronousRequest:httpReq returningResponse:&response error:&error];
			
			if ([data length] > 0) {
				responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				NSLog(@"Response From Google: %@", responseStr);
				
				responseStatus = [response statusCode];
				
				if (responseStatus == 200 ) {
					NSLog(@"Get List Successful!!");
				} else if (responseStatus == 403) {
					NSLog(@"get list failed");
				}
			}
		} else if (responseStatus == 403) {
			NSLog(@"authentication failed");
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
