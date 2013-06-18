//
//  RSSCategoriesViewController.h
//  Readey
//
//  Created by David Barkman on 3/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSCategoriesViewController : UITableViewController <ReadeyClientDelegate>
{
	ReadeyAPIClient *client;
	NSMutableArray *rssCategories;
	NSString *topLevel;
}

@end
