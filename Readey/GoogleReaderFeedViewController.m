//
//  GoogleReaderFeedViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderFeedViewController.h"
#import "ReadeyViewController.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_MARGIN 20.0f

@implementation GoogleReaderFeedViewController

@synthesize grClient, navTitle, feed;

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
	
	[[self navigationItem] setTitle:navTitle];
	
	NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
	[article setObject:@"Loading..." forKey:@"title"];
	articles = [[NSMutableArray alloc] initWithObjects:article, nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	NSString *authToken = [grClient getAuthToken];
	articles = [grClient getSubscriptionFeed:authToken fromFeed:feed];
	
	[self.tableView reloadData];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
		NSDictionary *contentDict;

		if ([article objectForKey:@"content"]) {
			contentDict = [article objectForKey:@"content"];
		} else {
			contentDict = [article objectForKey:@"summary"];
		}
		NSString *content = [contentDict objectForKey:@"content"];
		
		NSArray *alternateArray = [article objectForKey:@"alternate"];
		NSDictionary *alternateDict = [alternateArray objectAtIndex:0];
		
		ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
		[readeyViewController setArticleContent:content];
		[readeyViewController setSourceUrl:[alternateDict objectForKey:@"href"]];
		[readeyViewController setSourceEnabled:true];
		
		[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self presentViewController:readeyViewController animated:YES completion:nil];
	}
}

@end
