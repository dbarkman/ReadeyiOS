//
//  FeedbackViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewController.h"
#import "Client.h"

@interface FeedbackViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
	IBOutlet UITextField *feedbackTypeTextField;
	IBOutlet UITextView *descriptionTextView;
	IBOutlet UITextField *emailTextField;
	IBOutlet UIButton *submitButton;
	IBOutlet UIScrollView *scrollView;
	
	IBOutlet NSLayoutConstraint *descriptionHeight;
}

@property (nonatomic, strong) Client *client;

- (IBAction)submit;

@end
