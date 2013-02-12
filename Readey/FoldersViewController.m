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
#import "SettingViewController.h"
#import "DropboxViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "GoogleReaderViewController.h"

@interface FoldersViewController ()

@end

@implementation FoldersViewController

@synthesize client = _client;
@synthesize grClient;

- (void)setClient:(Client *)c {
    _client = c;
}

- (Client *)client {
    return _client;
}

- (id)init
{
	self = [super initWithStyle:UITableViewStylePlain];
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
    
    _client = [[Client alloc] init];
	grClient = [[GoogleReaderClient alloc] init];
    
	[[self navigationItem] setTitle:@"Readey"];

	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(tappedSettings)];
	[settingsButton setImageInsets:UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f)];
	[[self navigationItem] setRightBarButtonItem:settingsButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	if (![_client accessToken]) {
		[self retryAuth];
	}
}

- (void)retryAuth
{
    if (![_client login]) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        [loginViewController setClient:_client];
        [loginViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

- (void)tappedSettings
{
	SettingViewController *settingsViewController = [[SettingViewController alloc] init];
	[settingsViewController setClient:_client];
	[settingsViewController setGrClient:grClient];
	[[self navigationController] pushViewController:settingsViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
	}
	
	switch ([indexPath row]) {
		case 0:
			[[cell textLabel] setText:@"Articles"];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			break;
        case 1:
            [[cell textLabel] setText:@"Dropbox"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 2:
            [[cell textLabel] setText:@"Google Reader"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
	switch ([indexPath row]) {
		case 0:
            [articleListViewController setTitle:@"Articles"];
            [articleListViewController setClient:_client];
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
}

@end
