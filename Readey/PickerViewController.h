//
//  PickerViewController.h
//  Readey
//
//  Created by David Barkman on 1/16/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

@protocol PickerViewDelegate <NSObject>

- (void)valueSelected:(NSString *)value;

@end

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    IBOutlet UIPickerView *pickerView;

	__weak id <PickerViewDelegate> delegate;
}

@property (nonatomic, weak)id <PickerViewDelegate> delegate;
@property (nonatomic, strong) NSString *pickerTitle;
@property (nonatomic) int pickerIndex;
@property (nonatomic, strong) NSArray *valueArray;

@end
