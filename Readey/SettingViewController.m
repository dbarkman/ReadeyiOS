//
//  SettingViewController.m
//  Readey
//
//  Created by David Barkman on 1/16/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "SettingViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "FeedbackViewController.h"
#import "Flurry.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_MARGIN 20.0f

#define ACTIONSHEET_READEY 0
#define ACTIONSHEET_DROPBOX 1
#define ACTIONSHEET_GOOGLE_READER 2

@implementation SettingViewController

@synthesize client, grClient;

- (void)setClient:(Client *)c {
    client = c;
}

- (Client *)client {
    return client;
}

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
		
		[Flurry logEvent:@"SettingView"];
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

	[[self navigationItem] setTitle:@"Settings"];
	
	[[self tableView] setBackgroundView:nil];
	[[self tableView] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)valueSelected:(NSString *)value
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:@"wpm"];
	[[self tableView] reloadData];

	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:value, @"Value", nil];
	[Flurry logEvent:@"Words Per Minute" withParameters:flurryParams];
}

-(IBAction)showActionSheet:(int)actionsheet {
	UIActionSheet *unlinkDropbox = [[UIActionSheet alloc] initWithTitle:@"Unlink Dropbox?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	UIActionSheet *logoutGoogleReader = [[UIActionSheet alloc] initWithTitle:@"Logout of Google Reader?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
	
	UIActionSheet *logoutReadey = [[UIActionSheet alloc] initWithTitle:@"Logout of Readey?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
	
	switch (actionsheet) {
		case ACTIONSHEET_DROPBOX:
			[unlinkDropbox setTag:ACTIONSHEET_DROPBOX];
			[unlinkDropbox setActionSheetStyle:UIActionSheetStyleBlackOpaque];
			[unlinkDropbox showInView:self.view];
			break;
		case ACTIONSHEET_GOOGLE_READER:
			[logoutGoogleReader setTag:ACTIONSHEET_GOOGLE_READER];
			[logoutGoogleReader setActionSheetStyle:UIActionSheetStyleBlackOpaque];
			[logoutGoogleReader showInView:self.view];
			break;
		case ACTIONSHEET_READEY:
			[logoutReadey setTag:ACTIONSHEET_READEY];
			[logoutReadey setActionSheetStyle:UIActionSheetStyleBlackOpaque];
			[logoutReadey showInView:self.view];
			break;
	}
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSMutableDictionary *flurryParams = [[NSMutableDictionary alloc] init];
	switch (actionSheet.tag) {
		case ACTIONSHEET_DROPBOX:
			if (buttonIndex == 0) {
				[flurryParams setObject:@"Dropbox" forKey:@"Service"];
				[[DBSession sharedSession] unlinkAll];
			}
			break;
		case ACTIONSHEET_GOOGLE_READER:
			if (buttonIndex == 0) {
				[flurryParams setObject:@"Google Reader" forKey:@"Service"];
				[grClient logout];
			}
			break;
		case ACTIONSHEET_READEY:
			if (buttonIndex == 0) {
				[flurryParams setObject:@"Readey" forKey:@"Service"];
				[client logout];
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
			break;
	}
	[Flurry logEvent:@"Logged Out Of Service" withParameters:flurryParams];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
		case 2:
			return 1;
			break;
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
	}
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];

	wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"250";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Words per Minute"];
					[[cell detailTextLabel] setText:wpm];
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					break;
			}
			break;
		case 1:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Unlink Dropbox"];
					break;
				case 1:
					[[cell textLabel] setText:@"Logout of Google Reader"];
					break;
				case 2:
					[[cell textLabel] setText:@"Logout of Readey"];
					break;
			}
			break;
		case 2:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:@"Send Feedback or Report Bugs"];
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					break;
			}
			break;
	}

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];
	int row = [indexPath row];
	
	if (section == 0 && row == 0) {
		[Flurry logEvent:@"WPM Tapped"];
		NSString *intString;
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		for (int i = 5; i < 805; i = i + 5) {
			intString = [NSString stringWithFormat:@"%d", i];
			[tempArray addObject:intString];
		}
		
		wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
		int arrayIndex = ([wpm integerValue] - 5) / 5;
		
		PickerViewController *pickerViewController = [[PickerViewController alloc] init];
		[pickerViewController setDelegate:(id)self];
		[pickerViewController setPickerTitle:@"Words per Minute"];
		[pickerViewController setPickerIndex:arrayIndex];
		[pickerViewController setValueArray:[[NSArray alloc] initWithArray:tempArray]];
		
		[[self navigationController] pushViewController:pickerViewController animated:YES];
	}
	if (section == 1 && row == 0) {
		[self showActionSheet:ACTIONSHEET_DROPBOX];
	}
	if (section == 1 && row == 1) {
		[self showActionSheet:ACTIONSHEET_GOOGLE_READER];
	}
	if (section == 1 && row == 2) {
		[self showActionSheet:ACTIONSHEET_READEY];
	}
	if (section == 2 && row == 0) {
		NSDictionary *feedbackPickedFrom = [NSDictionary dictionaryWithObjectsAndKeys:@"Settings", @"From", nil];
		[Flurry logEvent:@"Feedback Picked From" withParameters:feedbackPickedFrom];

		FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];
		[feedbackViewController setClient:client];
		[[self navigationController] pushViewController:feedbackViewController animated:YES];
	}
}

@end
