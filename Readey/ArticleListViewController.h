//
//  ArticleListViewController.h
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleListViewController : UITableViewController <UIAlertViewDelegate>
{
	NSMutableArray *articles;
}

@property (nonatomic, strong) ReadeyAPIClient *client;

@end
