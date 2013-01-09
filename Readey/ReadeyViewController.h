//
//  ReadeyViewController.h
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadeyViewController : UIViewController
{
	IBOutlet UILabel *wpmRate;
	IBOutlet UILabel *timeRemaining;
	IBOutlet UILabel *words;
	IBOutlet UILabel *currentWord;
	IBOutlet UILabel *timeToRead;
	IBOutlet UILabel *averageSpeed;
	IBOutlet UIButton *startReading;
	IBOutlet UIButton *pause;
    IBOutlet UIButton *back;
    IBOutlet UIButton *prevWordBtn;
    IBOutlet UIButton *nextWordBtn;
    IBOutlet UIButton *fasterBtn;
    IBOutlet UIButton *slowerBtn;
    IBOutlet UIProgressView *progress;
}

- (IBAction)startReading:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)nextWord:(id)sender;
- (IBAction)prevWord:(id)sender;
- (IBAction)faster:(id)sender;
- (IBAction)slower:(id)sender;

@property (nonatomic) int marker;
@property (nonatomic) int wordArraySize;
@property (nonatomic, retain) NSArray *wordArray;

@property (nonatomic) float rate;
@property (nonatomic) float wordsPerMinute;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) NSDate *start;
@property (nonatomic, retain) NSDate *finish;

@end
