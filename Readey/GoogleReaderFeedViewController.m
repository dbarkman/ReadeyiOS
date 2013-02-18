//
//  GoogleReaderFeedViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderFeedViewController.h"
#import "ReadeyViewController.h"
#import "Flurry.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_MARGIN 20.0f

@implementation GoogleReaderFeedViewController

@synthesize grClient, navTitle, feed;

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
		
		[Flurry logEvent:@"GoogleReaderFeedView"];
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
	
	[[self navigationItem] setTitle:navTitle];
	
	NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
	[article setObject:@"Loading..." forKey:@"title"];
	articles = [[NSMutableArray alloc] initWithObjects:article, nil];

	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];
	[[self navigationItem] setRightBarButtonItem:refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSString *authToken = [grClient getAuthToken];
	articles = [grClient getSubscriptionFeed:authToken fromFeed:feed];

	[[self tableView] reloadData];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)refreshClicked
{
	NSString *authToken = [grClient getAuthToken];
	articles = [grClient getSubscriptionFeed:authToken fromFeed:feed];
	
	[[self tableView] reloadData];
	
	[Flurry logEvent:@"Google Reader Feed Articles Refreshed"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	NSString *title = [article objectForKey:@"title"];
	if (title.length == 0) title = @"(title unknown)";
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont systemFontOfSize:FONT_SIZE]];
	}

	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	if ([article objectForKey:@"content"] || [article objectForKey:@"summary"]) {
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

	NSString *title = [article objectForKey:@"title"];
	if (title.length == 0) title = @"(title unknown)";
	if (![article objectForKey:@"content"] && [article objectForKey:@"summary"]) {
		title = [NSString stringWithFormat:@"%@ (summary only)", title];
	}
	[[cell textLabel] setText:title];
	
	if ([article objectForKey:@"updated"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"eee MMM dd, yyyy @ h:mm a"];
		NSTimeInterval intervaldep = [[article objectForKey:@"updated"] doubleValue];
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:intervaldep];
		NSString *formattedDate = [dateFormatter stringFromDate:date];
		
		[[cell detailTextLabel] setText:formattedDate];
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	if ([article objectForKey:@"content"] || [article objectForKey:@"summary"]) {
		NSDictionary *contentDict = [[NSDictionary alloc] init];
		NSMutableDictionary *flurryParamsArticleContent = [[NSMutableDictionary alloc] init];
		if ([article objectForKey:@"content"]) {
			contentDict = [article objectForKey:@"content"];
			[flurryParamsArticleContent setObject:@"content" forKey:@"contentOrSummary"];
		} else {
			contentDict = [article objectForKey:@"summary"];
			[flurryParamsArticleContent setObject:@"summary" forKey:@"contentOrSummary"];
		}
		NSString *content = [contentDict objectForKey:@"content"];
		[Flurry logEvent:@"Google Reader Feed Article Content or Summary" withParameters:flurryParamsArticleContent];
		
		NSArray *alternateArray = [article objectForKey:@"alternate"];
		NSDictionary *alternateDict = [alternateArray objectAtIndex:0];
		NSString *sourceUrl = [alternateDict objectForKey:@"href"];
		
		NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:sourceUrl, @"Article", nil];
		[Flurry logEvent:@"Google Reader Feed Article Selected" withParameters:flurryParams];
		
		ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
		[readeyViewController setClient:client];
		[readeyViewController setSourceEnabled:true];
		[readeyViewController setSourceUrl:sourceUrl];
		[readeyViewController setArticleContent:content];
		[readeyViewController setArticleIdentifier:sourceUrl];
		
		NSDictionary *flurryParamsSource = [[NSDictionary alloc] initWithObjectsAndKeys:@"Google Reader", @"Source", nil];
		[Flurry logEvent:@"Source Read" withParameters:flurryParamsSource];
		
		[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self presentViewController:readeyViewController animated:YES completion:nil];
	}
}

@end
