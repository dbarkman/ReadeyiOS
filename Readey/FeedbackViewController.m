//
//  FeedbackViewController.m
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#define SCROLLVIEW_CONTENT_HEIGHT [UIScreen mainScreen].bounds.size.height - 44
#define SCROLLVIEW_CONTENT_WIDTH  320

#import "FeedbackViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)valueSelected:(NSString *)value
{
	[feedbackTypeTextField setText:value];
}

- (IBAction)submit
{
	NSString *description = [descriptionTextView text];
	NSString *email = [emailTextField text];
	
	NSLog(@"Description: %@ - Email: %@", description, email);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (textField == feedbackTypeTextField) {
		PickerViewController *pickerViewController = [[PickerViewController alloc] init];
		pickerViewController.delegate = self;
		pickerViewController.descriptionLabelString = @"I have:";
		pickerViewController.pickerIndex = 0;
		pickerViewController.valueArray = [[NSArray alloc] initWithObjects:@"An Issue", @"A Question", @"A Compliment", @"An Idea", nil];
		[[self navigationController] pushViewController:pickerViewController animated:YES];
	}
	
	if (textField == emailTextField) {
		[scrollView setContentOffset:CGPointMake(0, 216) animated:YES];
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == emailTextField) {
		[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
		[textField resignFirstResponder];
	}

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

- (void) keyboardDidShow:(NSNotification *)nsNotification {
	
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
}

@end
