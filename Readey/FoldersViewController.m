//
//  FoldersViewController.m
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "FoldersViewController.h"
#import "LoginViewController.h"
#import "ArticleListViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxViewController.h"
#import "GoogleReaderViewController.h"
#import "FeedbackViewController.h"
#import "SettingViewController.h"

@implementation FoldersViewController

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
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
    
    client = [[Client alloc] init];
	grClient = [[GoogleReaderClient alloc] init];
    
	[[self navigationItem] setTitle:@"Readey"];

	[[self tableView] setBackgroundView:nil];
	[[self tableView] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];

	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(tappedSettings)];
	[settingsButton setImageInsets:UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f)];
	[[self navigationItem] setRightBarButtonItem:settingsButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	if (![client accessToken]) {
		[self retryAuth];
	}
}

- (void)retryAuth
{
    if (![client login]) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        [loginViewController setClient:client];
        [loginViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

- (void)tappedSettings
{
	SettingViewController *settingsViewController = [[SettingViewController alloc] init];
	[settingsViewController setClient:client];
	[settingsViewController setGrClient:grClient];
	[[self navigationController] pushViewController:settingsViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return 2;
			break;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Your Saved Articles"];
					break;
				case 1:
					[[cell textLabel] setText:@"Files from Dropbox"];
					break;
				case 2:
					[[cell textLabel] setText:@"Google Reader Feeds"];
					break;
			}
			break;
		case 1:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Feedback"];
					break;
				case 1:
					[[cell textLabel] setText:@"More Sources Coming!"];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					[cell setAccessoryType:UITableViewCellAccessoryNone];
					break;
			}
			break;
	}
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleListViewController *articleListViewController = [[ArticleListViewController alloc] init];
    DropboxViewController *dropboxViewController = [[DropboxViewController alloc] init];
	GoogleReaderViewController *googleReaderViewController = [[GoogleReaderViewController alloc] init];
	FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];
	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[articleListViewController setTitle:@"Articles"];
					[articleListViewController setClient:client];
					[[self navigationController] pushViewController:articleListViewController animated:YES];
					break;
				case 1:
					if (![[DBSession sharedSession] isLinked]) {
						[[DBSession sharedSession] linkFromController:self];
					} else {
						[dropboxViewController setTitle:@"Dropbox"];
						[[self navigationController] pushViewController:dropboxViewController animated:YES];
					}
					break;
				case 2:
					[googleReaderViewController setTitle:@"Google Reader"];
					[googleReaderViewController setGrClient:grClient];
					[[self navigationController] pushViewController:googleReaderViewController animated:YES];
					break;
			}
			break;
		case 1:
			switch ([indexPath row]) {
				case 0:
					[feedbackViewController setClient:client];
					[[self navigationController] pushViewController:feedbackViewController animated:YES];
					break;
				default:
					[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
					break;
			}
			break;
	}
}

@end
