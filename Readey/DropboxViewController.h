//
//  DropboxViewController.h
//  Readey
//
//  Created by David Barkman on 1/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxViewController : UITableViewController <DBRestClientDelegate>
{
    DBRestClient *restClient;
	NSArray *files;
}

@property (nonatomic, strong) ReadeyAPIClient *client;

@end
