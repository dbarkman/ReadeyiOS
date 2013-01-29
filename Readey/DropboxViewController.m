//
//  DropboxViewController.m
//  Readey
//
//  Created by David Barkman on 1/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "DropboxViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxViewController ()

@end

@implementation DropboxViewController

@synthesize fileNamesArray;

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

    [[self restClient] loadMetadata:@"/"];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            [tempArray addObject:file.filename];
            NSLog(@"\t%@", file.filename);
        }
        fileNamesArray = tempArray;
        [[self tableView] reloadData];
    }
}

- (void)restClient:(DBRestClient *)client
    loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileNamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
	}
    
    NSString *name = [fileNamesArray objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:name];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
