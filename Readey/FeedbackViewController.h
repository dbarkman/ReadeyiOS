//
//  FeedbackViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, ReadeyClientDelegate>
{
	IBOutlet UITextField *feedbackTypeTextField;
	IBOutlet UITextView *descriptionTextView;
	IBOutlet UITextField *emailTextField;
	IBOutlet UIButton *submitButton;
	IBOutlet UIScrollView *scrollView;
	IBOutlet NSLayoutConstraint *descriptionHeight;
}

@property (nonatomic, strong) ReadeyAPIClient *client;

- (IBAction)submit;

@end
