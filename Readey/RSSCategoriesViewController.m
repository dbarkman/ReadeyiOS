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
	
	client = [kAppDelegate readeyAPIClient];
	client.delegate = self;
	
	[SVProgressHUD showWithStatus:@"Fetching Categories"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[client getCategories];
	});

	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuTapped)];
	[[self navigationItem] setLeftBarButtonItem:menuButton];
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsTapped)];
	[[self navigationItem] setRightBarButtonItem:settingsButton];
}

- (void)requestReturned:(NSArray *)request
{
	rssCategories = request;
	[self.tableView reloadData];
	[SVProgressHUD dismiss];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)menuTapped
{
	[[self viewDeckController] toggleLeftViewAnimated:YES];
}

- (IBAction)settingsTapped
{
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
		[rssItemsViewController setRssCategory:[rssCategories objectAtIndex:[indexPath row]]];
	}
}

@end
