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

@interface SettingViewController : UITableViewController <PickerViewDelegate, UIActionSheetDelegate>

-(IBAction)showActionSheet;

@property (nonatomic, strong) Client *client;

@end
