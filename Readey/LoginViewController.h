//
//  LoginViewController.h
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
	IBOutlet UITextField *emailTextField;
	IBOutlet UITextField *passwordTextField;
}

@property (nonatomic) int alertViewFlag;
@property (nonatomic, strong) Client *client;

@end
