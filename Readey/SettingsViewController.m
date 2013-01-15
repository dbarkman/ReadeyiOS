//
//  SettingsViewController.m
//  Readey
//
//  Created by David Barkman on 1/15/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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

	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) wpm = @"250";
	[wpmTextField setText:wpm];

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
						   [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
						   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						   [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
						   nil];
    [numberToolbar sizeToFit];
    wpmTextField.inputAccessoryView = numberToolbar;
}

-(void) cancelNumberPad{
    [wpmTextField resignFirstResponder];
    wpmTextField.text = @"";
}

-(void) doneWithNumberPad{
	NSString *wpm = [wpmTextField text];
	[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];

    [wpmTextField resignFirstResponder];
}

@end
