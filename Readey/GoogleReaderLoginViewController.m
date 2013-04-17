//
//  GoogleReaderLoginViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "GoogleReaderLoginViewController.h"

@implementation GoogleReaderLoginViewController

@synthesize delegate, grClient;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[Flurry logEvent:@"GoogleReaderLoginView"];
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	
    [loginButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [loginButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [cancelButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == usernameTextField) {
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
    NSString *username = [usernameTextField text];
    NSString *password = [passwordTextField text];
	
	[grClient setUsername:username];
	[grClient setPassword:password];
	
	if (username.length == 0 || password.length == 0) {
		[self alertCredentialsMissing];
		
	} else if ([grClient login]) {
		NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:@"yes", @"Authed", nil];
		[Flurry logEvent:@"Google Reader Authed" withParameters:flurryParams];
		
		[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
		
	} else {
		[self alertLoginFailed];
    }
}

- (IBAction)cancel
{
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:@"no", @"Authed", nil];
	[Flurry logEvent:@"Google Reader Authed" withParameters:flurryParams];

	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
	
	if ([delegate respondsToSelector:@selector(cancelLogin)]) {
		[delegate cancelLogin];
	}
}

- (void)alertLoginFailed
{
	[Flurry logEvent:@"Google Reader Login User Failed"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
													message:@"Login to Google Reader failed.  Please check your username and password and try again."
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)alertCredentialsMissing
{
	[Flurry logEvent:@"Google Reader Login Information Missing"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Missing"
													message:@"Your username or password may have been left blank."
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

@end
