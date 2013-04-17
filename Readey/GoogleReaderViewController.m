//
//  GoogleReaderViewController.m
//  Readey
//
//  Created by David Barkman on 2/2/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderViewController.h"
#import "GoogleReaderFeedViewController.h"

@implementation GoogleReaderViewController

@synthesize grClient;

@synthesize client;

- (void)setClient:(Client *)c {
    client = c;
}

- (Client *)client {
    return client;
}

- (id)init
{
	self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
		
		[Flurry logEvent:@"GoogleReaderView"];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSMutableDictionary *feed = [[NSMutableDictionary alloc] init];
	[feed setObject:@"Loading..." forKey:@"title"];
	feeds = [[NSMutableArray alloc] initWithObjects:feed, nil];

	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];
	[[self navigationItem] setRightBarButtonItem:refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	if ([grClient isLoggedIn]) {
		NSString *authToken = [grClient getAuthToken];
		feeds = [grClient getSubscriptionList:authToken];
		
		[[self tableView] reloadData];
	} else {
		[Flurry logEvent:@"Google Reader Requesting User Login"];
		GoogleReaderLoginViewController *grLoginViewController = [[GoogleReaderLoginViewController alloc] init];
		grLoginViewController.delegate = self;
		[grLoginViewController setGrClient:grClient];
		[grLoginViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self presentViewController:grLoginViewController animated:YES completion:nil];
	}
}

- (void)cancelLogin
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)refreshClicked
{
	NSString *authToken = [grClient getAuthToken];
	feeds = [grClient getSubscriptionList:authToken];
	
	[[self tableView] reloadData];
	
	[Flurry logEvent:@"Google Reader Feeds Refreshed"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString *feedCountString = [NSString stringWithFormat:@"%d", [feeds count]];
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:feedCountString, @"Feed Count", nil];
	[Flurry logEvent:@"Get Google Reader Feeds" withParameters:flurryParams];

    return [feeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSDictionary *feed = [feeds objectAtIndex:[indexPath row]];
	NSString *title = [feed objectForKey:@"title"];
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (kCellContentMargin10 * 2), 20000.0f);
	CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:kFontSize16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (kCellContentMargin10 * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont systemFontOfSize:kFontSize16]];
	}

	NSDictionary *feed = [feeds objectAtIndex:[indexPath row]];
	if ([feed objectForKey:@"id"]) {
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

	NSString *title = [feed objectForKey:@"title"];
	[[cell textLabel] setText:title];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *feed = [feeds objectAtIndex:[indexPath row]];
	if ([feed objectForKey:@"id"]) {
		NSString *feedId = [feed objectForKey:@"id"];
		NSString *title = [feed objectForKey:@"title"];
		
		NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:title, @"Feed", nil];
		[Flurry logEvent:@"Google Reader Feed Selected" withParameters:flurryParams];

		GoogleReaderFeedViewController *grFeedViewController = [[GoogleReaderFeedViewController alloc] init];
		[grFeedViewController setClient:client];
		[grFeedViewController setGrClient:grClient];
		[grFeedViewController setFeed:feedId];
		[grFeedViewController setNavTitle:title];
		
		[[self navigationController] pushViewController:grFeedViewController animated:YES];
	}
}

@end
