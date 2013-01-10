//
//  LoginViewController.m
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "LoginViewController.h"
#import "ReadeyViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

	emailTextField.delegate = self;
	passwordTextField.delegate = self;
	[emailTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == emailTextField) {
		[textField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	} else if (textField == passwordTextField) {
		[textField resignFirstResponder];
		ReadeyViewController *readeyViewController = [[ReadeyViewController alloc] init];
		[readeyViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self presentViewController:readeyViewController animated:YES completion:nil];
	}

	
	return YES;
}

@end
