//
//  ReadeyViewController.m
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyViewController.h"
#import "NSString_stripHtml.h"
#import "WebViewController.h"

@implementation ReadeyViewController

@synthesize articleContent, marker, wordArray, wordArraySize;
@synthesize rate, wordsPerMinute, timer, start, finish;
@synthesize sourceUrl, sourceTitle, sourceEnabled;

bool jumpBack = false;
bool jumpForward = false;

- (IBAction)back
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)source
{
	WebViewController *webViewController = [[WebViewController alloc] initWithURL:sourceUrl title:sourceTitle];
	[webViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentViewController:webViewController animated:YES completion:nil];
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
	
	//setup the regex to find and remove easy html
	NSRegularExpression *regexImageTag = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//setup the regex to find short-hyphen hyphenated-words and make them into hyphenated- words
	NSRegularExpression *regexShortHyphen = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z]+-)" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//setup the regex to find long—hyphen hyphenated-words and make them into hyphenated- words
	NSRegularExpression *regexLongHyphen = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z]+—)" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	NSLog(@"Original Length: %d", [articleContent length]);
	
	//apply the above regex for easy html
	NSString *articlecontent0 = [regexImageTag stringByReplacingMatchesInString:articleContent options:0 range:NSMakeRange(0, [articleContent length]) withTemplate:@""];
	
	NSLog(@"Post Step 0 Length: %d", [articlecontent0 length]);
	
	//remove all html content with stripHTML - not sureif this is needed
	NSString *articleContent1 = [articlecontent0 stripHtml];
	
	NSLog(@"Post Step 1 Length: %d", [articleContent1 length]);
	
	//apply the above regex for short-hyphenated-words
	NSString *articlecontent2 = [regexShortHyphen stringByReplacingMatchesInString:articleContent1 options:0 range:NSMakeRange(0, [articleContent1 length]) withTemplate:@"$1 "];
	
	NSLog(@"Post Step 2 Length: %d", [articlecontent2 length]);
	
	//apply the above regex for long-hyphenated-words
	NSString *articlecontent3 = [regexLongHyphen stringByReplacingMatchesInString:articlecontent2 options:0 range:NSMakeRange(0, [articlecontent2 length]) withTemplate:@"$1 "];
	
	NSLog(@"Post Step 3 Length: %d", [articlecontent3 length]);
	
	//seperate the results of the above fixes into an array, one word per array entry
	NSArray *tempArray = [articlecontent3 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSLog(@"Post Step 4 Size: %d", [tempArray count]);
	
	//elimenates blank spots in the array
	wordArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
	wordArraySize = [wordArray count];
	
	NSLog(@"Words: %d", wordArraySize);
	
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
	jumpBack = true;
	if (jumpForward == true) {
		jumpForward = false;
		marker++;
	}
	if (marker < wordArraySize) {
		NSString *word = [wordArray objectAtIndex:marker];
		marker++;
		if ([word length] == 0) NSLog(@"*************************BLANK*****BLANK*****BLANK*************************"); //flurry todo - log blank words, with article uuid
		[currentWord setText:word];
        finish = [NSDate date];
		[self updateCounters];
	} else if (marker == wordArraySize) {
        [back setHidden:NO];
		if (sourceEnabled == true) {
			[source setHidden:NO];
			[timeRemaining setHidden:YES];
			[words setHidden:YES];
			[wpmRate setHidden:YES];
		}
		[timer invalidate];
		
		[self setToRestart];
		[self setToResume];
        
        [currentWord setText:@"Complete!"];
        [timeToRead setHidden:NO];
        [averageSpeed setHidden:NO];

		NSTimeInterval difference = [finish timeIntervalSinceDate:start];
		int minutes = floor(difference / 60);
		int seconds = difference - (minutes * 60);
		NSString *timeToReadResult = [NSString stringWithFormat:@"Time: %d:%02d", minutes, seconds];
		NSString *averageSpeedResult = [NSString stringWithFormat:@"Speed: %.0f wpm", wordArraySize * (60 / difference)];
        if (start == NULL) {
			timeToReadResult = @"Time: 0:00";
			averageSpeedResult = @"Speed: 0 wpm";
		}
		[timeToRead setText:timeToReadResult];
		[averageSpeed setText:averageSpeedResult];
	}
}

- (IBAction)prevWord:(id)sender
{
	jumpForward = true;
	if (jumpBack == true) {
		jumpBack = false;
		marker--;
	}
	if (marker > 0) {
		marker--;
		NSString *word = [wordArray objectAtIndex:marker];
		if ([word length] == 0) NSLog(@"*************************BLANK*****BLANK*****BLANK*************************"); //flurry todo - log blank words, with article uuid
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
	timer = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(nextWord:) userInfo:nil repeats:YES];
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
    [source setHidden:YES];
	[timeRemaining setHidden:NO];
	[words setHidden:NO];
	[wpmRate setHidden:NO];
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
    [source setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [source setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
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
