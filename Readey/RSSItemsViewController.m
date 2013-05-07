//
//  RSSItemsViewController.m
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "RSSItemsViewController.h"
#import "RSSItem.h"
#import "RSSItemCell.h"
#import "ReadeyViewController.h"

@implementation RSSItemsViewController

@synthesize client, rssCategory;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[self navigationItem] setTitle:rssCategory.name];

	rssItems = nil;

	if (self.rssCategory) {
		client.delegate = self;
		[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Fetching %@ Articles", rssCategory.name]];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[client getItemsForCategory:rssCategory.name];
		});
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)requestReturned:(NSArray *)request
{
	rssItems = [client rssItems];
	[self.tableView reloadData];
	[SVProgressHUD dismiss];
}

- (IBAction)tweet:(id)button
{
	RSSItem *rssItem = [rssItems objectAtIndex:[button tag]];
	NSString *url = [rssItem permalink];
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
			[slComposer dismissViewControllerAnimated:YES completion:nil];
		};
		
		[slComposer setInitialText:[NSString stringWithFormat:@"I'm reading this article with Readey: %@ - #ReadeyApp", url]];
		[slComposer setCompletionHandler:completionHandler];
		[self presentViewController:slComposer animated:YES completion:nil];
	}
}

- (IBAction)facebook:(id)button
{
	RSSItem *rssItem = [rssItems objectAtIndex:[button tag]];
	NSString *url = [rssItem permalink];
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
			[slComposer dismissViewControllerAnimated:YES completion:nil];
		};
		
		[slComposer setInitialText:[NSString stringWithFormat:@"I'm reading this article with Readey: %@ - #ReadeyApp", url]];
		[slComposer setCompletionHandler:completionHandler];
		[self presentViewController:slComposer animated:YES completion:nil];
	}
}

- (IBAction)sendEmail:(id)button {
	RSSItem *rssItem = [rssItems objectAtIndex:[button tag]];
	NSString *url = [rssItem permalink];
	
    NSString *emailTitle = @"Readey";
    NSString *messageBody = [NSString stringWithFormat:@"I'm reading this article with Readey: %@ - http://cla.ms/readey", url];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
	[mc setMailComposeDelegate:self];
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
	
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rssItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	NSString *title = rssItem.title;

	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 50, 20000.0f);
	CGSize size = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:kFontSize15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + 67.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItemCell *cell = (RSSItemCell *)[tableView dequeueReusableCellWithIdentifier:@"RSSItemCell"];
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	
	//find out the time to read
	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"200";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	int wpmInt = [wpm integerValue];
	float rate = 60.0 / wpmInt;

	float timeRemain = rssItem.wordCount * rate;
	int minutes = floor(timeRemain / 60);
	int seconds = timeRemain - (minutes * 60);

	[[cell title] setText:rssItem.title];
	[[cell feedTitle] setText:rssItem.feedTitle];
	[[cell date] setText:rssItem.date];
	[[cell timeToRead] setText:[NSString stringWithFormat:@"Time to read: %dm %02ds", minutes, seconds]];
	[[cell facebookShare] setTag:[indexPath row]];
	[[cell twitterShare] setTag:[indexPath row]];
	[[cell sendEmail] setTag:[indexPath row]];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	
	Client *clientOld = [[Client alloc] init];

	ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
	[readeyViewController setClient:clientOld];
	[readeyViewController setSourceEnabled:true];
	[readeyViewController setSourceUrl:rssItem.permalink];
	[readeyViewController setArticleContent:rssItem.content];
	[readeyViewController setArticleIdentifier:rssItem.permalink];
	
	[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readeyViewController animated:YES completion:nil];
}

@end
