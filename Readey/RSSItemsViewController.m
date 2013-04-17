//
//  RSSItemsViewController.m
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "RSSItemsViewController.h"
#import "RSSItem.h"
#import "RSSItemCell.h"
#import "ReadeyViewController.h"

@implementation RSSItemsViewController

@synthesize client, rssCategory;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[self navigationItem] setTitle:rssCategory.name];

	rssItems = nil;

	if (self.rssCategory) {
		client.delegate = self;
		[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Fetching %@ Articles", rssCategory.name]];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[client getItemsForCategory:rssCategory.name];
		});
	}
}

- (void)requestReturned:(NSArray *)request
{
	rssItems = [client rssItems];
	[self.tableView reloadData];
	[SVProgressHUD dismiss];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rssItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	NSString *title = rssItem.title;
	NSLog(@"Title: %@", title);

	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 50, 20000.0f);
	CGSize size = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:kFontSize15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + 49.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItemCell *cell = (RSSItemCell *)[tableView dequeueReusableCellWithIdentifier:@"RSSItemCell"];
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	
	//find out the time to read
	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"200";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	int wpmInt = [wpm integerValue];
	float rate = 60.0 / wpmInt;

	float timeRemain = rssItem.wordCount * rate;
	int minutes = floor(timeRemain / 60);
	int seconds = timeRemain - (minutes * 60);

	[[cell title] setText:rssItem.title];
	[[cell feedTitle] setText:rssItem.feedTitle];
	[[cell date] setText:rssItem.date];
	[[cell timeToRead] setText:[NSString stringWithFormat:@"Time to read: %dm %02ds", minutes, seconds]];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	
	Client *clientOld = [[Client alloc] init];

	ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
	[readeyViewController setClient:clientOld];
	[readeyViewController setSourceEnabled:true];
	[readeyViewController setSourceUrl:rssItem.permalink];
	[readeyViewController setArticleContent:rssItem.content];
	[readeyViewController setArticleIdentifier:rssItem.permalink];
	
	[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readeyViewController animated:YES completion:nil];
}

@end
