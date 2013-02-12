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
#import "WebViewController.h"

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
	
	[emailTextField setDelegate:self];
	[passwordTextField setDelegate:self];

    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	
    [loginButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [loginButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
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

- (IBAction)login
{
    NSString *username = [emailTextField text];
    NSString *password = [passwordTextField text];
	
	[_client setUsername:username];
	[_client setPassword:password];
	
	if (username.length == 0 || password.length == 0) {
		[self alertCredentialsMissing];
		
	} else if ([_client login]) {
		[self previousView];
		
	} else {
		[self alertLoginFailed];
    }
}

- (void)createAccount
{
	[_client setUsername:[emailTextField text]];
	[_client setPassword:[passwordTextField text]];

	if ([_client createUser]) {
		[self previousView];
	} else {
		[self alertAccountCreateFailed];
	}
}

- (void)previousView
{
    if ([saveLogin isOn]) {
		[_client setUsername:[emailTextField text]];
		[_client setPassword:[passwordTextField text]];
		[_client saveLogin];
    } else {
		[_client resetLogin];
    }
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *url = @"http://api.usergrid.com/reallysimpleapps/readey/users/resetpw";
	NSString *title = @"Readey Password Reset";
	WebViewController *webViewController = [[WebViewController alloc] initWithURL:url title:title];
	
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
					[self alertWebView];
					break;
				case 3:
					[webViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
					[self presentViewController:webViewController animated:YES completion:nil];
				default:
					break;
			}
		default:
			break;
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

- (void)alertWebView
{
	alertViewFlag = 3;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset"
													message:@"A password reset webpage will now appear.  Enter the email for your Readey account. You will then receive an email from usergrid@apigee.com containing a link for resetting  your password."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	[alert show];
}

@end
