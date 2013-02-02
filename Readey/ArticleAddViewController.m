//
//  ArticleAddViewController.m
//  Readey
//
//  Created by David Barkman on 1/31/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#define SCROLLVIEW_CONTENT_HEIGHT [UIScreen mainScreen].bounds.size.height - 44
#define SCROLLVIEW_CONTENT_WIDTH  320

#import "ArticleAddViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ArticleAddViewController ()

@end

@implementation ArticleAddViewController

@synthesize client = _client;

- (void)setClient:(Client *)c {
    _client = c;
}

- (Client *)client {
    return _client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	[articleName setDelegate:self];
	[articleUrl setDelegate:self];
	[articleContents setDelegate:self];
	
	[articleUrl setInputView:emptyView];
	[articleContents setInputView:emptyView];
	
	UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveTapped)];
	[[self navigationItem] setRightBarButtonItem:save];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[articleContents setClipsToBounds:YES];
	[[articleContents layer] setCornerRadius:10.0f];
	
	NSString *alertMessage = @"This form is meant for copy and paste. To type an article yourself, login with your Readey account at speedReadey.com. The keyboard will appear for the Name field only.";
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Paste Only" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[message show];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

- (IBAction)saveTapped
{
	NSString *name = [articleName text];
	NSString *url = [articleUrl text];
	NSString *contents = [articleContents text];
	
	if ([_client createArticle:name source:url content:contents]) {
		[[self navigationController] popViewControllerAnimated:YES];
	} else {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldLogout"] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"shouldLogout"];
			[self showAlert:@"Your session has expired. Please login again." withMessage:nil];
		} else {
			[self showAlert:@"Error" withMessage:@"The article could not be saved"];
		}
	}
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[_client logout];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
