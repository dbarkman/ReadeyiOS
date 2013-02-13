//
//  SettingViewController.h
//  Readey
//
//  Created by David Barkman on 1/16/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewController.h"
#import "Client.h"
#import "GoogleReaderClient.h"

@interface SettingViewController : UITableViewController <PickerViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
	NSString *wpm;
}

@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) GoogleReaderClient *grClient;

@end
