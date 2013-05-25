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

const int kLoadingCellTag = 1234;

@implementation RSSItemsViewController

@synthesize client, rssCategory;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[Flurry logEvent:@"RSSItemsView"];
	
	[[self navigationItem] setTitle:rssCategory.name];

	page = 1;
	rssItems = [NSMutableArray array];

	[self fetchRSSItems];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadLogNotification:) name:@"ReadLogCreated" object:nil];
	
	UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
	[refresh addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refresh;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)fetchRSSItems
{
	if (self.rssCategory) {
		client.delegate = self;
		[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Fetching %@ Articles", rssCategory.name]];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[client getItemsForCategory:rssCategory.uuid onPage:page];
		});
	}
}

- (void)requestReturned:(NSDictionary *)request
{
	[Flurry endTimedEvent:@"Get Items" withParameters:nil];
	
	[SVProgressHUD dismiss];
	if (request) {
		totalPages = [[request objectForKey:@"totalPages"] intValue];
		
		for (id itemDictionary in [request objectForKey:@"data"]) {
			RSSItem *rssItem = [[RSSItem alloc] initWithDictionary:itemDictionary];
			if (![rssItems containsObject:rssItem]) {
				[rssItems addObject:rssItem];
			}
		}
		
		[self.tableView reloadData];
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Drats! Couldn't fetch articles." message:@"Please try again in a few minutes." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (void)refreshPulled
{
	[self fetchRSSItems];
	
	if ([[self refreshControl] isRefreshing]) {
		[[self refreshControl] endRefreshing];
		[Flurry logEvent:@"RSS Items Refreshed"];
	}
}

- (void)handleReadLogNotification:(NSNotification *)notification
{
	[Flurry logEvent:@"RSS Item Read"];
	
	RSSItem *rssItem = [rssItems objectAtIndex:rssItemSelected];
	[rssItem markAsRead];
	[rssItems setObject:rssItem atIndexedSubscript:rssItemSelected];
	[self.tableView reloadData];
}

- (IBAction)tweet:(id)button
{
	RSSItem *rssItem = [rssItems objectAtIndex:[button tag]];
	NSString *url = [rssItem permalink];
	
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:rssItem.title, @"RSS Item", nil];
	[Flurry logEvent:@"RSS Item Shared to Twitter" withParameters:flurryParams];
	
	SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
		[slComposer dismissViewControllerAnimated:YES completion:nil];
	};
		
	[slComposer setInitialText:[NSString stringWithFormat:@"I'm reading this article with Readey: %@ - #ReadeyApp %@", url, kReadeyAppiTunesURL]];
	[slComposer setCompletionHandler:completionHandler];
	[self presentViewController:slComposer animated:YES completion:nil];
}

- (IBAction)facebook:(id)button
{
	RSSItem *rssItem = [rssItems objectAtIndex:[button tag]];
	NSString *url = [rssItem permalink];
	
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:rssItem.title, @"RSS Item", nil];
	[Flurry logEvent:@"RSS Item Shared to Facebook" withParameters:flurryParams];
	
	SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
	SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
		[slComposer dismissViewControllerAnimated:YES completion:nil];
	};
		
	[slComposer setInitialText:[NSString stringWithFormat:@"I'm reading this article with Readey: %@ - #ReadeyApp %@", url, kReadeyAppiTunesURL]];
	[slComposer setCompletionHandler:completionHandler];
	[self presentViewController:slComposer animated:YES completion:nil];
}

- (IBAction)sendEmail:(id)button {
	RSSItem *rssItem = [rssItems objectAtIndex:[button tag]];
	NSString *url = [rssItem permalink];
	
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:rssItem.title, @"RSS Item", nil];
	[Flurry logEvent:@"RSS Item Shared by Email" withParameters:flurryParams];
	
    NSString *emailTitle = @"Read with Readey";
    NSString *messageBody = [NSString stringWithFormat:@"I'm reading this article with Readey: %@ - %@", url, kReadeyAppiTunesURL];
    
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
		[mc setMailComposeDelegate:self];
		[mc setSubject:emailTitle];
		[mc setMessageBody:messageBody isHTML:YES];
		
		[self presentViewController:mc animated:YES completion:NULL];
	} else {
		[[[UIAlertView alloc] initWithTitle:@"No Mail Accounts" message:@"There are no mail accounts configured. You can add a mail account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result)
    {
        case MFMailComposeResultCancelled:
//            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
//            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
//            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
//            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
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
	if (page < totalPages) {
		return [rssItems count] + 1;
	}
	
    return [rssItems count];
}

- (CGFloat)rssItemHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	NSString *title = rssItem.title;
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 50, 20000.0f);
	CGSize size = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:kFontSize15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + 67.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] < [rssItems count]) {
		return [self rssItemHeightForRowAtIndexPath:indexPath];
	} else {
		return 44.0f;
	}
}

- (UITableViewCell *)rssItemCellForIndexPath:(NSIndexPath *)indexPath
{
	RSSItemCell *cell = (RSSItemCell *)[[self tableView] dequeueReusableCellWithIdentifier:@"RSSItemCell"];
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

- (UITableViewCell *)loadingCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    cell.tag = kLoadingCellTag;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] < [rssItems count]) {
		return [self rssItemCellForIndexPath:indexPath];
	} else {
		return [self loadingCell];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag) {
        page++;

		NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:rssCategory.name, @"RSS Category", nil];
		NSString *flurryLog = [NSString stringWithFormat:@"RSS Category %@ Showing Page %i", rssCategory.name, page];
		[Flurry logEvent:flurryLog withParameters:flurryParams];
		
        [self fetchRSSItems];
    } else {
		RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
		bool alreadyRead = rssItem.alreadyRead;
		if (alreadyRead == TRUE) {
			[cell setBackgroundColor:kOffWhiteColor];
		}
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RSSItem *rssItem = [rssItems objectAtIndex:[indexPath row]];
	
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:rssItem.title, @"RSS Item", nil];
	[Flurry logEvent:@"RSS Item Selected" withParameters:flurryParams];
	
	rssItemSelected = [indexPath row];

	ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
	[readeyViewController setClient:client];
	[readeyViewController setSourceEnabled:true];
	[readeyViewController setRssItemUuid:rssItem.uuid];
	[readeyViewController setSourceUrl:rssItem.permalink];
	[readeyViewController setArticleContent:rssItem.content];
	[readeyViewController setArticleIdentifier:rssItem.permalink];
	
	[readeyViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentViewController:readeyViewController animated:YES completion:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
