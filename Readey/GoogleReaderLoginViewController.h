//
//  GoogleReaderLoginViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReaderClient.h"

@interface GoogleReaderLoginViewController : UIViewController <UITextFieldDelegate>
{
	GoogleReaderClient *grClient;
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UIButton *loginButton;
}

- (IBAction)login;

@end
