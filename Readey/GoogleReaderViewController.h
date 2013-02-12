//
//  GoogleReaderViewController.h
//  Readey
//
//  Created by David Barkman on 2/2/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReaderClient.h"
#import "GoogleReaderLoginViewController.h"

@interface GoogleReaderViewController : UITableViewController <GoogleReaderLoginDelegate>

@property (nonatomic, strong) GoogleReaderClient *grClient;
@property (nonatomic, retain) NSMutableArray *subscriptionTitles;

@end
