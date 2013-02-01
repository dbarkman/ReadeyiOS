//
//  DropboxViewController.h
//  Readey
//
//  Created by David Barkman on 1/29/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "Client.h"

@interface DropboxViewController : UITableViewController <DBRestClientDelegate>
{
    DBRestClient *restClient;
	NSArray *filePaths;
}

@end
