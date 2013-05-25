//
//  FeedbackViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "FeedbackViewController.h"
#import "PickerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedbackViewController

@synthesize client, feedbackLabelString, whichFeedback;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[Flurry logEvent:@"FeedbackView"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuTapped)];
	[[self navigationItem] setLeftBarButtonItem:menu];

	UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	[feedbackTypeTextField setInputView:emptyView];
	
	[feedbackTypeTextField setDelegate:self];
	[descriptionTextView setDelegate:self];
	[emailTextField setDelegate:self];
	
	if ([UIScreen mainScreen].bounds.size.height > 480) {
		descriptionHeight.constant += ([UIScreen mainScreen].bounds.size.height - 480);
	}
	
	[feedbackLabel setText:feedbackLabelString];
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

- (IBAction)menuTapped
{
	[Flurry logEvent:@"Left Menu Opened with Menu Button"];
	
	[[self viewDeckController] toggleLeftViewAnimated:YES];
}

- (IBAction)submit
{
	[feedbackTypeTextField resignFirstResponder];
	[descriptionTextView resignFirstResponder];
	[emailTextField resignFirstResponder];
	
	NSString *feedback = [feedbackTypeTextField text];
	NSString *description = [descriptionTextView text];
	NSString *email = [emailTextField text];
	
	client.delegate = self;

	if ([email length] > 0) [Flurry logEvent:@"Email Included with Feedback"];
	
	[SVProgressHUD showWithStatus:@"Sending Feedback"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[client createFeedback:feedback description:description email:email];
	});
}

- (void)requestReturned:(NSDictionary *)request
{
	[Flurry endTimedEvent:@"POST Feedback" withParameters:nil];

	[SVProgressHUD dismiss];
	if (request) {
		[SVProgressHUD showSuccessWithStatus:@"Thanks for your feedback!"];
		[[self viewDeckController] toggleLeftViewAnimated:YES];
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Drats! Your feedback could not be saved. For support, email support@speedReadey.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (void)valueSelected:(NSString *)value
{
	[feedbackTypeTextField setText:value];
	NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:value, @"Value", nil];
	[Flurry logEvent:@"FeedbackType" withParameters:flurryParams];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (textField == feedbackTypeTextField) {
		PickerViewController *pickerViewController = [[PickerViewController alloc] init];
		[pickerViewController setDelegate:(id)self];
		[pickerViewController setPickerTitle:@"Choose Feedback"];
		[pickerViewController setPickerIndex:0];
		
		NSArray *fscArray = [[NSArray alloc] initWithObjects:@"An Idea", @"An Issue", @"A Question", @"A Compliment", nil];
		NSArray *vffcArray = [[NSArray alloc] initWithObjects:@"Create My Own Feed", @"Sync Across Devices", @"Offline Reading", @"Show Reading Stats", @"Create My Own Articles", @"Other Feature", nil];
		NSArray *vfscArray = [[NSArray alloc] initWithObjects:@"Pocket", @"Readability", @"Instapaper", @"Dropbox", @"Other Source", nil];
		switch (whichFeedback) {
			case 0:
				[pickerViewController setValueArray:fscArray];
				break;
			case 1:
				[pickerViewController setValueArray:vffcArray];
				break;
			case 2:
				[pickerViewController setValueArray:vfscArray];
				break;
		}
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
