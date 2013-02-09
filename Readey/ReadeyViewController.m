//
//  ReadeyViewController.m
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyViewController.h"

@interface ReadeyViewController ()

@end

@implementation ReadeyViewController

@synthesize articleContent, marker, wordArray, wordArraySize;
@synthesize rate, wordsPerMinute, timer, start, finish;

- (IBAction)back
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateButton];

	[timer invalidate];
	
	CGFloat height = [[UIScreen mainScreen] bounds].size.height;
	CGRect frame = [currentWord frame];
	frame.origin.y = (height - frame.size.height) / 2;
	[currentWord setFrame:frame];
	
	marker = 0;
	
	NSArray *tempArray = [articleContent componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	wordArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
	wordArraySize = [wordArray count];
	
	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	int wpmInt = [wpm integerValue];

	wordsPerMinute = wpmInt;
	rate = 60.0 / wordsPerMinute;
	
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters];
}

- (void)updateCounters
{
	float timeRemain = (wordArraySize - marker) * rate;
	int minutes = floor(timeRemain / 60);
	int seconds = timeRemain - (minutes * 60);
	[timeRemaining setText:[NSString stringWithFormat:@"%d:%02d time", minutes, seconds]];
	[words setText:[NSString stringWithFormat:@"%d words", wordArraySize - marker]];
    [progress setProgress:(1.0 / wordArraySize) * marker animated:YES];
}

- (IBAction)nextWord:(id)sender
{
	if (marker < wordArraySize) {
		int wordLength = 0;
		NSString *word = @"";
		while (wordLength == 0) {
			word = [wordArray objectAtIndex:marker];
			wordLength = [word length];
			marker++;
		}
		[currentWord setText:word];
        finish = [NSDate date];
		[self updateCounters];
	} else if (marker == wordArraySize) {
        [back setHidden:NO];
		[timer invalidate];
		
		[self setToRestart];
		[self setToResume];
        
        [currentWord setText:@"Complete!"];
        [timeToRead setHidden:NO];
        [averageSpeed setHidden:NO];

        NSTimeInterval difference = [finish timeIntervalSinceDate:start];
		int minutes = floor(difference / 60);
		int seconds = difference - (minutes * 60);
		[timeToRead setText:[NSString stringWithFormat:@"Time: %d:%02d", minutes, seconds]];
		[averageSpeed setText:[NSString stringWithFormat:@"Speed: %.0f wpm", wordArraySize * (60 / difference)]];
	}
}

- (IBAction)prevWord:(id)sender
{
	if (marker > 0) {
		int wordLength = 0;
		NSString *word = @"";
		while (wordLength == 0) {
			word = [wordArray objectAtIndex:marker];
			wordLength = [word length];
			marker--;
		}
		[currentWord setText:word];
        [self updateCounters];
	}
}

- (IBAction)faster:(id)sender
{
	wordsPerMinute = wordsPerMinute + 5;
	rate = 60.0 / wordsPerMinute;
	if ([timer isValid]) [self resetTimer];
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters];
}

- (IBAction)slower:(id)sender
{
	wordsPerMinute = wordsPerMinute - 5;
	rate = 60.0 / wordsPerMinute;
	if ([timer isValid]) [self resetTimer];
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters];
}

- (void)resetTimer
{
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:rate
											 target:self
										   selector:@selector(nextWord:)
										   userInfo:nil
											repeats:YES];
}

- (IBAction)startReading:(id)sender
{
    [back setHidden:YES];
    [timeToRead setHidden:YES];
    [averageSpeed setHidden:YES];
	[self resetTimer];
    start = [NSDate date];
	[self setToRestart];
	[self setToPause];
}

- (IBAction)pause:(id)sender
{
	if ([timer isValid]) {
        [back setHidden:NO];
		[timer invalidate];
		[self setToResume];
	}
}

- (IBAction)resume:(id)sender
{
    [back setHidden:YES];
	[self resetTimer];
	[self setToPause];
}

- (IBAction)restart:(id)sender
{
    [back setHidden:NO];
	[timer invalidate];
	
	marker = 0;
    
    [self updateCounters];
	
	[self setToStart];
	[self setToPause];
	
	[currentWord setText:@"Ready?"];
}

- (void)setToPause
{
	[pause setTitle:@"Pause" forState:UIControlStateNormal];
	[pause removeTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
	[pause addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToResume
{
	[pause setTitle:@"Resume" forState:UIControlStateNormal];
	[pause removeTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
	[pause addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToStart
{
	[startReading setTitle:@"Start" forState:UIControlStateNormal];
	[startReading removeTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
	[startReading addTarget:self action:@selector(startReading:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToRestart
{
	[startReading setTitle:@"Restart" forState:UIControlStateNormal];
	[startReading removeTarget:self action:@selector(startReading:) forControlEvents:UIControlEventTouchUpInside];
	[startReading addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateButton
{
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	
    [startReading setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startReading setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [pause setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [pause setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [back setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [back setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [prevWordBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [prevWordBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [nextWordBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [nextWordBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [fasterBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [fasterBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [slowerBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [slowerBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

@end
