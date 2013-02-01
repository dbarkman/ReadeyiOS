//
//  DropboxViewController.m
//  Readey
//
//  Created by David Barkman on 1/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "DropboxViewController.h"
#import "SettingViewController.h"
#import "ReadeyViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxViewController ()

@end

@implementation DropboxViewController

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

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];
	[[self navigationItem] setRightBarButtonItem:refresh];

    [[self restClient] loadMetadata:@"/"];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)refreshClicked
{
    [[self restClient] loadMetadata:@"/"];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	NSArray* validExtensions = [NSArray arrayWithObjects:@"txt", nil];
    NSMutableArray *newFilePaths = [NSMutableArray new];
    if (metadata.isDirectory) {
		for (DBMetadata *file in metadata.contents) {
			NSString *extension = [[file.path pathExtension] lowercaseString];
			if (!file.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
				NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
				[tempDict setObject:file.path forKey:@"path"];
				[tempDict setObject:file.filename forKey:@"name"];
				[newFilePaths addObject:tempDict];
			}
		}
	}
    filePaths = newFilePaths;
	[[self tableView] reloadData];
	
	if ([filePaths count] == 0) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Files!" message:@"Put some .txt files in your Apps/Readey folder.  :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[message show];
	}
}

- (void)restClient:(DBRestClient *)client
    loadMetadataFailedWithError:(NSError *)error {
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filePaths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
	}
    
	NSDictionary *tempDict = [filePaths objectAtIndex:[indexPath row]];
    NSString *name = [tempDict objectForKey:@"name"];
    [[cell textLabel] setText:name];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tempDict = [filePaths objectAtIndex:[indexPath row]];
    NSString *path = [tempDict objectForKey:@"path"];
	[restClient loadFile:path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"file.txt"]];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
	NSString *fileContents = [[NSString alloc] initWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:nil];

	ReadeyViewController *readyViewController = [[ReadeyViewController alloc] init];
	[readyViewController setArticleContent:fileContents];
	
	[readyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readyViewController animated:YES completion:nil];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"There was an error loading your file." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[message show];
}

@end
