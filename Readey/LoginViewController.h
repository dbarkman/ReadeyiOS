//
//  LoginViewController.h
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
	int alertViewFlag;
	IBOutlet UITextField *emailTextField;
	IBOutlet UITextField *passwordTextField;
    IBOutlet UISwitch *saveLogin;
	IBOutlet UIButton *loginButton;
}

@property (nonatomic, strong) ReadeyAPIClient *client;

- (IBAction)login;

@end
