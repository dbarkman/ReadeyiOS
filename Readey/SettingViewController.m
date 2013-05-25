//
//  SettingViewController.m
//  Readey
//
//  Created by David Barkman on 1/16/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "SettingViewController.h"
#import "FeedbackViewController.h"

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[Flurry logEvent:@"SettingView"];

	float rightSize = self.viewDeckController.rightSize;
	float width = self.navigationController.view.frame.size.width;
	float height = self.view.frame.size.height;
	self.navigationController.view.frame = (CGRect){rightSize, 0.0f, (width - rightSize), height};

	[[self tableView] setBackgroundView:nil];
	[[self tableView] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeTapped)];
	[[self navigationItem] setLeftBarButtonItem:closeButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	[self.tableView reloadData];
}

- (IBAction)closeTapped
{
	[Flurry logEvent:@"Right Menu Closed with Close Button"];

	[[self viewDeckController] closeRightViewAnimated:YES];
}

- (void)valueSelected:(NSString *)value
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:@"wpm"];
	[[self tableView] reloadData];

	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:value, @"Value", nil];
	[Flurry logEvent:@"Words Per Minute" withParameters:flurryParams];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
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

	wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"200";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:[NSString stringWithFormat:@"Words per Minute: %@", wpm]];
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
		[Flurry logEvent:@"Words per Minute Tapped"];
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
}

@end
