//
//  ArticleAddViewController.m
//  Readey
//
//  Created by David Barkman on 1/31/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ArticleAddViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"

@implementation ArticleAddViewController

@synthesize client;

- (void)setClient:(Client *)c {
    client = c;
}

- (Client *)client {
    return client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[Flurry logEvent:@"ArticleAddView"];
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
	
	NSString *alertMessage = @"This form is meant for copy and paste. The keyboard will only appear for the Article Name field.";
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
	
	if ([client createArticle:name source:url content:contents]) {
		[Flurry logEvent:@"Created Article"];
		[[self navigationController] popViewControllerAnimated:YES];
	} else {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldLogout"] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"shouldLogout"];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your session has expired. Please login again." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		} else {
			[Flurry logEvent:@"Create Article Failed"];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The article could not be saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[client logout];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
