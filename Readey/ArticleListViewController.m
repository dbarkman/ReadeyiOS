//
//  ArticleListViewController.m
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ArticleListViewController.h"
#import "ReadeyViewController.h"

@interface ArticleListViewController ()

@end

@implementation ArticleListViewController

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
	
	articles = [_client getArticles];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
	}
	
	NSDictionary *article = [articles objectAtIndex:[indexPath row]];
	[[cell textLabel] setText:[article objectForKey:@"name"]];
	
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
