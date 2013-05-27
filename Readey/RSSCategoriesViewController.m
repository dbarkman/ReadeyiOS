//
//  RSSCategoriesViewController.m
//  Readey
//
//  Created by David Barkman on 3/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "RSSCategoriesViewController.h"
#import "RSSCategory.h"
#import "RSSItemsViewController.h"

@implementation RSSCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[Flurry logEvent:@"RSSCategoriesView"];
	
	client = [kAppDelegate readeyAPIClient];
	
	rssCategories = [NSMutableArray array];
	
	[self fetchCategories];
	
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuTapped)];
	[[self navigationItem] setLeftBarButtonItem:menuButton];
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsTapped)];
	[[self navigationItem] setRightBarButtonItem:settingsButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)fetchCategories
{
	client.delegate = self;
	[SVProgressHUD showWithStatus:@"Fetching Categories"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[client getCategories];
	});
}

- (void)requestReturned:(NSDictionary *)request
{
	[Flurry endTimedEvent:@"Get Categories" withParameters:nil];

	[SVProgressHUD dismiss];
	if (request) {
		for (id categoryDictionary in [request objectForKey:@"data"]) {
			RSSCategory *rssCategory = [[RSSCategory alloc] initWithDictionary:categoryDictionary];
			[rssCategories addObject:rssCategory];
		}
		
		[self.tableView reloadData];
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Drats! Couldn't fetch categories." message:@"Please try again in a few minutes." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (IBAction)menuTapped
{
	[Flurry logEvent:@"Left Menu Opened with Menu Button"];

	[[self viewDeckController] toggleLeftViewAnimated:YES];
}

- (IBAction)settingsTapped
{
	[Flurry logEvent:@"Right Menu Opened with Settings Button"];
	
	[[self viewDeckController] toggleRightViewAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rssCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	
	RSSCategory *rssCategory = [rssCategories objectAtIndex:[indexPath row]];
	
	[[cell textLabel] setText:rssCategory.name];
	
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ViewArticles"]) {
		RSSItemsViewController *rssItemsViewController = segue.destinationViewController;
		[rssItemsViewController setClient:client];
		
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		RSSCategory *rssCategory = [rssCategories objectAtIndex:[indexPath row]];
		[rssItemsViewController setRssCategory:rssCategory];
		
		NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:rssCategory.name, @"Category", nil];
		[Flurry logEvent:@"RSS Categories Selected" withParameters:flurryParams];
	}
}

@end
