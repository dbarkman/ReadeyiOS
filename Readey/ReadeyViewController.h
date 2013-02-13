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
    IBOutlet UIProgressView *progress;

    IBOutlet UIButton *back;
    IBOutlet UIButton *source;

	IBOutlet UIButton *startButton;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *slowerButton;
	IBOutlet UIButton *masterButton;
	IBOutlet UIButton *fasterButton;
	IBOutlet UIButton *nextButton;
	IBOutlet UIButton *endButton;
}

- (IBAction)back;
- (IBAction)source;

- (IBAction)start:(bool)andGo;
- (IBAction)prevWord;
- (IBAction)slower;
- (IBAction)play;
- (IBAction)pause;
- (IBAction)faster;
- (IBAction)nextWord;
- (IBAction)end;

@property (nonatomic, retain) NSString *articleContent;

@property (nonatomic) int marker;
@property (nonatomic) int wordArraySize;
@property (nonatomic, retain) NSArray *wordArray;

@property (nonatomic) float rate;
@property (nonatomic) float wordsPerMinute;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *finishTime;

@property (nonatomic, retain) NSString *sourceUrl;
@property (nonatomic, retain) NSString *sourceTitle;
@property (nonatomic) bool sourceEnabled;

@end
