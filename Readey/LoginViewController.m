//
//  LoginViewController.m
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "Flurry.h"

@implementation LoginViewController

@synthesize client;

- (void)setClient:(Client *)c
{
    client = c;
}

- (Client *)client
{
    return client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[Flurry logEvent:@"LoginView"];
    }
    return self;
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
	
	[client setUsername:username];
	[client setPassword:password];
	
	if (username.length == 0 || password.length == 0) {
		[self alertCredentialsMissing];
		
	} else if (![self validateEmail:username]) {
		[self alertEmailNotValid];
		
	} else if (![self validatePassword:password]) {
		[self alertPasswordNotValid];
		
	} else if ([client login]) {
		[self previousView];
		
	} else {
		[self alertLoginFailed];
    }
}

- (bool)validateEmail:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (bool)validatePassword:(NSString*)password
{
	if ([password length] < 6) return false;
    NSString *passwordRegex = @"[a-zA-Z0-9,.!@#$%^&*()_-]{6,32}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    return [emailTest evaluateWithObject:password];
}

- (void)createAccount
{
	[client setUsername:[emailTextField text]];
	[client setPassword:[passwordTextField text]];

	if ([client createUser]) {
		[Flurry logEvent:@"Created User"];
		[self previousView];
	} else {
		[self alertAccountCreateFailed];
	}
}

- (void)previousView
{
	NSMutableDictionary *saveLoginDict = [[NSMutableDictionary alloc] init];
    if ([saveLogin isOn]) {
		[saveLoginDict setObject:@"yes" forKey:@"saveLogin"];
		[client setUsername:[emailTextField text]];
		[client setPassword:[passwordTextField text]];
		[client saveLogin];
    } else {
		[saveLoginDict setObject:@"no" forKey:@"saveLogin"];
		[client resetLogin];
    }
	[Flurry logEvent:@"Login User" withParameters:saveLoginDict];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *url = @"http://api.usergrid.com/reallysimpleapps/readey/users/resetpw";
	WebViewController *webViewController = [[WebViewController alloc] initWithURL:url];
	
	switch (buttonIndex) {
		case 0:
			switch (alertViewFlag) {
				case 0:
					[Flurry logEvent:@"Reenter Info On Create"];
					break;
				case 1:
					[Flurry logEvent:@"Reenter Info On Information Missing"];
					break;
				case 2:
					[Flurry logEvent:@"Reenter Info On Create User Failed"];
					break;
				case 3:
					[Flurry logEvent:@"Cancel Password Reset"];
					break;
				case 4:
					[Flurry logEvent:@"Try Again On Username Invalid"];
					break;
				case 5:
					[Flurry logEvent:@"Try Again On Password Invalid"];
					break;
				default:
					break;
			}
			[emailTextField becomeFirstResponder];
			break;
		case 1:
			switch (alertViewFlag) {
				case 0:
					[self createAccount];
					break;
				case 1:
					[self alertWebView];
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
	[Flurry logEvent:@"Login User Failed"];
	alertViewFlag = 0;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Account?"
													message:@"A Readey account was not found. Would you like to create a Readey account or reenter your information?"
												   delegate:self
										  cancelButtonTitle:@"Reenter Info"
										  otherButtonTitles:@"Create Account", nil];
	[alert show];
}

- (void)alertCredentialsMissing
{
	[Flurry logEvent:@"Login Information Missing"];
	alertViewFlag = 1;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Missing"
													message:@"Your email or password may have been left blank. Would you like to reset your password or reenter your information?"
												   delegate:self
										  cancelButtonTitle:@"Try Again"
										  otherButtonTitles:@"Reset Password", nil];
	[alert show];
}

- (void)alertEmailNotValid
{
	[Flurry logEvent:@"Invalid Email"];
	alertViewFlag = 4;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Not Valid"
													message:@"Please enter a valid email address."
												   delegate:self
										  cancelButtonTitle:@"Try Again"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)alertPasswordNotValid
{
	[Flurry logEvent:@"Invalid Password"];
	alertViewFlag = 5;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Not Valid"
													message:@"Please enter a valid password. A password can be between 6 and 32 characters and could contain letters, uper and lower case, numbers and the following symbols: ,.!@#$%^&*()_-"
												   delegate:self
										  cancelButtonTitle:@"Try Again"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)alertAccountCreateFailed
{
	[Flurry logEvent:@"Create User Failed"];
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
	[Flurry logEvent:@"Reset Password"];
	alertViewFlag = 3;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset"
													message:@"A password reset webpage will now appear.  Enter the email for your Readey account. You will then receive an email from usergrid@apigee.com containing a link for resetting your password."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	[alert show];
}

@end
