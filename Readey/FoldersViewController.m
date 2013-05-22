//
//  FoldersViewController.m
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "FoldersViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxViewController.h"
#import "FeedbackViewController.h"
#import "RSSCategoriesViewController.h"

@implementation FoldersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[Flurry logEvent:@"FoldersView"];

	float leftSize = self.viewDeckController.leftSize;
	float width = self.view.frame.size.width;
	float height = self.view.frame.size.height;
	NSLog(@"Left Size: %f - Width: %f - Height: %f", leftSize, width, height);
	self.navigationController.view.frame = (CGRect){0.0f, 0.0f, (width - leftSize), height};
	
	[[self tableView] setBackgroundView:nil];
	[[self tableView] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	
	client = [kAppDelegate readeyAPIClient];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeTapped)];
	[[self navigationItem] setLeftBarButtonItem:closeButton];
}

- (IBAction)closeTapped
{
	[[self viewDeckController] closeLeftViewAnimated:YES];
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
			return 2;
			break;
		case 1:
			return 1;
			break;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Featured Articles"];
					break;
				case 1:
					[[cell textLabel] setText:@"My Dropbox Articles"];
					break;
			}
			break;
		case 1:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Feedback/New Sources"];
					break;
			}
			break;
	}
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DropboxViewController *dropboxViewController = [[DropboxViewController alloc] init];
	FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];

	UINavigationController *feedbackNavigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
	[feedbackNavigationController.navigationBar setTintColor:kOffBlackColor];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Readey" bundle:nil];
	UIViewController *centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];

	NSMutableDictionary *folderPicked = [[NSMutableDictionary alloc] init];
	NSDictionary *pickedFrom = [NSDictionary dictionaryWithObjectsAndKeys:@"Folders", @"From", nil];

	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[[self viewDeckController] closeLeftViewAnimated:YES];
					[[self viewDeckController] setCenterController:centerViewController];
					break;
				case 1:
					[folderPicked setObject:@"Dropbox" forKey:@"Folder"];
					if (![[DBSession sharedSession] isLinked]) {
						[[DBSession sharedSession] linkFromController:self];
					} else {
						[dropboxViewController setClient:client];
						[[self viewDeckController] closeLeftViewAnimated:YES];
						[[self viewDeckController] setCenterController:dropboxViewController];
					}
					break;
			}
			break;
			[Flurry logEvent:@"Folder Picked" withParameters:folderPicked];
		case 1:
			switch ([indexPath row]) {
				case 0:
					[Flurry logEvent:@"Feedback Picked From" withParameters:pickedFrom];
					[feedbackViewController setClient:client];
					[[self viewDeckController] closeLeftViewAnimated:YES];
					[[self viewDeckController] setCenterController:feedbackNavigationController];
					break;
			}
			break;
	}
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
