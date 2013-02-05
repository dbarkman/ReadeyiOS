//
//  SettingViewController.m
//  Readey
//
//  Created by David Barkman on 1/16/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "SettingViewController.h"
#import "PickerViewController.h"
#import "GoogleReaderClient.h"
#import <DropboxSDK/DropboxSDK.h>

@interface SettingViewController ()

@end

@implementation SettingViewController

NSString *wpm;

@synthesize client = _client;

- (void)setClient:(Client *)c {
    _client = c;
}

- (Client *)client {
    return _client;
}

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

	[[self navigationItem] setTitle:@"Settings"];
	
	NSData *calmingBlueData = [[NSUserDefaults standardUserDefaults] objectForKey:@"calmingBlue"];
	UIColor *calmingBlue = [NSKeyedUnarchiver unarchiveObjectWithData:calmingBlueData];

	[[self tableView] setBackgroundView:nil];
	[[self tableView] setBackgroundColor:calmingBlue];
}

- (void)valueSelected:(NSString *)value
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:@"wpm"];
	[[self tableView] reloadData];
}

-(IBAction)showActionSheet:(int)actionsheet {
	UIActionSheet *unlinkDropbox = [[UIActionSheet alloc] initWithTitle:@"Unlink Dropbox?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	UIActionSheet *logoutGoogleReader = [[UIActionSheet alloc] initWithTitle:@"Logout of Google Reader?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
	
	UIActionSheet *logoutReadey = [[UIActionSheet alloc] initWithTitle:@"Logout of Readey?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
	
	switch (actionsheet) {
		case 1:
			[unlinkDropbox setTag:1];
			[unlinkDropbox setActionSheetStyle:UIActionSheetStyleBlackOpaque];
			[unlinkDropbox showInView:self.view];
			break;
		case 2:
			[logoutGoogleReader setTag:2];
			[logoutGoogleReader setActionSheetStyle:UIActionSheetStyleBlackOpaque];
			[logoutGoogleReader showInView:self.view];
			break;
		case 3:
			[logoutReadey setTag:3];
			[logoutReadey setActionSheetStyle:UIActionSheetStyleBlackOpaque];
			[logoutReadey showInView:self.view];
			break;
	}
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (actionSheet.tag) {
		case 1:
			if (buttonIndex == 0) {
				[[DBSession sharedSession] unlinkAll];
			}
			break;
		case 2:
			if (buttonIndex == 0) {
				GoogleReaderClient *grClient = [[GoogleReaderClient alloc] init];
				[grClient logout];
			}
			break;
		case 3:
			if (buttonIndex == 0) {
				[_client logout];
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
			break;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
	}
	
	wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"250";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	switch ([indexPath section]) {
		case 0:
			[[cell textLabel] setText:@"Words per Minute"];
			[[cell detailTextLabel] setText:wpm];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			break;
		case 1:
			[[cell textLabel] setText:@"Unlink Dropbox"];
			break;
		case 2:
			[[cell textLabel] setText:@"Logout of Google Reader"];
			break;
		case 3:
			[[cell textLabel] setText:@"Logout of Readey"];
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
		NSString *intString;
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		for (int i = 50; i < 805; i = i + 5) {
			intString = [NSString stringWithFormat:@"%d", i];
			[tempArray addObject:intString];
		}
		
		NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
		int arrayIndex = ([wpm integerValue] - 50) / 5;
		
		PickerViewController *pickerViewController = [[PickerViewController alloc] init];
		pickerViewController.delegate = self;
		pickerViewController.valueLabelString = wpm;
		pickerViewController.descriptionLabelString = @"Words per Minute:";
		pickerViewController.pickerIndex = arrayIndex;
		pickerViewController.valueArray = [[NSArray alloc] initWithArray:tempArray];
		
		[[self navigationController] pushViewController:pickerViewController animated:YES];
	}
	if (section == 1 && row == 0) {
		[self showActionSheet:1];
	}
	if (section == 2 && row == 0) {
		[self showActionSheet:2];
	}
	if (section == 3 && row == 0) {
		[self showActionSheet:3];
	}
}

@end
