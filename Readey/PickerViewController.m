//
//  PickerViewController.m
//  Readey
//
//  Created by David Barkman on 1/16/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController ()

@end

@implementation PickerViewController

@synthesize delegate, valueLabelString, descriptionLabelString, valueArray, pickerIndex;

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
	
	[descriptionLabel setText:descriptionLabelString];
	
	[pickerView selectRow:pickerIndex inComponent:0 animated:YES];
	[valueLabel setText:[valueArray objectAtIndex:[pickerView selectedRowInComponent:0]]];

	if ([delegate respondsToSelector:@selector(valueSelected:)]) {
		[delegate valueSelected:[valueArray objectAtIndex:[pickerView selectedRowInComponent:0]]];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[valueLabel setText:[valueArray objectAtIndex:row]];

	if ([delegate respondsToSelector:@selector(valueSelected:)]) {
		[delegate valueSelected:[valueArray objectAtIndex:row]];
	}
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [valueArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [valueArray objectAtIndex:row];
}

@end
