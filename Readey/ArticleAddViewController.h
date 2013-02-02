//
//  ArticleAddViewController.h
//  Readey
//
//  Created by David Barkman on 1/31/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface ArticleAddViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>
{
	IBOutlet UITextField *articleName;
	IBOutlet UITextField *articleUrl;
	IBOutlet UITextView *articleContents;
}

@property (nonatomic, strong) Client *client;

@end
