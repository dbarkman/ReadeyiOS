//
//  GoogleReaderFeedViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderFeedViewController.h"
#import "ReadeyViewController.h"

#define FONT_SIZE 18.0f
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
	
	articles = [[NSMutableArray alloc] init];

	NSString *authToken = [grClient getAuthToken];
	articles = [grClient getSubscriptionFeed:authToken fromFeed:feed];
	
	//check for content or summaries
	
	[[self navigationItem] setTitle:navTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
	CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
	}
	
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	NSString *title = [article objectForKey:@"title"];
	if (title.length == 0) title = @"(title unknown)";

	if (![article objectForKey:@"content"]) title = [NSString stringWithFormat:@"%@ (summary only)", title];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"eee MMM dd, yyyy @ h:mm a"];
	NSTimeInterval intervaldep = [[article objectForKey:@"updated"] doubleValue];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:intervaldep];
	NSString *formattedDate = [dateFormatter stringFromDate:date];
	
	[[cell textLabel] setText:title];
	[[cell detailTextLabel] setText:formattedDate];
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *contentDict;
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
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

@end
