//
//  RSSItemsViewController.h
//  Readey
//
//  Created by David Barkman on 4/3/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSCategory.h"
#import "ReadeyAPIClient.h"

@interface RSSItemsViewController : UITableViewController <ReadeyClientDelegate>
{
	NSArray *rssItems;
}

@property (nonatomic, strong) ReadeyAPIClient *client;
@property (strong, nonatomic) RSSCategory *rssCategory;

@end
