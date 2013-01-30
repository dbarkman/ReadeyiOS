//
//  ArticleListViewController.m
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ArticleListViewController.h"
#import "ReadeyViewController.h"
#import "SettingViewController.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_MARGIN 10.0f

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
	NSDictionary *article = [articles objectAtIndex:0];
	NSString *name = [article objectForKey:@"name"];
	if ([name isEqualToString:@"logout"]) {
		[[[UIAlertView alloc] initWithTitle:@"Your session has expired. Please login again." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		[_client logout];
        [self.navigationController popToRootViewControllerAnimated:YES];
	}

	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(tappedSettings)];
	[settingsButton setImageInsets:UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f)];
	[[self navigationItem] setRightBarButtonItem:settingsButton];
}

- (void)tappedSettings
{
	SettingViewController *settingsViewController = [[SettingViewController alloc] init];
	[settingsViewController setClient:_client];
	[[self navigationController] pushViewController:settingsViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articles count];
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
