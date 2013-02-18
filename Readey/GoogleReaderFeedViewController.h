//
//  GoogleReaderFeedViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReaderClient.h"
#import "Client.h"

@interface GoogleReaderFeedViewController : UITableViewController
{
	NSMutableArray *articles;
}

@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) GoogleReaderClient *grClient;
@property (nonatomic, retain) NSString *navTitle;
@property (nonatomic, retain) NSString *feed;

@end
