//
//  FeedbackViewController.h
//  Readey
//
//  Created by David Barkman on 2/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
	IBOutlet UITextView *descriptionTextView;
	IBOutlet UITextField *emailTextField;
	IBOutlet UIButton *submitButton;
}

- (IBAction)submit;

@end
