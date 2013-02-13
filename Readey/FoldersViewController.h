//
//  FoldersViewController.h
//  Readey
//
//  Created by David Barkman on 1/11/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"
#import "GoogleReaderClient.h"

@interface FoldersViewController : UITableViewController
{
	NSString *readerColor;
}
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) GoogleReaderClient *grClient;

@end
