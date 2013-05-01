//
//  DropboxViewController.m
//  Readey
//
//  Created by David Barkman on 1/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "DropboxViewController.h"
#import "ReadeyViewController.h"

@implementation DropboxViewController

@synthesize client;

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
	
	UIToolbar *toolBar = [[UIToolbar alloc] init];
	
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.height, 32)];
    }
	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	}
	
	toolBar.barStyle = UIBarStyleDefault;
	[toolBar sizeToFit];
	UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuTapped)];
	UIBarButtonItem *flexiableSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];

	NSArray *items = [NSArray arrayWithObjects:menu, flexiableSpace, refresh, nil];
	[toolBar setItems:items];
	[self.view addSubview:toolBar];
	[toolBar setTintColor:kOffBlackColor];
	
    [[self restClient] loadMetadata:@"/"];
	
	NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
	[article setObject:@"Loading..." forKey:@"name"];
	files = [[NSMutableArray alloc] initWithObjects:article, nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)menuTapped
{
	[[self viewDeckController] toggleLeftViewAnimated:YES];
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
				NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
				[article setObject:file.path forKey:@"path"];
				[article setObject:file.filename forKey:@"name"];
				[article setObject:file.lastModifiedDate forKey:@"date"];
				[newFilePaths addObject:article];
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
		[[cell textLabel] setFont:[UIFont systemFontOfSize:kFontSize16]];
	}
	
	NSDictionary *article = [files objectAtIndex:[indexPath row]];
	if ([article objectForKey:@"path"]) {
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    NSString *name = [article objectForKey:@"name"];
	[[cell textLabel] setText:name];
    
	if ([article objectForKey:@"date"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"eee MMM dd, yyyy @ h:mm a"];
		NSString *formattedDate = [dateFormatter stringFromDate:[article objectForKey:@"date"]];

		[[cell detailTextLabel] setText:formattedDate];
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *article = [files objectAtIndex:[indexPath row]];
	if ([article objectForKey:@"path"]) {
		NSString *path = [article objectForKey:@"path"];
		[restClient loadFile:path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"file.txt"]];
	}
}

- (void)restClient:(DBRestClient*)restClient loadedFile:(NSString*)localPath {
	NSString *fileContents = [[NSString alloc] initWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:nil];

	ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
	[readeyViewController setClient:client];
	[readeyViewController setSourceEnabled:false];
	[readeyViewController setArticleContent:fileContents];
	[readeyViewController setArticleIdentifier:@"Dropbox"];

	NSDictionary *flurryParamsSource = [[NSDictionary alloc] initWithObjectsAndKeys:@"Dropbox", @"Source", nil];
	[Flurry logEvent:@"Source Read" withParameters:flurryParamsSource];
	
	[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readeyViewController animated:YES completion:nil];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"There was an error loading your file." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[message show];
}

@end
