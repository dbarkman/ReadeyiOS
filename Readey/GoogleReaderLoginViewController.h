//
//  GoogleReaderLoginViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

@protocol GoogleReaderLoginDelegate <NSObject>

- (void)cancelLogin;

@end

#import <UIKit/UIKit.h>
#import "GoogleReaderClient.h"

@interface GoogleReaderLoginViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *cancelButton;
	
	__weak id <GoogleReaderLoginDelegate> delegate;
}

@property (nonatomic, weak)id <GoogleReaderLoginDelegate> delegate;
@property (nonatomic, strong) GoogleReaderClient *grClient;

- (IBAction)login;
- (IBAction)cancel;

@end
