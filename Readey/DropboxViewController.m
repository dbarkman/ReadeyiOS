//
//  DropboxViewController.m
//  Readey
//
//  Created by David Barkman on 1/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "DropboxViewController.h"
#import "ReadeyViewController.h"
#import "Flurry.h"

#define FONT_SIZE 16.0f

@implementation DropboxViewController

- (id)init
{
	self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
		
		[Flurry logEvent:@"DropboxView"];
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
	
	NSMutableDictionary *file = [[NSMutableDictionary alloc] init];
	[file setObject:@"Loading..." forKey:@"name"];
	files = [[NSMutableArray alloc] initWithObjects:file, nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)refreshClicked
{
    [[self restClient] loadMetadata:@"/"];
	
	[Flurry logEvent:@"Dropbox Refreshed"];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	NSArray* validExtensions = [NSArray arrayWithObjects:@"txt", nil];
    NSMutableArray *newFilePaths = [NSMutableArray new];
    if (metadata.isDirectory) {
		for (DBMetadata *file in metadata.contents) {
			NSString *extension = [[file.path pathExtension] lowercaseString];
			if (!file.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
				NSMutableDictionary *tempFile = [[NSMutableDictionary alloc] init];
				[tempFile setObject:file.path forKey:@"path"];
				[tempFile setObject:file.filename forKey:@"name"];
				[tempFile setObject:file.lastModifiedDate forKey:@"date"];
				[newFilePaths addObject:file];
			}
		}
	}
    files = newFilePaths;
	[[self tableView] reloadData];
	
	NSString *dbFilesCountString = [NSString stringWithFormat:@"%d", [files count]];
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:dbFilesCountString, @"File Count", nil];
	[Flurry logEvent:@"Get Dropbox Files" withParameters:flurryParams];
	
	if ([files count] == 0) {
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
    return [files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
		[[cell textLabel] setFont:[UIFont systemFontOfSize:FONT_SIZE]];
	}
	
	NSDictionary *file = [files objectAtIndex:[indexPath row]];
	if ([file objectForKey:@"path"]) {
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    NSString *name = [file objectForKey:@"name"];
	[[cell textLabel] setText:name];
    
	if ([file objectForKey:@"date"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"eee MMM dd, yyyy @ h:mm a"];
		NSString *formattedDate = [dateFormatter stringFromDate:[file objectForKey:@"date"]];

		[[cell detailTextLabel] setText:formattedDate];
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *file = [files objectAtIndex:[indexPath row]];
	if ([file objectForKey:@"path"]) {
		NSString *path = [file objectForKey:@"path"];
		[restClient loadFile:path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"file.txt"]];
	}
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
	NSString *fileContents = [[NSString alloc] initWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:nil];

	ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
	[readeyViewController setArticleContent:fileContents];
	[readeyViewController setSourceEnabled:false];

	[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readeyViewController animated:YES completion:nil];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"There was an error loading your file." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[message show];
}

@end
