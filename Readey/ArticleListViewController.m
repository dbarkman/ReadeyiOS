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

#define FONT_SIZE 16.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface ArticleListViewController ()

@end

@implementation ArticleListViewController

int articleCount;
NSArray *articles;

@synthesize client = _client;

- (void)setClient:(Client *)c {
    _client = c;
}

- (Client *)client {
    return _client;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];
	[[self navigationItem] setRightBarButtonItem:refresh];

	articles = [_client getArticles];
	articleCount = [articles count];
	
	NSDictionary *article = [articles objectAtIndex:0];
	NSString *name = [article objectForKey:@"name"];
	if ([name isEqualToString:@"logout"]) {
		articleCount = 0;
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Your session has expired. Please login again." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[message show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[_client logout];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)addClicked
{
	ArticleAddViewController *articleAddViewController = [[ArticleAddViewController alloc] init];
	[[self navigationController] pushViewController:articleAddViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return articleCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	NSString *articleName = [article objectForKey:@"name"];
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [articleName sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont systemFontOfSize:FONT_SIZE]];
	}
	
	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"250";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	[[cell textLabel] setText:[article objectForKey:@"name"]];
//	[[cell detailTextLabel] setText:@"wpm"];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	ReadeyViewController *readyViewController = [[ReadeyViewController alloc] init];
	[readyViewController setArticleContent:[article objectForKey:@"content"]];

	[readyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readyViewController animated:YES completion:nil];
}

@end
