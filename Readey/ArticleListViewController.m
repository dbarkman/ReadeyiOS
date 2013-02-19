//
//  ArticleListViewController.m
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ArticleListViewController.h"
#import "ReadeyViewController.h"
#import "ArticleAddViewController.h"
#import "Flurry.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_MARGIN 20.0f

@implementation ArticleListViewController

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
		
		[Flurry logEvent:@"ArticleListView"];
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
	
	NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
	[article setObject:@"Loading..." forKey:@"articleName"];
	articles = [[NSMutableArray alloc] initWithObjects:article, nil];
	
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked)];
	[add setStyle:UIBarButtonItemStyleBordered];
	[[self navigationItem] setRightBarButtonItem:add];
	
	UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
	[refresh addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refresh;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	[self refreshPulled];
}

- (void)refreshPulled
{
	NSArray *tempArray = [client getArticles];
	articles = [[NSMutableArray alloc] initWithArray:tempArray];
	
	if ([articles count] == 0) {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldLogout"] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"shouldLogout"];
			[self showAlert:@"Your session has expired. Please login again." withMessage:nil];
		} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"error"] boolValue]) {
			[Flurry logEvent:@"Get Articles Failed"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"error"];
			[self showAlert:@"Error" withMessage:@"There was an error retrieving your articles."];
		} else {
			NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
			[article setObject:@"No Articles, tap the + button to add one." forKey:@"articleName"];
			articles = [[NSMutableArray alloc] initWithObjects:article, nil];
		}
	}
	
	[[self tableView] reloadData];
	
	NSString *articleCountString = [NSString stringWithFormat:@"%d", [articles count]];
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:articleCountString, @"Article Count", nil];
	[Flurry logEvent:@"Get Articles" withParameters:flurryParams];
	
	if ([[self refreshControl] isRefreshing]) {
		[[self refreshControl] endRefreshing];
		[Flurry logEvent:@"Articles Refreshed"];
	}
}

- (IBAction)addClicked
{
	ArticleAddViewController *articleAddViewController = [[ArticleAddViewController alloc] init];
	[articleAddViewController setClient:client];
	[[self navigationController] pushViewController:articleAddViewController animated:YES];
}

- (bool)removeArticle:(NSDictionary *)article
{
	NSString *articleUUID = [article objectForKey:@"uuid"];
	if (![client removeArticle:articleUUID]) {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldLogout"] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"shouldLogout"];
			[self showAlert:@"Your session has expired. Please login again." withMessage:nil];
			return false;
		} else {
			[Flurry logEvent:@"Remove Article Failed"];
			[self showAlert:@"Error" withMessage:@"The article could not be removed"];
			return false;
		}
	} else {
		[Flurry logEvent:@"Removed Article"];
		return true;
	}
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	NSString *articleName = [article objectForKey:@"articleName"];
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [articleName sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
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
	if ([article objectForKey:@"content"]) {
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

	NSString *articleName = [article objectForKey:@"articleName"];
	[[cell textLabel] setText:articleName];

	if ([article objectForKey:@"modified"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"eee MMM dd, yyyy @ h:mm a"];
		NSTimeInterval intervaldep = ([[article objectForKey:@"modified"] doubleValue] / 1000);
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:intervaldep];
		NSString *formattedDate = [dateFormatter stringFromDate:date];
		
		[[cell detailTextLabel] setText:formattedDate];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if ([self removeArticle:[articles objectAtIndex:[indexPath row]]]) {
			[articles removeObjectAtIndex:[indexPath row]];
			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView endUpdates];
			[tableView reloadData];
		}
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	if ([article objectForKey:@"content"]) {
		ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
		[readeyViewController setClient:client];
		[readeyViewController setSourceEnabled:false];
		[readeyViewController setArticleContent:[article objectForKey:@"content"]];
		[readeyViewController setArticleIdentifier:[article objectForKey:@"uuid"]];
		
		NSDictionary *flurryParamsSource = [[NSDictionary alloc] initWithObjectsAndKeys:@"Article", @"Source", nil];
		[Flurry logEvent:@"Source Read" withParameters:flurryParamsSource];

		[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self presentViewController:readeyViewController animated:YES completion:nil];
	}
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[client logout];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
