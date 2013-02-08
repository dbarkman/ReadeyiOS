//
//  FeedbackViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "FeedbackViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedbackViewController

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
	
	[feedbackTypeTextField setInputView:emptyView];
	
	[feedbackTypeTextField setDelegate:self];
	[descriptionTextView setDelegate:self];
	[emailTextField setDelegate:self];
	
	if ([UIScreen mainScreen].bounds.size.height > 480) {
		descriptionHeight.constant += ([UIScreen mainScreen].bounds.size.height - 480);
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self subscribeToKeyboardEvents:YES];
	
	[descriptionTextView setClipsToBounds:YES];
	[[descriptionTextView layer] setCornerRadius:10.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self subscribeToKeyboardEvents:NO];
}

- (IBAction)submit
{
	NSString *feedback = [feedbackTypeTextField text];
	NSString *description = [descriptionTextView text];
	NSString *email = [emailTextField text];
	
	if ([_client createFeedback:feedback description:description email:email]) {
		[[[UIAlertView alloc] initWithTitle:@"Thank you for your feedback!" message:nil delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil] show];
		[[self navigationController] popViewControllerAnimated:YES];
	} else {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldLogout"] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"shouldLogout"];
			[self showAlert:@"Your session has expired. Please login again." withMessage:nil];
		} else {
			[self showAlert:@"Error" withMessage:@"Your feedback could not be saved.  For support, email support@speedReadey.com."];
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

- (void)valueSelected:(NSString *)value
{
	[feedbackTypeTextField setText:value];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (textField == feedbackTypeTextField) {
		PickerViewController *pickerViewController = [[PickerViewController alloc] init];
		pickerViewController.delegate = (id)self;
		pickerViewController.descriptionLabelString = @"I have:";
		pickerViewController.pickerIndex = 0;
		pickerViewController.valueArray = [[NSArray alloc] initWithObjects:@"An Idea", @"An Issue", @"A Question", @"A Compliment", nil];
		[[self navigationController] pushViewController:pickerViewController animated:YES];
	}
	
	if (textField == emailTextField) {
		[scrollView setContentOffset:CGPointMake(0, 216) animated:YES];
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	[textView resignFirstResponder];
	
	return YES;
}

- (void)subscribeToKeyboardEvents:(BOOL)subscribe
{
    if (subscribe) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) keyboardDidShow:(NSNotification *)nsNotification
{
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
    CGRect newFrame = [self.view frame];
	
    CGFloat kHeight = kbSize.height;
	
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        kHeight = kbSize.width;
    }
	
    newFrame.size.height -= kHeight;
	
    [self.view setFrame:newFrame];
}

- (void) keyboardWillHide:(NSNotification *)nsNotification
{
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [self.view frame];
	
    CGFloat kHeight = kbSize.height;
	
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        kHeight = kbSize.width;
    }
	
    newFrame.size.height += kHeight;
	
	[self.view setFrame:newFrame];
}

@end
