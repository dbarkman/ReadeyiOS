//
//  FoldersViewController.m
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "FoldersViewController.h"
#import "FeedbackViewController.h"
#import "RSSCategoriesViewController.h"

@implementation FoldersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[Flurry logEvent:@"FoldersView"];

	float width = self.view.frame.size.width;
	float height = self.view.frame.size.height;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		width = self.view.frame.size.height;
		height = self.view.frame.size.width;
	}
	float leftSize = self.viewDeckController.leftSize;
	float newWidth = (width - leftSize);
	self.navigationController.view.frame = (CGRect){0.0f, 0.0f, newWidth, height};
	
	[[self tableView] setBackgroundView:nil];
	[[self tableView] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	
	client = [kAppDelegate readeyAPIClient];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeTapped)];
	[[self navigationItem] setLeftBarButtonItem:closeButton];
}

- (IBAction)closeTapped
{
	[Flurry logEvent:@"Left Menu Closed with Close Button"];
	
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
			return 1;
			break;
		case 1:
			return 3;
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
			}
			break;
		case 1:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Feedback/Support"];
					break;
				case 1:
					[[cell textLabel] setText:@"Vote for Features"];
					break;
				case 2:
					[[cell textLabel] setText:@"Vote fore Sources"];
					break;
			}
			break;
	}
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];

	UINavigationController *feedbackNavigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
	[feedbackNavigationController.navigationBar setTintColor:kOffBlackColor];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Readey" bundle:nil];
	UIViewController *centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];

	NSDictionary *flurryParamsFeaturedArticleSource = [[NSDictionary alloc] initWithObjectsAndKeys:@"Featured Article", @"Source", nil];
	
	NSDictionary *flurryParamsFeedbackSupportFeedback = [[NSDictionary alloc] initWithObjectsAndKeys:@"FeedbackSupport", @"Feedback", nil];
	NSDictionary *flurryParamsVoteFeaturesFeedback = [[NSDictionary alloc] initWithObjectsAndKeys:@"VoteFeatures", @"Feedback", nil];
	NSDictionary *flurryParamsVoteSourcesFeedback = [[NSDictionary alloc] initWithObjectsAndKeys:@"VoteSources", @"Feedback", nil];

	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[Flurry logEvent:@"Reading Source Selected" withParameters:flurryParamsFeaturedArticleSource];
					
					[[self viewDeckController] closeLeftViewAnimated:YES];
					[[self viewDeckController] setCenterController:centerViewController];
					break;
			}
			break;
		case 1:
			switch ([indexPath row]) {
				case 0:
					[Flurry logEvent:@"Feedback Source Selected" withParameters:flurryParamsFeedbackSupportFeedback];
					
					[feedbackViewController setClient:client];
					[feedbackViewController setWhichFeedback:0];
					[feedbackViewController setFeedbackLabelString:@"Hey Readey Developers, I have:"];
					[[self viewDeckController] closeLeftViewAnimated:YES];
					[[self viewDeckController] setCenterController:feedbackNavigationController];
					break;
				case 1:
					[Flurry logEvent:@"Feedback Source Selected" withParameters:flurryParamsVoteFeaturesFeedback];
					
					[feedbackViewController setClient:client];
					[feedbackViewController setWhichFeedback:1];
					[feedbackViewController setFeedbackLabelString:@"Please add this feature:"];
					[[self viewDeckController] closeLeftViewAnimated:YES];
					[[self viewDeckController] setCenterController:feedbackNavigationController];
					break;
				case 2:
					[Flurry logEvent:@"Feedback Source Selected" withParameters:flurryParamsVoteSourcesFeedback];
					
					[feedbackViewController setClient:client];
					[feedbackViewController setWhichFeedback:2];
					[feedbackViewController setFeedbackLabelString:@"Please add this reading source:"];
					[[self viewDeckController] closeLeftViewAnimated:YES];
					[[self viewDeckController] setCenterController:feedbackNavigationController];
					break;
			}
			break;
	}
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
