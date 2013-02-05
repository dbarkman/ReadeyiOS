//
//  GoogleReaderFeedViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleReaderFeedViewController : UITableViewController

@property (nonatomic, retain) NSString *navTitle;
@property (nonatomic, retain) NSString *feed;
@property (nonatomic, retain) NSMutableArray *articles;

@end
