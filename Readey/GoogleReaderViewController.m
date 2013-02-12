//
//  GoogleReaderViewController.m
//  Readey
//
//  Created by David Barkman on 2/2/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderViewController.h"
#import "GoogleReaderFeedViewController.h"

#define FONT_SIZE 18.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation GoogleReaderViewController

@synthesize grClient;
@synthesize subscriptionTitles;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	if ([grClient isLoggedIn]) {
		NSString *authToken = [grClient getAuthToken];
		subscriptionTitles = [grClient getSubscriptionList:authToken];
		
		[[self tableView] reloadData];
	} else {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [subscriptionTitles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSDictionary *tempDict = [subscriptionTitles objectAtIndex:[indexPath row]];
	NSString *title = [tempDict objectForKey:@"title"];
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
	}
	
	NSDictionary *tempDict = [subscriptionTitles objectAtIndex:[indexPath row]];
	NSString *title = [tempDict objectForKey:@"title"];
	
	[[cell textLabel] setText:title];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tempDict = [subscriptionTitles objectAtIndex:[indexPath row]];
	NSString *feedId = [tempDict objectForKey:@"id"];
	NSString *title = [tempDict objectForKey:@"title"];
	
	GoogleReaderFeedViewController *grFeedViewController = [[GoogleReaderFeedViewController alloc] init];
	[grFeedViewController setGrClient:grClient];
	[grFeedViewController setFeed:feedId];
	[grFeedViewController setNavTitle:title];
	
	[[self navigationController] pushViewController:grFeedViewController animated:YES];
}

@end
