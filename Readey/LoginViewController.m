//
//  LoginViewController.m
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "LoginViewController.h"
#import "FoldersViewController.h"
#import "ReadeyViewController.h"
#import "KeychainItemWrapper.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize alertViewFlag;
@synthesize client = _client;


- (void)setClient:(Client *)c
{
    _client = c;
}

- (Client *)client
{
    return _client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSData *calmingBlueData = [[NSUserDefaults standardUserDefaults] objectForKey:@"calmingBlue"];
	UIColor *calmingBlue = [NSKeyedUnarchiver unarchiveObjectWithData:calmingBlueData];
	
	self.view.backgroundColor = calmingBlue;
	
	emailTextField.delegate = self;
	passwordTextField.delegate = self;
//	[emailTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == emailTextField) {
		[textField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	} else if (textField == passwordTextField) {
		[textField resignFirstResponder];
		[self login];
	}
	
	return YES;
}

- (void)login
{
    NSString *username = [emailTextField text];
    NSString *password = [passwordTextField text];
	
	if (username.length == 0 || password.length == 0) {
		[self alertCredentialsMissing];

	} else if ([_client login:username withPassword:password]) {
		[self previousView];
    
	} else {
		[self alertLoginFailed];
    }
}

- (void)createAccount
{
    NSString *username = [emailTextField text];
    NSString *name = [emailTextField text];
    NSString *email = [emailTextField text];
    NSString *password = [passwordTextField text];
	
	if ([_client createUser:username
				   withName:name
				  withEmail:email
			   withPassword:password]) {
		[self previousView];
	} else {
		[self alertAccountCreateFailed];
	}
}

- (void)previousView
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ReaderAppLogin" accessGroup:nil];
    if ([saveLogin isOn]) {
        NSString *username = [emailTextField text];
        NSString *password = [passwordTextField text];
        
        [keychainItem setObject:username forKey:(__bridge id)kSecAttrAccount];
        [keychainItem setObject:password forKey:(__bridge id)kSecValueData];
    } else {
        [keychainItem resetKeychainItem];
    }
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 	switch (buttonIndex) {
		case 0:
			[emailTextField becomeFirstResponder];
			break;
		case 1:
			switch (alertViewFlag) {
				case 0:
					[self createAccount];
					break;
				case 2:
					//send email for reset
					[self alertEmailSent];
					break;
				default:
					break;
			}
		default:
			break;
	}
	if (buttonIndex == 0) {
		[emailTextField becomeFirstResponder];
	}
}

- (void)alertLoginFailed
{
	alertViewFlag = 0;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Account?"
													message:@"A Readey account was not found. Would you like to create a free account or reenter your information?"
												   delegate:self
										  cancelButtonTitle:@"Reenter Info"
										  otherButtonTitles:@"Create Account", nil];
	[alert show];
}

- (void)alertCredentialsMissing
{
	alertViewFlag = 1;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Missing"
													message:@"Your email or password may have been left blank."
												   delegate:self
										  cancelButtonTitle:@"Try Again"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)alertAccountCreateFailed
{
	alertViewFlag = 2;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Create Failed"
													message:@"An account could not be created. Would you like to reset your password or reenter your information?"
												   delegate:self
										  cancelButtonTitle:@"Reenter Info"
										  otherButtonTitles:@"Reset Password", nil];
	[alert show];
}

- (void)alertEmailSent
{
	alertViewFlag = 3;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Sent"
													message:@"An email was sent to the email address you entered. Follow the instructions in the email to reset your password."
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

@end
